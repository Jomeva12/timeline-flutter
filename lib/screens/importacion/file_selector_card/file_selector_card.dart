import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileSelectorCard extends StatelessWidget {
  final String? fileName;
  final VoidCallback onSelect;
  final DateTime selectedDate;
  const FileSelectorCard({
    super.key,
    required this.fileName,
    required this.onSelect,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar Archivo Excel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Columnas: Nombre de Empresa, Vuelo Llegada, Vuelo Salida, Hora Llegada, Hora Salida, Posición',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onSelect,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar Archivo'),
            ),
            if (fileName != null) ...[
              const SizedBox(height: 8),
              Text('Archivo: $fileName'),
            ],
          ],
        ),
      ),
    );
  }
}