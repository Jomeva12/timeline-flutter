import 'package:flutter/material.dart';
import 'package:timeline/widgets/grid_line_painter.dart';
import '../models/vuelo/vuelo.dart';
import '../models/vuelo/widget/vuelo_widget.dart';


class TimelineGrid extends StatelessWidget {
  final List<Vuelo> vuelos;
  final List<String> columnas;
  final double hourHeight;
  final List<double> columnWidths;
  final List<Color> columnColors;

  const TimelineGrid({
    super.key,
    required this.vuelos,
    required this.columnas,
    required this.hourHeight,
    required this.columnWidths,
    required this.columnColors,
  });

  double minuteToPixels(int minutes) => (minutes / 60) * hourHeight;

  int _timeToMinutes(DateTime time) => time.hour * 60 + time.minute;

  List<List<Vuelo>> _agruparVuelosEnBloques(List<Vuelo> vuelos) {
    final List<List<Vuelo>> bloques = [];

    for (final vuelo in vuelos) {
      bool asignado = false;

      for (final grupo in bloques) {
        if (grupo.any((v) => _seSuperponen(v, vuelo))) {
          grupo.add(vuelo);
          asignado = true;
          break;
        }
      }

      if (!asignado) {
        bloques.add([vuelo]);
      }
    }

    return bloques;
  }

  bool _seSuperponen(Vuelo a, Vuelo b) {
    final aInicio = _timeToMinutes(a.horaLlegada);
    final aFin = _timeToMinutes(a.horaSalida);
    final bInicio = _timeToMinutes(b.horaLlegada);
    final bFin = _timeToMinutes(b.horaSalida);

    return aInicio < bFin && bInicio < aFin;
  }

  List<Widget> _renderVuelosPorPistas(
      BuildContext context,
      List<Vuelo> vuelosColumna,
      double columnWidth,
      ) {
    final pistas = <List<Vuelo>>[];

    for (final vuelo in vuelosColumna) {
      bool asignado = false;

      for (final pista in pistas) {
        if (!pista.any((v) => _seSuperponen(v, vuelo))) {
          pista.add(vuelo);
          asignado = true;
          break;
        }
      }

      if (!asignado) {
        pistas.add([vuelo]);
      }
    }

    final totalPistas = pistas.length;
    final widgets = <Widget>[];

    for (int i = 0; i < pistas.length; i++) {
      for (final vuelo in pistas[i]) {
        final top = minuteToPixels(_timeToMinutes(vuelo.horaLlegada));
        final height = minuteToPixels(
            _timeToMinutes(vuelo.horaSalida) - _timeToMinutes(vuelo.horaLlegada)
        );
        final width = columnWidth / totalPistas;
        final left = i * width;

        widgets.add(Positioned(
          top: top,
          left: left,
          child: SizedBox(
            width: width,
            height: height,
            child: VueloWidget(vuelo: vuelo),  // Nuevo widget para vuelos
          ),
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = 24 * 60;
    final height = minuteToPixels(totalMinutes);

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(columnas.length, (colIndex) {
          final colName = columnas[colIndex];
          final vuelosCol = vuelos.where((v) => v.posicion == colName).toList();
          final bloques = _agruparVuelosEnBloques(vuelosCol);
          final columnWidth = columnWidths[colIndex];
          final backgroundColor = columnColors[colIndex % columnColors.length];

          return Container(
            width: columnWidth,
            color: backgroundColor,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(columnWidth, height),
                  painter: GridLinePainter(hourHeight: hourHeight),
                ),
                for (final bloque in bloques)
                  ..._renderVuelosPorPistas(context, vuelosCol, columnWidth),
              ],
            ),
          );
        }),
      ),
    );
  }
}
