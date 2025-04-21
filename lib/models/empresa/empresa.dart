import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Empresa {
  final String? id;
  final String nombre;
  final String alias;
  final Color color;

  Empresa({
    this.id,
    required this.nombre,
    required this.alias,
    required this.color,
  });

  // Convertir Empresa a Map
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'alias': alias,
      'color': color.value, // Guardamos el color como un entero
    };
  }

  // Crear Empresa desde DocumentSnapshot
  factory Empresa.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Empresa(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      alias: data['alias'] ?? '',
      color: Color(data['color'] ?? Colors.blue.value),
    );
  }

  // Crear copia de Empresa con cambios
  Empresa copyWith({
    String? id,
    String? nombre,
    String? alias,
    Color? color,
  }) {
    return Empresa(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      alias: alias ?? this.alias,
      color: color ?? this.color,
    );
  }
}