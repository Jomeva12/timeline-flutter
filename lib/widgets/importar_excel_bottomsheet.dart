import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportarExcelBottomSheet extends StatefulWidget {
  final void Function(PlatformFile file)? onArchivoSeleccionado;
  final VoidCallback? onGuardar;

  const ImportarExcelBottomSheet({
    super.key,
    this.onArchivoSeleccionado,
    this.onGuardar,
  });

  @override
  State<ImportarExcelBottomSheet> createState() => _ImportarExcelBottomSheetState();
}

class _ImportarExcelBottomSheetState extends State<ImportarExcelBottomSheet> {
  PlatformFile? archivoSeleccionado;

  Future<void> _seleccionarArchivo() async {
    final permiso = await Permission.storage.request();

    if (permiso.isGranted) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => archivoSeleccionado = result.files.first);
        widget.onArchivoSeleccionado?.call(archivoSeleccionado!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso denegado para acceder al almacenamiento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          const Text(
            '📥 Seleccionar archivo Excel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _seleccionarArchivo,
            icon: const Icon(Icons.upload_file),
            label: const Text('Elegir archivo'),
          ),
          const SizedBox(height: 16),
          if (archivoSeleccionado != null)
            Text(
              'Seleccionado: ${archivoSeleccionado!.name}',
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: widget.onGuardar,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
