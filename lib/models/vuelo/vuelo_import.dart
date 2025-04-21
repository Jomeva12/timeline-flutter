import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class VueloImport {
  final DateTime fecha;
  final String empresaNombre;
  String? empresaId;
  final String numeroVueloLlegada;
  final String numeroVueloSalida;
  final DateTime horaLlegada;
  final DateTime horaSalida;
  final String posicion;

  VueloImport({
    required this.fecha,
    required this.empresaNombre,
    this.empresaId,
    required this.numeroVueloLlegada,
    required this.numeroVueloSalida,
    required this.horaLlegada,
    required this.horaSalida,
    required this.posicion,
  });

  factory VueloImport.fromExcelRow(List<Data?> row, DateTime selectedDate) {
    // row[3] y row[4] son Data? del paquete excel
    final horaLlegada = _parseTime(row[3], selectedDate);
    final horaSalida  = _parseTime(row[4], selectedDate);

    return VueloImport(
      fecha: selectedDate,
      empresaNombre: row[0]?.value.toString().trim() ?? '',
      numeroVueloLlegada: row[1]?.value.toString().trim() ?? '',
      numeroVueloSalida: row[2]?.value.toString().trim() ?? '',
      horaLlegada: horaLlegada,
      horaSalida: horaSalida,
      posicion: row[5]?.value.toString().trim() ?? '',
    );
  }

  static DateTime _parseTime(Data? cell, DateTime date) {
    final raw = cell?.value;
    // 1) Si ya es DateTime
    if (raw is DateTime) {
      return DateTime(date.year, date.month, date.day,
          raw.hour, raw.minute, raw.second);
    }
    // 2) Si es número de serie Excel
    if (raw is double) {
      final epoch = DateTime(1899, 12, 30);
      final dt = epoch.add(
        Duration(milliseconds: (raw * 24 * 3600 * 1000).round()),
      );
      return DateTime(date.year, date.month, date.day,
          dt.hour, dt.minute, dt.second);
    }
    // 3) Lo tratamos como String "HH:mm" o "HH:mm:ss"
    final s = raw.toString().trim();
    final fmt = s.split(':').length == 3
        ? DateFormat('HH:mm:ss')
        : DateFormat.Hm();
    final parsed = fmt.parse(s);
    return DateTime(date.year, date.month, date.day,
        parsed.hour, parsed.minute, parsed.second);
  }

  @override
  String toString() =>
      'VueloImport($empresaNombre: $numeroVueloLlegada → $numeroVueloSalida)';
}
