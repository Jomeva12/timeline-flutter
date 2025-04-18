import 'package:flutter/material.dart';
import '../models/evento.dart';

class EventWidget extends StatelessWidget {
  final Evento evento;

  const EventWidget({
    super.key,
    required this.evento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: evento.color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        evento.titulo,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
