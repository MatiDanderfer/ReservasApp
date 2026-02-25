import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:reservas_app/screens/reserva_form_screen.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'reserva_detalle_screen.dart';
//import 'reservas_screen.dart';
//import 'huesped_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReservaService _reservaService = ReservaService();
  List<Reserva> _proximasReservas = [];
  Reserva? _reservaEnCurso;
  bool _cargando = true;
  
  @override
  void initState() {
    super.initState();
    _cargarProximasReservas();
  }

  Future<void> _cargarProximasReservas() async {
    try {
      final hoy = DateTime.now();
      final todasReservas = await _reservaService.listarTodas();

      // Reserva en curso: hoy está entre fechaEntrada y fechaSalida
      final enCurso = todasReservas.where((r) =>
        !hoy.isBefore(r.fechaEntrada) &&
        hoy.isBefore(r.fechaSalida.add(const Duration(days: 1)))
        //!hoy.isAfter(r.fechaSalida)
      ).firstOrNull;

      // Próximas: fechaEntrada es posterior a hoy, excluye la en curso
      final proximas = todasReservas
          .where((r) => r.fechaEntrada.isAfter(hoy) && r != enCurso && r.estado != 'Cancelada')
          .toList();
          proximas.sort((a, b) => a.fechaEntrada.compareTo(b.fechaEntrada));
      setState(() {
        _reservaEnCurso = enCurso;
        _proximasReservas = proximas.take(5).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _reservaEnCurso == null
                      ? const Card(
                          child: ListTile(
                            leading: Icon(Icons.info_outline, color: Colors.grey),
                            title: Text('No hay reserva en curso'),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservaDetalleScreen(reserva: _reservaEnCurso!),
                              ),
                            );
                            _cargarProximasReservas();
                          },
                          child: Card(
                            color: Colors.blue.shade50,
                            child: ListTile(
                              leading: const Icon(Icons.home, color: Colors.blue),
                              title: Text(
                                '${_reservaEnCurso!.nombreHuesped ?? ''} ${_reservaEnCurso!.apellidoHuesped ?? ''}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'En curso hasta ${DateFormat('dd/MM/yyyy').format(_reservaEnCurso!.fechaSalida)}\n'
                                'Saldo pendiente: \$${_reservaEnCurso!.saldoPendiente}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _colorEstado(_reservaEnCurso!.estado),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _reservaEnCurso!.estado,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Próximas reservas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: _proximasReservas.isEmpty
                      ? const Center(child: Text('No hay reservas próximas'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _proximasReservas.length,
                          itemBuilder: (context, index) {
                            final reserva = _proximasReservas[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservaDetalleScreen(reserva: reserva),
                                  ),
                                );
                                _cargarProximasReservas();
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    '${reserva.nombreHuesped ?? ''} ${reserva.apellidoHuesped ?? ''}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Entrada: ${DateFormat('dd/MM/yyyy').format(reserva.fechaEntrada)}\n'
                                    'Salida: ${DateFormat('dd/MM/yyyy').format(reserva.fechaSalida)}\n'
                                    'Seña: \$${reserva.senia}\n'
                                    'Saldo pendiente: \$${reserva.saldoPendiente}',
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _colorEstado(reserva.estado),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      reserva.estado,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Confirmada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      case 'Señada':
        return Colors.orange;
      case 'Pagada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}