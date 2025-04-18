
import 'package:flutter/material.dart';

List<Color> generarColoresColumnas(int cantidad) {
  const pastel = Color(0xFFF3F4F6); // Gris claro pastel
  const blanco = Colors.white;

  return List.generate(cantidad, (index) {
    return index.isEven ? pastel : blanco;
  });
}
