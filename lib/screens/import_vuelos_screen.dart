import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/vuelo/vuelo_import.dart';
import '../widgets/curve_appbar_clipper.dart';

class ImportVuelosScreen extends StatefulWidget {
  final DateTime? selectedDate;
  const ImportVuelosScreen({super.key, this.selectedDate});

  @override
  State<ImportVuelosScreen> createState() => _ImportVuelosScreenState();
}
class _ImportVuelosScreenState extends State<ImportVuelosScreen> {
  bool _isLoading = false;
  String? _fileName;
  double? _progress;            // null = sin carga, 0–1 = progreso
  List<String> _logs = [];      // mensajes de log para UI y debug
  List<VueloImport> _vuelosPreview = [];
  List<String> _errores = [];

  // ----------------------------------------
  // Procesamiento de Excel (igual que antes)
  // ----------------------------------------
  Future<void> _processExcelFile(List<int> bytes) async {
    debugPrint('[ImportVuelos] _processExcelFile iniciado');
    setState(() {
      _logs
        ..clear()
        ..add('Iniciando procesamiento...');
      _errores.clear();
      _vuelosPreview.clear();
      _progress = 0;
    });

    try {
      final excel = Excel.decodeBytes(bytes);
      setState(() => _logs.add('Excel decodificado con éxito'));

      final sheetMap = excel.tables;
      if (sheetMap.isEmpty) {
        _showError('El archivo no contiene hojas');
        return;
      }
      final sheet = sheetMap.values.first!;
      final total = sheet.maxRows - 1;

      for (var i = 1; i <= total; i++) {
        setState(() => _logs.add('Procesando fila ${i + 1} de ${total + 1}'));
        try {
          final vuelo = VueloImport.fromExcelRow(sheet.row(i), widget.selectedDate!);
          _vuelosPreview.add(vuelo);
          debugPrint('[ImportVuelos] Agregado vuelo: ${vuelo.numeroVueloLlegada}');
        } catch (e) {
          _errores.add('Fila ${i + 1}: $e');
          debugPrint('[ImportVuelos][ERROR] Fila ${i + 1}: $e');
        }
        setState(() => _progress = i / total);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      setState(() => _logs.add('Procesamiento completado'));
    } catch (e) {
      _showError('Error al procesar archivo: $e');
      debugPrint('[ImportVuelos][EXCEPTION] $e');
    } finally {
      setState(() {
        _progress = null;
        _logs.add('Progreso limpiado');
      });
    }
  }

  // ----------------------------------------
  // Selección de archivo (igual que antes)
  // ----------------------------------------
  Future<void> _selectFile() async {
    if (!await _checkAndRequestStoragePermission()) return;
    setState(() {
      _isLoading = true;
      _progress = null;
      _logs.clear();
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null) {
        List<int>? bytes = result.files.first.bytes;
        if (bytes == null && result.files.first.path != null) {
          bytes = await File(result.files.first.path!).readAsBytes();
        }
        if (bytes != null) {
          setState(() {
            _fileName = result.files.first.name;
            _progress = 0;
            _logs.add('Archivo seleccionado: $_fileName');
            _errores.clear();
            _vuelosPreview.clear();
          });
          await _processExcelFile(bytes);
        } else {
          setState(() => _logs.add('No se pudieron leer los bytes del archivo'));
        }
      } else {
        setState(() => _logs.add('Selección de archivo cancelada'));
      }
    } catch (e) {
      _showError('Error al seleccionar archivo: $e');
      debugPrint('[ImportVuelos][EXCEPTION] $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------
  // Utilidades
  // ----------------------------------------
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<bool> _checkAndRequestStoragePermission() async {
    final perms = await [Permission.storage].request();
    final ok = perms[Permission.storage]?.isGranted ?? false;
    if (!ok) _showError('Permiso de almacenamiento denegado.');
    return ok;
  }

  // ----------------------------------------
  // Build: muestra logs y PREVIEW estilo Firestore
  // ----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // Ajusta la altura según necesites
        child: _AppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card para seleccionar archivo
              FileSelectorCard(
                fileName: _fileName,
                onSelect: _selectFile,
                selectedDate: widget.selectedDate!,
              ),

              const SizedBox(height: 12),
              // Barra de progreso
              if (_progress != null) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text('${(_progress! * 100).toStringAsFixed(0)}% procesado'),
                const SizedBox(height: 12),
              ],

              // Logs de proceso
              if (_logs.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: Card(
                    color: Colors.grey[100],
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: _logs.map((l) => Text('• $l')).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              // Errores de parsing
              if (_errores.isNotEmpty) ErrorCard(errors: _errores),

              const SizedBox(height: 12),
              // PREVIEW estilo Firestore
              if (_vuelosPreview.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vista previa:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vuelosPreview.length,
                  itemBuilder: (ctx, i) {
                    final v = _vuelosPreview[i];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Encabezado con empresa
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Para separar el contenido
                                children: [
                                  // Mantiene el diseño original de la empresa
                                  Row(
                                    children: [
                                      Icon(Icons.flight_takeoff, color: Colors.blue.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        v.empresaNombre ?? '<pendiente>',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Contador en el extremo derecho
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),

                                    ),
                                    child: Text(
                                      '${i + 1}/${_vuelosPreview.length}',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Información de vuelos
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn(
                                    'Llegada',
                                    v.numeroVueloLlegada,
                                    _formatTimeOfDay(v.horaLlegada),
                                    Icons.flight_land,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  _buildInfoColumn(
                                    'Salida',
                                    v.numeroVueloSalida,
                                    _formatTimeOfDay(v.horaSalida),
                                    Icons.flight_takeoff,
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              // Fecha y posición
                              Row(
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Función auxiliar para construir las columnas de información
  Widget _buildInfoColumn(
      String label, String number, String time, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

// Función para formatear TimeOfDay
  String _formatTimeOfDay(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedAppBarClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    const Text(
                      'Importar Vuelos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10.0,
                                      offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icono superior
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(12),

                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 20,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Recomendaciones',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                              Text(
                                                'Importantes',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),


                                    const SizedBox(height: 20),

                                    // Lista de recomendaciones
                                    ...buildRecommendationsList(),

                                    const SizedBox(height: 20),

                                    // Botón de cerrar
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        minimumSize: const Size(double.infinity, 45),
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'Entendido',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> buildRecommendationsList() {
    final recommendations = [
      {
        'icon': Icons.business,
        'title': 'Nombres de Empresa',
        'description': 'Use exactamente el mismo nombre registrado en empresas, sin espacios adicionales.',
      },
      {
        'icon': Icons.table_chart,
        'title': 'Formato del Archivo',
        'description': 'Verifique que las columnas tengan los nombres correctos y el tipo de datos apropiado.',
      },
      {
        'icon': Icons.swipe_left,
        'title': 'Edición Previa',
        'description': 'Puede eliminar elementos deslizando hacia la izquierda antes de la importación.',
      },
      {
        'icon': Icons.check_circle,
        'title': 'Confirmación',
        'description': 'Al finalizar, confirme la importación para procesar los datos.',
      },
      {
        'icon': Icons.error_outline,
        'title': 'En Caso de Error',
        'description': 'Verifique el archivo, formato, nombres de columnas y tipos de datos.',
      },
    ];

    return recommendations.map((rec) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                rec['icon'] as IconData,
                size: 18,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec['description'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

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

class ErrorCard extends StatelessWidget {
  final List<String> errors;
  const ErrorCard({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((e) => Text('• $e')).toList(),
        ),
      ),
    );
  }
}


