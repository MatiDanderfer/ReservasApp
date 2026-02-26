import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/huesped.dart';

class HuespedService {
  final String baseUrl = 'http://192.168.0.15:5011/api/huesped';

  Future<List<Huesped>> listarTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/listar'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Huesped.fromJson(json)).toList();
    }
    throw Exception('Error al cargar huéspedes');
  }
  
  Future<List<Huesped>> buscar(String nombre, String apellido) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscar?nombre=$nombre&apellido=$apellido'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Huesped.fromJson(json)).toList();
    }
    throw Exception('No se encontraron huéspedes');
  }

  Future<Huesped> crear(Map<String, dynamic> dto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      return Huesped.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear huésped');
  }

  Future<Huesped> actualizar(int id, Map<String, dynamic> dto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/actualizar/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      return Huesped.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar huésped');
  }

  Future<bool> eliminar(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/eliminar/$id'),
    );
    if (response.statusCode == 204) {
      return true;
    }
    throw Exception('No se pudo eliminar el huésped');
  }

  Future<Huesped> buscarPorId(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );
    if (response.statusCode == 200) {
      return Huesped.fromJson(jsonDecode(response.body));
    }
    throw Exception('Huésped no encontrado');
  }

  Future<List<Huesped>> buscarPorNombre(String nombre) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscarPorNombre?nombre=$nombre'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Huesped.fromJson(json)).toList();
    }
    throw Exception('No se encontraron huéspedes');
  }

  Future<List<Huesped>> buscarPorApellido(String apellido) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buscarPorApellido?apellido=$apellido'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Huesped.fromJson(json)).toList();
    }
    throw Exception('No se encontraron huéspedes');
  }
}

