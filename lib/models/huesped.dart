class Huesped {
  final int idHuesped;
  final String nombre;
  final String apellido;
  final int? dni;
  final String? telefono;

  Huesped({
    required this.idHuesped,
    required this.nombre,
    required this.apellido,
    this.dni,
    this.telefono,
  });
  factory Huesped.fromJson(Map<String, dynamic> json) {
    return Huesped(
      idHuesped: json['idHuesped'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      dni: json['dni'],
      telefono: json['telefono'],
    );
  }
}