import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReservaService _reservaService = ReservaService();
  List<Reserva> _proximasReservas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProximasReservas();
  }

  Future<void> _cargarProximasReservas() async {
    try {
      final hoy = DateTime.now();
      final fechaFormateada = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(hoy);
      final reservas = await _reservaService.buscarDesdeInicio(fechaFormateada);
      setState(() {
        _proximasReservas = reservas.take(5).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _proximasReservas.isEmpty
              ? const Center(child: Text('No hay reservas próximas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _proximasReservas.length,
                  itemBuilder: (context, index) {
                    final reserva = _proximasReservas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          '${reserva.nombreHuesped ?? ''} ${reserva.apellidoHuesped ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Entrada: ${DateFormat('dd/MM/yyyy').format(reserva.fechaEntrada)}\n'
                          'Salida: ${DateFormat('dd/MM/yyyy').format(reserva.fechaSalida)}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nueva Reserva'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_search), label: 'Huéspedes'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // navegación la agregamos después
        },
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
      default:
        return Colors.grey;
    }
  }
}