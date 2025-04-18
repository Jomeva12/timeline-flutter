import 'package:flutter/material.dart';

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = 30.0;

    Path path = Path();
    path.moveTo(0, 0); // Inicio en la esquina superior izquierda
    path.lineTo(size.width, 0); // Línea recta superior

    // Bajar por el lado derecho hasta el borde inferior con curva
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - radius, size.height,
    );

    // Línea horizontal inferior hacia la izquierda
    path.lineTo(radius, size.height);

    // Curva inferior izquierda
    path.quadraticBezierTo(
      0, size.height,
      0, size.height - radius,
    );

    // Subir hasta el inicio
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
