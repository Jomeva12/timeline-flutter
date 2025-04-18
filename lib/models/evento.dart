import 'package:flutter/material.dart';

class Evento {
  final String titulo;
  final String posicion;
  final TimeOfDay inicio;
  final TimeOfDay fin;
  final Color color;

  Evento({
    required this.titulo,
    required this.posicion,
    required this.inicio,
    required this.fin,
    required this.color,
  });
}