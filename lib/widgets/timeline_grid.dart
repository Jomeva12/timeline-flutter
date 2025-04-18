import 'package:flutter/material.dart';
import 'package:timeline/widgets/grid_line_painter.dart';
import '../models/evento.dart';
import 'event_widget.dart';

class TimelineGrid extends StatelessWidget {
  final List<Evento> eventos;
  final List<String> columnas;
  final double hourHeight;
  final List<double> columnWidths;
  final List<Color> columnColors;

  const TimelineGrid({
    super.key,
    required this.eventos,
    required this.columnas,
    required this.hourHeight,
    required this.columnWidths,
    required this.columnColors,
  });

  double minuteToPixels(int minutes) => (minutes / 60) * hourHeight;

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  List<List<Evento>> _agruparEventosEnBloques(List<Evento> eventos) {
    final List<List<Evento>> bloques = [];

    for (final evento in eventos) {
      bool asignado = false;

      for (final grupo in bloques) {
        if (grupo.any((e) => _seSuperponen(e, evento))) {
          grupo.add(evento);
          asignado = true;
          break;
        }
      }

      if (!asignado) {
        bloques.add([evento]);
      }
    }

    return bloques;
  }

  bool _seSuperponen(Evento a, Evento b) {
    final aInicio = _timeToMinutes(a.inicio);
    final aFin = _timeToMinutes(a.fin);
    final bInicio = _timeToMinutes(b.inicio);
    final bFin = _timeToMinutes(b.fin);

    return aInicio < bFin && bInicio < aFin;
  }

  List<Widget> _renderEventosPorPistas(
  BuildContext context,
  List<Evento> eventosColumna,
  double columnWidth,
) {
  final pistas = <List<Evento>>[];

  for (final evento in eventosColumna) {
    bool asignado = false;

    for (final pista in pistas) {
      if (!pista.any((e) => _seSuperponen(e, evento))) {
        pista.add(evento);
        asignado = true;
        break;
      }
    }

    if (!asignado) {
      pistas.add([evento]);
    }
  }

  final totalPistas = pistas.length;
  final widgets = <Widget>[];

  for (int i = 0; i < pistas.length; i++) {
    for (final evento in pistas[i]) {
      final top = minuteToPixels(_timeToMinutes(evento.inicio));
      final height = minuteToPixels(_timeToMinutes(evento.fin) - _timeToMinutes(evento.inicio));
      final width = columnWidth / totalPistas;
      final left = i * width;

      widgets.add(Positioned(
        top: top,
        left: left,
        child: SizedBox(
          width: width,
          height: height,
          child: EventWidget(evento: evento),
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
          final eventosCol = eventos.where((e) => e.posicion == colName).toList();
          final bloques = _agruparEventosEnBloques(eventosCol);
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
                  ..._renderEventosPorPistas(context, eventosCol, columnWidth),

              ],
            ),
          );
        }),
      ),
    );
  }
}
