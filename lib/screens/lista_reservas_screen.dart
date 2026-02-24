import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reservas_app/screens/main_screen.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'reserva_detalle_screen.dart';

class ListaReservasScreen extends StatefulWidget {
  const ListaReservasScreen({super.key});

  @override
  State<ListaReservasScreen> createState() => _ListaReservasScreenState();
}

class _ListaReservasScreenState extends State<ListaReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  List<Reserva> _reservas = [];
  List<Reserva> _reservasFiltradas = [];
  bool _cargando = true;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    try {
      final reservas = await _reservaService.listarTodas();
      reservas.sort((a, b) => a.fechaEntrada.compareTo(b.fechaEntrada));
      setState(() {
        _reservas = reservas;
        _reservasFiltradas = reservas;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void _filtrarPorFechas() {
    if (_fechaDesde == null || _fechaHasta == null) return;
    setState(() {
      _reservasFiltradas = _reservas.where((r) =>
        r.fechaEntrada.isAfter(_fechaDesde!.subtract(const Duration(days: 1))) &&
        r.fechaSalida.isBefore(_fechaHasta!.add(const Duration(days: 1)))
      ).toList();
    });
  }

  void _limpiarFiltro() {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
      _reservasFiltradas = _reservas;
    });
  }

  int get _montoTotal => _reservasFiltradas.fold(0, (sum, r) => sum + r.monto);
  int get _saldoTotal => _reservasFiltradas.fold(0, (sum, r) => sum + r.saldoPendiente);

  Future<void> _seleccionarFecha(bool esDesde) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esDesde ? (_fechaDesde ?? DateTime.now()) : (_fechaHasta ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() {
        if (esDesde) _fechaDesde = fecha;
        else _fechaHasta = fecha;
      });
      if (_fechaDesde != null && _fechaHasta != null) {
        _filtrarPorFechas();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Reservas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtro por fechas
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(true),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(_fechaDesde == null
                                  ? 'Desde'
                                  : DateFormat('dd/MM/yyyy').format(_fechaDesde!)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(false),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(_fechaHasta == null
                                  ? 'Hasta'
                                  : DateFormat('dd/MM/yyyy').format(_fechaHasta!)),
                            ),
                          ),
                          if (_fechaDesde != null || _fechaHasta != null)
                            IconButton(
                              onPressed: _limpiarFiltro,
                              icon: const Icon(Icons.clear, color: Colors.red),
                            ),
                        ],
                      ),
                      // Resumen de montos
                      if (_fechaDesde != null && _fechaHasta != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Reservas',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text('${_reservasFiltradas.length}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Monto total',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text('\$$_montoTotal',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Saldo pendiente',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text('\$$_saldoTotal',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: _reservasFiltradas.isEmpty
                      ? const Center(child: Text('No hay reservas en ese rango'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reservasFiltradas.length,
                          itemBuilder: (context, index) {
                            final reserva = _reservasFiltradas[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReservaDetalleScreen(reserva: reserva),
                                  ),
                                );
                                _cargarReservas();
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
                                    'Monto: \$${reserva.monto} | Saldo: \$${reserva.saldoPendiente}',
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
      default:
        return Colors.grey;
    }
  }
}