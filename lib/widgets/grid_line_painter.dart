import 'package:flutter/material.dart';

class GridLinePainter extends CustomPainter {
  final double hourHeight;

  GridLinePainter({required this.hourHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Cada 15 minutos → 4 líneas por hora
    final totalLines = 24 * 4;
    final spacing = hourHeight / 4;
    final offset = 8.0; // 🔧 Desplazamiento hacia abajo (ajústalo entre 1-3 según la vista)

    for (int i = 0; i <= totalLines; i++) {
      final y = i * spacing + offset;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
