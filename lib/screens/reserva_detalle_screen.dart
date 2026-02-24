import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reservas_app/screens/main_screen.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'reserva_form_screen.dart';

class ReservaDetalleScreen extends StatefulWidget {
  final Reserva reserva;

  const ReservaDetalleScreen({super.key, required this.reserva});

  @override
  State<ReservaDetalleScreen> createState() => _ReservaDetalleScreenState();
}

class _ReservaDetalleScreenState extends State<ReservaDetalleScreen> {
  final ReservaService _reservaService = ReservaService();
  late Reserva _reserva;

  @override
  void initState() {
    super.initState();
    _reserva = widget.reserva;
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('¿Estás seguro que querés cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await _reservaService.eliminar(_reserva.idReserva);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva cancelada correctamente')),
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

  Future<void> _editar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReservaFormScreen(reserva: _reserva),
      ),
    );
    if (resultado == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Reserva'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seccion('Huésped', '${_reserva.nombreHuesped ?? ''} ${_reserva.apellidoHuesped ?? ''}'),
            _seccion('Entrada', DateFormat('dd/MM/yyyy').format(_reserva.fechaEntrada)),
            _seccion('Salida', DateFormat('dd/MM/yyyy').format(_reserva.fechaSalida)),
            _seccion('Personas', '${_reserva.cantidadPersonas}'),
            _seccion('Monto total', '\$${_reserva.monto}'),
            _seccion('Seña', '\$${_reserva.senia}'),
            _seccion('Saldo pendiente', '\$${_reserva.saldoPendiente}'),
            _seccion('Comentarios', _reserva.comentarios ?? 'Sin comentarios'),
            const SizedBox(height: 8),
            _estadoBadge(_reserva.estado),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editar,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _eliminar,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar reserva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  Widget _estadoBadge(String estado) {
    Color color;
    switch (estado) {
      case 'Confirmada':
        color = Colors.green;
        break;
      case 'Cancelada':
        color = Colors.red;
        break;
      case 'Señada':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}