class Reserva {
  final int idReserva;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int cantidadPersonas;
  final String? comentarios;
  final String estado;
  final int monto;
  final int senia;
  final int saldoPendiente;
  final int idHuesped;
  final String? nombreHuesped;
  final String? apellidoHuesped;

  Reserva({
    required this.idReserva,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.cantidadPersonas,
    this.comentarios,
    required this.estado,
    required this.monto,
    required this.senia,
    required this.saldoPendiente,
    required this.idHuesped,
    this.nombreHuesped,
    this.apellidoHuesped,
  });
  factory Reserva.fromJson(Map<String, dynamic> json) {
    try{
      print('idReserva: ${json['idReserva']}');
      print('cantidadPersonas: ${json['cantidadPersonas']}');
      print('monto: ${json['monto']}');
      print('senia: ${json['senia']}');
      print('saldoPendiente: ${json['saldoPendiente']}');
      print('huespedId: ${json['huespedId']}');
      return Reserva(
      idReserva: json['idReserva'],
      fechaEntrada: DateTime.parse(json['fechaEntrada']),
      fechaSalida: DateTime.parse(json['fechaSalida']),
      cantidadPersonas: json['cantidadPersonas'] ?? 1,
      comentarios: json['comentarios'],
      estado: json['estado'],
      monto: json['monto'] ?? 0,
      senia: json['senia'] ?? 0,
      saldoPendiente: json['saldoPendiente'] ?? 0,
      idHuesped: json['huespedId'],
      nombreHuesped: json['nombreHuesped'],
      apellidoHuesped: json['apellidoHuesped'],
    );
    } catch (e) {
      print('Error al parsear Reserva: $e');
      print('JSON problemático: $json');
      rethrow;
    }
    
  }
}