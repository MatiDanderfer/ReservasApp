import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reservas_screen.dart';
import 'huesped_screen.dart';
import 'reserva_form_screen.dart';
import 'lista_reservas_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReservasScreen(),
    const HuespedesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReservaFormScreen()),
            );
          } else if (index == 0) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaReservasScreen()),
              );
            } else {
                setState(() => _currentIndex = index);
              }
          },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'Huéspedes'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nueva Reserva'),
        ],
      ),
    );
  }
}