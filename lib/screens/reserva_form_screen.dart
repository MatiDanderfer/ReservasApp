import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reservas_app/screens/main_screen.dart';
import '../models/huesped.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import '../services/huesped_service.dart';
import 'huesped_form_screen.dart';

class ReservaFormScreen extends StatefulWidget {
  final DateTime? fechaInicial;
  final Reserva? reserva; // si viene con reserva es edición

  const ReservaFormScreen({super.key, this.fechaInicial, this.reserva});

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> {
  final ReservaService _reservaService = ReservaService();
  final HuespedService _huespedService = HuespedService();

  final _formKey = GlobalKey<FormState>();
  final _comentariosController = TextEditingController();
  final _montoController = TextEditingController();
  final _seniaController = TextEditingController();
  final _cantidadController = TextEditingController();

  DateTime? _fechaEntrada;
  DateTime? _fechaSalida;
  String _estado = 'Confirmada';
  Huesped? _huespedSeleccionado;
  bool _guardando = false;

  bool get _esEdicion => widget.reserva != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      // Precargá datos de la reserva existente
      final r = widget.reserva!;
      _fechaEntrada = r.fechaEntrada;
      _fechaSalida = r.fechaSalida;
      _estado = r.estado.isEmpty ? 'Confirmada' : r.estado;
      _cantidadController.text = r.cantidadPersonas.toString();
      _montoController.text = r.monto.toString();
      _seniaController.text = r.senia.toString();
      _comentariosController.text = r.comentarios ?? '';
      // Precargá el huésped
      _huespedSeleccionado = Huesped(
        idHuesped: r.idHuesped,
        nombre: r.nombreHuesped ?? '',
        apellido: r.apellidoHuesped ?? '',
      );
    } else {
      _fechaEntrada = widget.fechaInicial;
    }
  }

  Future<void> _seleccionarFecha(bool esEntrada) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esEntrada
          ? (_fechaEntrada ?? DateTime.now())
          : (_fechaSalida ?? _fechaEntrada ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );
    if (fecha != null) {
      setState(() {
        if (esEntrada) {
          _fechaEntrada = fecha;
        } else {
          _fechaSalida = fecha;
        }
      });
    }
  }

  Future<void> _buscarHuesped() async {
    final resultado = await showDialog<Huesped>(
      context: context,
      builder: (context) => _DialogBuscarHuesped(huespedService: _huespedService),
    );
    if (resultado != null) {
      setState(() {
        _huespedSeleccionado = resultado;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaEntrada == null || _fechaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná las fechas de entrada y salida')),
      );
      return;
    }
    if (_huespedSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un huésped')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      final dto = {
        'huespedId': _huespedSeleccionado!.idHuesped,
        'fechaEntrada': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_fechaEntrada!),
        'fechaSalida': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_fechaSalida!),
        'cantidadPersonas': int.parse(_cantidadController.text),
        'comentarios': _comentariosController.text.isEmpty ? null : _comentariosController.text,
        'monto': int.parse(_montoController.text),
        'senia': int.parse(_seniaController.text.isEmpty ? '0' : _seniaController.text),
        'estado': _estado,
      };

      if (_esEdicion) {
        await _reservaService.actualizar(widget.reserva!.idReserva, dto);
      } else {
        await _reservaService.crear(dto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_esEdicion
                ? 'Reserva actualizada correctamente'
                : 'Reserva creada correctamente'),
          ),
        );
        Navigator.pop(context, true);
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
        title: Text(_esEdicion ? 'Editar Reserva' : 'Nueva Reserva'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(_huespedSeleccionado == null
                    ? 'Sin huésped seleccionado'
                    : '${_huespedSeleccionado!.nombre} ${_huespedSeleccionado!.apellido}'),
                subtitle: const Text('Tocá para buscar o crear huésped'),
                leading: const Icon(Icons.person),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _buscarHuesped,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaEntrada == null
                        ? 'Fecha entrada'
                        : DateFormat('dd/MM/yyyy').format(_fechaEntrada!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaSalida == null
                        ? 'Fecha salida'
                        : DateFormat('dd/MM/yyyy').format(_fechaSalida!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de personas',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obligatorio';
                final n = int.tryParse(value);
                if (n == null || n < 1 || n > 6) return 'Entre 1 y 6 personas';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto total',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obligatorio';
                if (int.tryParse(value) == null) return 'Ingresá un número válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seniaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Seña (opcional)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _comentariosController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentarios (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Confirmada', child: Text('Confirmada')),
                DropdownMenuItem(value: 'Señada', child: Text('Señada')),
                DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
              ],
              onChanged: (value) => setState(() => _estado = value!),
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
                      _esEdicion ? 'Guardar cambios' : 'Guardar reserva',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog para buscar huésped
class _DialogBuscarHuesped extends StatefulWidget {
  final HuespedService huespedService;

  const _DialogBuscarHuesped({required this.huespedService});

  @override
  State<_DialogBuscarHuesped> createState() => _DialogBuscarHuespedState();
}

class _DialogBuscarHuespedState extends State<_DialogBuscarHuesped> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  List<Huesped> _resultados = [];
  bool _buscando = false;

  Future<void> _buscarPorNombre() async {
    setState(() => _buscando = true);
    try {
      final resultados = await widget.huespedService.buscarPorNombre(_nombreController.text);
      setState(() { _resultados = resultados; _buscando = false; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; });
    }
  }

  Future<void> _buscarPorApellido() async {
    setState(() => _buscando = true);
    try {
      final resultados = await widget.huespedService.buscarPorApellido(_apellidoController.text);
      setState(() { _resultados = resultados; _buscando = false; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; });
    }
  }

  Future<void> _buscarPorAmbos() async {
    setState(() => _buscando = true);
    try {
      final resultados = await widget.huespedService.buscar(_nombreController.text, _apellidoController.text);
      setState(() { _resultados = resultados; _buscando = false; });
    } catch (e) {
      setState(() { _resultados = []; _buscando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar huésped'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
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
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buscando ? null : _buscarPorApellido,
                      child: const Text('Por apellido'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: _buscando ? null : _buscarPorAmbos,
                  child: const Text('Por nombre y apellido'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.maxFinite,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final nuevoHuesped = await Navigator.push<Huesped>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HuespedFormScreen(),
                      ),
                    );
                    if (nuevoHuesped != null && context.mounted) {
                      Navigator.pop(context, nuevoHuesped);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Crear nuevo huésped'),
                ),
              ),
              const SizedBox(height: 12),
              if (_buscando)
                const CircularProgressIndicator()
              else
                ..._resultados.map((h) => ListTile(
                      title: Text('${h.nombre} ${h.apellido}'),
                      subtitle: Text(h.telefono ?? ''),
                      onTap: () => Navigator.pop(context, h),
                    )),
              if (!_buscando && _resultados.isEmpty)
                const Text('Sin resultados'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}