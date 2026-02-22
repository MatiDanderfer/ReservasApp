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
  final String nombreHuesped;
  final String apellidoHuesped;

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
    required this.nombreHuesped,
    required this.apellidoHuesped,
  });
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      idReserva: json['idReserva'],
      fechaEntrada: DateTime.parse(json['fechaEntrada']),
      fechaSalida: DateTime.parse(json['fechaSalida']),
      cantidadPersonas: json['cantidadPersonas'],
      comentarios: json['comentarios'],
      estado: json['estado'],
      monto: json['monto'],
      senia: json['seña'],
      saldoPendiente: json['saldoPendiente'],
      idHuesped: json['idHuesped'],
      nombreHuesped: json['nombreHuesped'],
      apellidoHuesped: json['apellidoHuesped'],
    );
  }
}