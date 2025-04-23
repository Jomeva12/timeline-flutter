import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/vuelo/vuelo_import.dart';
import '../providers/empresa_provider.dart';
import '../providers/vuelo_provider.dart';
import 'importacion/appbar/appbar.dart';
import 'importacion/builder_card/vuelos_preview_list.dart';
import 'importacion/error_card/error_card.dart';
import 'importacion/file_selector_card/file_selector_card.dart';

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
  bool _isExpanded = true; // Controla el estado del acordeón
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // ----------------------------------------
  void _onVuelosChanged(List<VueloImport> updatedVuelos) {
    setState(() {

      debugPrint('_vuelosPreview modificado1 ${_vuelosPreview.length}');
      _vuelosPreview = updatedVuelos;
      debugPrint('_vuelosPreview modificado2 ${_vuelosPreview.length}');
    });
  }
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

      setState(() {
        _isExpanded = false; // Contrae la card si la importación fue exitosa
        _logs.add('Procesamiento completado');
      });

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
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(100), // Ajusta la altura según necesites
        child: AppBarImportacion(),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, _vuelosPreview.isNotEmpty ? 80 : 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.vertical(
                              top: const Radius.circular(12),
                              bottom: Radius.circular(_isExpanded ? 0 : 12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Información de Importación',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_fileName != null)
                                Text(
                                  _fileName!,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Contenido expandible
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: FileSelectorCard(
                          fileName: _fileName,
                          onSelect: _selectFile,
                          selectedDate: widget.selectedDate!,
                        ),
                        secondChild: const SizedBox.shrink(),
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
                              physics: const BouncingScrollPhysics(),
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
                        VuelosPreviewList(
                          vuelos: _vuelosPreview,
                          formatTimeOfDay: _formatTimeOfDay,
                          onVuelosChanged: _onVuelosChanged,
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // Botón fijo de guardar
          if (_vuelosPreview.isNotEmpty && _errores.isEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _guardarVuelos,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Guardar ${_vuelosPreview.length} vuelos',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  ),
                ),
              ),
            ),
        ],

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
  Future<void> _guardarVuelos() async {
    try {
      debugPrint('🚀 Iniciando proceso de guardar vuelos...');
      setState(() => _isLoading = true);

      final vueloProvider = Provider.of<VueloProvider>(context, listen: false);
      final empresaProvider = Provider.of<EmpresaProvider>(context, listen: false);
      debugPrint('✅ Providers obtenidos correctamente');

      // Mostrar diálogo de confirmación
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar importación'),
          content: Text('¿Deseas importar ${_vuelosPreview.length} vuelos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirmar != true) {
        debugPrint('❌ Importación cancelada por el usuario');
        return;
      }

      debugPrint('📝 Comenzando importación de ${_vuelosPreview.length} vuelos...');

      // Crear cada vuelo
      for (var i = 0; i < _vuelosPreview.length; i++) {
        final vuelo = _vuelosPreview[i];
        debugPrint('🔄 Procesando vuelo ${i + 1}/${_vuelosPreview.length}');
        debugPrint('📌 Buscando empresa: ${vuelo.empresaNombre}');

        // Obtener el ID de la empresa usando el nombre
        final empresaId = await empresaProvider.getEmpresaIdByNombre(vuelo.empresaNombre);

        if (empresaId == null) {
          debugPrint('❌ No se encontró la empresa: ${vuelo.empresaNombre}');
          throw Exception('No se encontró la empresa: ${vuelo.empresaNombre}');
        }

        debugPrint('✅ ID de empresa encontrado: $empresaId');
        debugPrint('📊 Datos del vuelo:');
        debugPrint('   - Empresa: ${vuelo.empresaNombre}');
        debugPrint('   - Vuelo llegada: ${vuelo.numeroVueloLlegada}');
        debugPrint('   - Vuelo salida: ${vuelo.numeroVueloSalida}');
        debugPrint('   - Fecha: ${widget.selectedDate}');
        debugPrint('   - Hora llegada: ${vuelo.horaLlegada}');
        debugPrint('   - Hora salida: ${vuelo.horaSalida}');
        debugPrint('   - Posición: ${vuelo.posicion}');

        try {
          await vueloProvider.crearVuelo(
            empresaId,
            vuelo.empresaNombre,
            vuelo.numeroVueloLlegada,
            vuelo.numeroVueloSalida,
            widget.selectedDate!,
            TimeOfDay.fromDateTime(vuelo.horaLlegada),
            TimeOfDay.fromDateTime(vuelo.horaSalida),
            vuelo.posicion,
          );
          debugPrint('✅ Vuelo ${i + 1} guardado exitosamente');
        } catch (e) {
          debugPrint('❌ Error al guardar vuelo ${i + 1}: $e');
          throw Exception('Error al guardar vuelo ${i + 1}: $e');
        }
      }

      debugPrint('✅ Todos los vuelos fueron importados exitosamente');

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_vuelosPreview.length} vuelos importados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Opcional: Navegar hacia atrás
      Navigator.pop(context);

    } catch (e) {
      debugPrint('❌ ERROR GENERAL: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar vuelos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      debugPrint('🏁 Proceso de importación finalizado');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
// Función para formatear TimeOfDay
  String _formatTimeOfDay(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}








