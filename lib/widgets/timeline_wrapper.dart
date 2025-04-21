// widgets/timeline_wrapper.dart
import 'package:flutter/material.dart';
import 'package:timeline/widgets/hour_column.dart';
import 'package:timeline/widgets/timeline_grid.dart';
import 'package:timeline/widgets/current_time_line.dart';

import '../models/vuelo/vuelo.dart';

class TimelineWrapper extends StatelessWidget {
  final List<Vuelo> vuelos;  // Cambiado de eventos a vuelos
  final List<String> columnas;
  final double hourHeight;
  final double timelineHeight;
  final List<double> columnWidths;
  final List<Color> columnColors;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  const TimelineWrapper({
    super.key,
    required this.vuelos,  // Cambiado de eventos a vuelos
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
          height: timelineHeight + 50,
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
                          vuelos: vuelos,  // Cambiado de eventos a vuelos
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
