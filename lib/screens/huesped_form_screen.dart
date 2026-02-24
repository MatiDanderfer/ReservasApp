import 'package:flutter/material.dart';
import '../models/huesped.dart';
import '../services/huesped_service.dart';

class HuespedFormScreen extends StatefulWidget {
  final Huesped? huesped; // si viene con huesped es edición, si no es creación

  const HuespedFormScreen({super.key, this.huesped});

  @override
  State<HuespedFormScreen> createState() => _HuespedFormScreenState();
}

class _HuespedFormScreenState extends State<HuespedFormScreen> {
  final HuespedService _huespedService = HuespedService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _dniController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Si es edición precargá los datos
    if (widget.huesped != null) {
      _nombreController.text = widget.huesped!.nombre;
      _apellidoController.text = widget.huesped!.apellido;
      _telefonoController.text = widget.huesped!.telefono ?? '';
      _dniController.text = widget.huesped!.dni?.toString() ?? '';
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final dto = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'telefono': _telefonoController.text.isEmpty ? null : _telefonoController.text,
        'dni': _dniController.text.isEmpty ? null : int.parse(_dniController.text),
      };

      Huesped huesped;
      if (widget.huesped == null) {
        // Crear nuevo
        huesped = await _huespedService.crear(dto);
      } else {
        // Actualizar existente
        huesped = await _huespedService.actualizar(widget.huesped!.idHuesped, dto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.huesped == null
                ? 'Huésped creado correctamente'
                : 'Huésped actualizado correctamente'),
          ),
        );
        Navigator.pop(context, huesped);
      }
    } catch (e) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.huesped == null ? 'Nuevo Huésped' : 'Editar Huésped'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obligatorio';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obligatorio';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'DNI (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.huesped == null ? 'Crear huésped' : 'Guardar cambios',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}