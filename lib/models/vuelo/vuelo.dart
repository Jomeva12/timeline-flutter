class Vuelo {
  final String? id;
  final String empresaId;
  final String empresaName;
  final String numeroVueloLlegada;
  final String numeroVueloSalida;
  final DateTime fecha;
  final DateTime horaLlegada;
  final DateTime horaSalida;
  final String posicion;

  Vuelo({
    this.id,
    required this.empresaId,
    required this.numeroVueloLlegada,
    required this.numeroVueloSalida,
    required this.fecha,
    required this.horaLlegada,
    required this.horaSalida,
    required this.posicion,
    required this.empresaName
  });

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'empresaName':empresaName,
      'numeroVueloLlegada': numeroVueloLlegada,
      'numeroVueloSalida': numeroVueloSalida,
      'fecha': fecha.toIso8601String(),
      'horaLlegada': horaLlegada.toIso8601String(),
      'horaSalida': horaSalida.toIso8601String(),
      'posicion': posicion,
    };
  }

  factory Vuelo.fromMap(String id, Map<String, dynamic> map) {
    return Vuelo(
      id: id,
      empresaId: map['empresaId'],
      empresaName:map['empresaName'],
      numeroVueloSalida: map['numeroVueloSalida'],
      numeroVueloLlegada: map['numeroVueloLlegada'],
      fecha: DateTime.parse(map['fecha']),
      horaLlegada: DateTime.parse(map['horaLlegada']),
      horaSalida: DateTime.parse(map['horaSalida']),
      posicion: map['posicion'],
    );
  }
}