import 'package:flutter/material.dart';
import 'evento.dart';

class EventosProvider extends ChangeNotifier {
  final List<Evento> _eventos = [
    Evento(
      titulo: 'Evento Naranja',
      posicion: 'P1',
      inicio: const TimeOfDay(hour: 15, minute: 20),
      fin: const TimeOfDay(hour: 15, minute: 50),
      color: Colors.orange,
    ),
    Evento(
      titulo: 'Evento Verde',
      posicion: 'P1',
      inicio: const TimeOfDay(hour: 7, minute: 15),
      fin: const TimeOfDay(hour: 7, minute: 53),
      color: Colors.green,
    ),
    Evento(
      titulo: 'Evento Azul',
      posicion: 'P1',
      inicio: const TimeOfDay(hour: 7, minute: 59),
      fin: const TimeOfDay(hour: 8, minute: 15),
      color: Colors.lightBlue,
    ),
     Evento(
      titulo: 'Evento Purpura',
      posicion: 'P1',
      inicio: const TimeOfDay(hour: 7, minute: 10),
      fin: const TimeOfDay(hour: 15, minute: 55),
      color: Colors.purple,
    ),
    Evento(
      titulo: 'Evento Morado',
      posicion: 'R6',
      inicio: const TimeOfDay(hour: 18, minute: 30),
      fin: const TimeOfDay(hour: 19, minute: 30),
      color: Colors.purple,
    ),
  ];

  List<Evento> get eventos => _eventos;

  void agregarEvento(Evento evento) {
    _eventos.add(evento);
    notifyListeners();
  }

  void limpiarEventos() {
    _eventos.clear();
    notifyListeners();
  }
}
