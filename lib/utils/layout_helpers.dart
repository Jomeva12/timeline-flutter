
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vuelo/vuelo.dart';
import '../providers/vuelo_provider.dart';

List<double> calcularAnchosColumnas(BuildContext context, List<String> columnas, double screenWidth) {
  return columnas.map((col) {
    final vuelosCol = context.read<VueloProvider>().vuelos
        .where((v) => v.posicion == col)
        .toList();

    if (vuelosCol.isEmpty) {
      final baseWidth = screenWidth / columnas.length;
      return baseWidth;
    }

    final pistas = <List<Vuelo>>[];
    for (final vuelo in vuelosCol) {
      bool asignado = false;
      for (final pista in pistas) {
        if (!pista.any((v) => seSuperponen(v, vuelo))) {
          pista.add(vuelo);
          asignado = true;
          break;
        }
      }
      if (!asignado) {
        pistas.add([vuelo]);
      }
    }

    final pistasNecesarias = pistas.length;
    final baseWidth = screenWidth / columnas.length;
    final anchoFinal = baseWidth * pistasNecesarias;

    debugPrint('📏 Columna $col → $pistasNecesarias pistas → ancho: ${anchoFinal.toStringAsFixed(2)}');

    return anchoFinal;
  }).toList();
}

bool seSuperponen(Vuelo a, Vuelo b) {
  final aInicio = a.horaLlegada.hour * 60 + a.horaLlegada.minute;
  final aFin = a.horaSalida.hour * 60 + a.horaSalida.minute;
  final bInicio = b.horaLlegada.hour * 60 + b.horaLlegada.minute;
  final bFin = b.horaSalida.hour * 60 + b.horaSalida.minute;

  return aInicio < bFin && bInicio < aFin;
}
int dateTimeToMinutes(DateTime dateTime) {
  return dateTime.hour * 60 + dateTime.minute;
}
