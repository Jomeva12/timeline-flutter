import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/eventos_provider.dart';

class HeaderTimeline extends StatelessWidget {
  final List<String> columnas;
  final List<double> columnWidths;
  final List<Color> columnColors;
  final ScrollController controller;

  const HeaderTimeline({
    super.key,
    required this.columnas,
    required this.columnWidths,
    required this.columnColors,
    required this.controller,
  });

  int _contarEventosPorColumna(BuildContext context, String columna) {
    return context
        .read<EventosProvider>()
        .eventos
        .where((e) => e.posicion == columna)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Row(
        children: [
          const SizedBox(width: 60), // espacio para la columna de horas
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: List.generate(columnas.length, (i) {
                  final nombre = columnas[i];
                  final cantidad = _contarEventosPorColumna(context, nombre);
                  return Container(
                    width: columnWidths[i],
                    alignment: Alignment.center,
                    color: columnColors[i % columnColors.length],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '($cantidad)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
