import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reserva.dart';

class ReservaService {
  final String baseUrl = 'http://10.0.2.2:5011/api/reserva';

  Future<List<Reserva>> listarTodas() async {
    final response = await http.get(Uri.parse('$baseUrl/listar'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reserva.fromJson(json)).toList();
    }
    throw Exception('Error al cargar reservas');
  }

  Future<List<Reserva>> buscar(String nombreHuesped) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscar?nombreHuesped=$nombreHuesped')
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reserva.fromJson(json)).toList();
    }
    throw Exception('No se encontraron reservas');
  }

  Future<Reserva> crear(Map<String, dynamic> dto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(response.body));
    }
    throw Exception(response.body);
  }

  Future<bool> eliminar(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/eliminar/$id'),
    );
    if (response.statusCode == 204) {
      return true;
    }
    throw Exception('No se pudo eliminar la reserva');
  }

  Future<Reserva> actualizar(int id, Map<String, dynamic> dto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/actualizar/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(response.body));
    }
    throw Exception(response.body);
  }

  Future<Reserva> cambiarEstado(int id, String nuevoEstado) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/cambiarEstado/$id?nuevoEstado=$nuevoEstado'),
    );
    if (response.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(response.body));
    }
    throw Exception('No se pudo cambiar el estado');
  }

  Future<Reserva> buscarPorId(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );
    if (response.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(response.body));
    }
    throw Exception('Reserva no encontrada');
  }

  Future<List<Reserva>> buscarPorFecha(String fechaEntrada, String fechaSalida) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscarPorFecha?fechaEntrada=$fechaEntrada&fechaSalida=$fechaSalida'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reserva.fromJson(json)).toList();
    }
    throw Exception('No se encontraron reservas');
  }
  //busco desde la fecha de entrada, sin importar la fecha de salida
  Future<List<Reserva>> buscarDesdeInicio(String fechaInicio) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscarDesdeInicio?fechaInicio=$fechaInicio'),
    );
    print('Status code: ${response.statusCode}'); // agregá esto
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Cantidad de reservas en JSON: ${data.length}');
      return data.map((json) => Reserva.fromJson(json)).toList();
    }
    throw Exception('No se encontraron reservas');
  }

}