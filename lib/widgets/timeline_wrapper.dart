// widgets/timeline_wrapper.dart
import 'package:flutter/material.dart';
import 'package:timeline/models/evento.dart';
import 'package:timeline/widgets/hour_column.dart';
import 'package:timeline/widgets/timeline_grid.dart';
import 'package:timeline/widgets/current_time_line.dart';

class TimelineWrapper extends StatelessWidget {
  final List<Evento> eventos;
  final List<String> columnas;
  final double hourHeight;
  final double timelineHeight;
  final List<double> columnWidths;
  final List<Color> columnColors;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  const TimelineWrapper({
    super.key,
    required this.eventos,
    required this.columnas,
    required this.hourHeight,
    required this.timelineHeight,
    required this.columnWidths,
    required this.columnColors,
    required this.verticalScrollController,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = columnWidths.reduce((a, b) => a + b);

    return Expanded(
      child: SingleChildScrollView(
        controller: verticalScrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: timelineHeight + 50, // espacio extra para evitar corte visual
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            HourColumn(hourHeight: hourHeight),

              Expanded(
                child: SingleChildScrollView(
                  controller: horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: totalWidth,
                    child: Stack(
                      children: [
                        TimelineGrid(
                          eventos: eventos,
                          columnas: columnas,
                          hourHeight: hourHeight,
                          columnWidths: columnWidths,
                          columnColors: columnColors,
                        ),
                        CurrentTimeLine(hourHeight: hourHeight),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
