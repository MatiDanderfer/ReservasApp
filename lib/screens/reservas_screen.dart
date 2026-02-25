// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:reservas_app/screens/main_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'reserva_detalle_screen.dart';
import 'reserva_form_screen.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  List<Reserva> _todasReservas = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    try {
      final reservas = await _reservaService.listarTodas();
      setState(() {
        _todasReservas = reservas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
    }
  }

  // Verifica si un día está ocupado por alguna reserva
  bool _diaOcupado(DateTime dia) {
    return _todasReservas.any((r) =>
        r.estado != 'Cancelada' &&
        !dia.isBefore(r.fechaEntrada) &&
        !dia.isAfter(r.fechaSalida));
  }

  // Devuelve la reserva que ocupa un día específico
  Reserva? _reservaDelDia(DateTime dia) {
    try {
      return _todasReservas.firstWhere((r) =>
          r.estado != 'Cancelada' &&
          !dia.isBefore(r.fechaEntrada) &&
          !dia.isAfter(r.fechaSalida));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
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
                TableCalendar(
                  locale: 'es_Ar',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2050, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    final reserva = _reservaDelDia(selectedDay);
                    if (reserva != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaDetalleScreen(reserva: reserva),
                        ),
                      ).then((_) async {
                        setState(() => _selectedDay = null);
                        await _cargarReservas();
                      });
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (_diaOcupado(day)) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.green.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (_selectedDay != null && _reservaDelDia(_selectedDay!) == null)
                   Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const Text('No hay reserva en este día'),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservaFormScreen(fechaInicial: _selectedDay),
              ),
            );
             setState(() {
                _selectedDay = null;
              });
              await _cargarReservas();
          },
          icon: const Icon(Icons.add),
          label: const Text('Crear reserva'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  ),
              ],
            ),
    );
  }
}