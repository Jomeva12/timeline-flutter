import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vuelo_provider.dart';

class HeaderTimeline extends StatelessWidget {
  final List<String> columnas;
  final List<double> columnWidths;
  final List<Color> columnColors;
  final ScrollController controller;
  final Map<String, int> vuelosPorPosicion;
  const HeaderTimeline({
    super.key,
    required this.columnas,
    required this.columnWidths,
    required this.columnColors,
    required this.controller,
  required this.vuelosPorPosicion,
  });

  @override
  Widget build(BuildContext context) {
    // Agregar prints de debug

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Columna de hora
          Container(
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '(24h)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Columnas de posiciones
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: List.generate(columnas.length, (i) {
                  final nombre = columnas[i];
                  final cantidad = vuelosPorPosicion[nombre] ?? 0;

                  return Container(
                    width: columnWidths[i],
                    height: 65,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: columnColors[i % columnColors.length].withOpacity(0.1),
                      border: Border(
                        left: BorderSide(color: Colors.grey[300]!),
                        right: i == columnas.length - 1
                            ? BorderSide(color: Colors.grey[300]!)
                            : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
