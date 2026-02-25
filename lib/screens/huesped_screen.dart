import 'package:flutter/material.dart';
import 'package:reservas_app/screens/main_screen.dart';
import '../models/huesped.dart';
import '../services/huesped_service.dart';
import 'huesped_form_screen.dart';
import 'huesped_detalle_screen.dart';

class HuespedesScreen extends StatefulWidget {
  const HuespedesScreen({super.key});

  @override
  State<HuespedesScreen> createState() => _HuespedesScreenState();
}

class _HuespedesScreenState extends State<HuespedesScreen> {
  final HuespedService _huespedService = HuespedService();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  List<Huesped> _resultados = [];
  bool _buscando = false;
  bool _buscado = false;

  Future<void> _buscarPorNombre() async {
    setState(() => _buscando = true);
    try {
      final resultados = await _huespedService.buscarPorNombre(_nombreController.text);
      setState(() { _resultados = resultados; _buscando = false; _buscado = true; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; _buscado = true; });
    }
  }

  Future<void> _buscarPorApellido() async {
    setState(() => _buscando = true);
    try {
      final resultados = await _huespedService.buscarPorApellido(_apellidoController.text);
      setState(() { _resultados = resultados; _buscando = false; _buscado = true; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; _buscado = true; });
    }
  }

  Future<void> _buscarPorAmbos() async {
    setState(() => _buscando = true);
    try {
      final resultados = await _huespedService.buscar(_nombreController.text, _apellidoController.text);
      setState(() { _resultados = resultados; _buscando = false; _buscado = true; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; _buscado = true; });
    }
  }

  Future<void> _eliminar(Huesped huesped) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar huésped'),
        content: Text('¿Eliminár a ${huesped.nombre} ${huesped.apellido}?'),
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
        await _huespedService.eliminar(huesped.idHuesped);
        setState(() => _resultados.remove(huesped));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Huésped eliminado correctamente')),
          );
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
        title: const Text('Huéspedes'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _buscando ? null : _buscarPorNombre,
                        child: const Text('Por nombre'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _buscando ? null : _buscarPorApellido,
                        child: const Text('Por apellido'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _buscando ? null : _buscarPorAmbos,
                    child: const Text('Por nombre y apellido'),
                  ),
                ),
              ],
            ),
          ),
          if (_buscando)
            const CircularProgressIndicator()
          else if (_buscado && _resultados.isEmpty)
            const Text('No se encontraron huéspedes')
          else
            Expanded(
              child: ListView.builder(
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  final huesped = _resultados[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('${huesped.nombre} ${huesped.apellido}'),
                    subtitle: Text(huesped.telefono ?? 'Sin teléfono'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HuespedDetalleScreen(huesped: huesped),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HuespedFormScreen(huesped: huesped),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminar(huesped),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HuespedFormScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}