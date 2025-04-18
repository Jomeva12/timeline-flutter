
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/evento.dart';
import '../models/eventos_provider.dart';

List<double> calcularAnchosColumnas(BuildContext context, List<String> columnas, double screenWidth) {
  return columnas.map((col) {
    final eventosCol = context.read<EventosProvider>().eventos.where((e) => e.posicion == col).toList();

    if (eventosCol.isEmpty) {
      final baseWidth = screenWidth / columnas.length;
      debugPrint('📏 Columna $col → sin eventos → ancho base: ${baseWidth.toStringAsFixed(2)}');
      return baseWidth;
    }

    final pistas = <List<Evento>>[];
    for (final evento in eventosCol) {
      bool asignado = false;
      for (final pista in pistas) {
        if (!pista.any((e) => seSuperponen(e, evento))) {
          pista.add(evento);
          asignado = true;
          break;
        }
      }
      if (!asignado) {
        pistas.add([evento]);
      }
    }

    final pistasNecesarias = pistas.length;
    final baseWidth = screenWidth / columnas.length;
    final anchoFinal = baseWidth * pistasNecesarias;

    debugPrint('📏 Columna $col → $pistasNecesarias pistas → ancho: ${anchoFinal.toStringAsFixed(2)}');

    return anchoFinal;
  }).toList();
}

bool seSuperponen(Evento a, Evento b) {
  final aInicio = a.inicio.hour * 60 + a.inicio.minute;
  final aFin = a.fin.hour * 60 + a.fin.minute;
  final bInicio = b.inicio.hour * 60 + b.inicio.minute;
  final bFin = b.fin.hour * 60 + b.fin.minute;

  return aInicio < bFin && bInicio < aFin;
}
