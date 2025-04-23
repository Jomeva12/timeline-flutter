
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/vuelo/vuelo_import.dart';

class CardImportacionVuelo extends StatelessWidget {
  const CardImportacionVuelo({
    super.key,
    required this.v,
  });

  final VueloImport v;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              DateFormat('dd/MM/yyyy').format(v.fecha),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.place, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 4),
              Text(
                'Posición ${v.posicion}',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}