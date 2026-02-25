import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/huesped.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import '../services/huesped_service.dart';
import 'reserva_detalle_screen.dart';
import 'huesped_form_screen.dart';
import 'main_screen.dart';

class HuespedDetalleScreen extends StatefulWidget {
  final Huesped huesped;

  const HuespedDetalleScreen({super.key, required this.huesped});

  @override
  State<HuespedDetalleScreen> createState() => _HuespedDetalleScreenState();
}

class _HuespedDetalleScreenState extends State<HuespedDetalleScreen> {
  final ReservaService _reservaService = ReservaService();
  final HuespedService _huespedService = HuespedService();
  List<Reserva> _reservas = [];
  bool _cargando = true;
  late Huesped _huesped;

  @override
  void initState() {
    super.initState();
    _huesped = widget.huesped;
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    try {
      final reservas = await _reservaService.buscar(_huesped.nombre);
      reservas.sort((a, b) => a.fechaEntrada.compareTo(b.fechaEntrada));
      setState(() {
        _reservas = reservas;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarHuesped() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar huésped'),
        content: Text('¿Eliminar a ${_huesped.nombre} ${_huesped.apellido}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await _huespedService.eliminar(_huesped.idHuesped);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Huésped eliminado correctamente')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_huesped.nombre} ${_huesped.apellido}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HuespedFormScreen(huesped: _huesped),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _eliminarHuesped,
          ),
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
      body: Column(
        children: [
          // Info del huésped
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_huesped.telefono != null)
                  Text('Teléfono: ${_huesped.telefono}'),
                if (_huesped.dni != null)
                  Text('DNI: ${_huesped.dni}'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historial de reservas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          // Lista de reservas
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _reservas.isEmpty
                    ? const Center(child: Text('Sin reservas registradas'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _reservas.length,
                        itemBuilder: (context, index) {
                          final reserva = _reservas[index];
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
                                  'Entrada: ${DateFormat('dd/MM/yyyy').format(reserva.fechaEntrada)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
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
        case 'Pagada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}