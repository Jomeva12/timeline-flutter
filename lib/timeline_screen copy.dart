// timeline_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/linked_scroll_controller.dart';
import 'package:timeline/models/evento.dart';
import 'package:timeline/widgets/curve_appbar_clipper.dart';
import 'models/eventos_provider.dart';
import 'widgets/hour_column.dart';
import 'widgets/timeline_grid.dart';
import 'widgets/current_time_line.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  double hourHeight = 100;
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();
  late final LinkedScrollControllerGroup _controllers;
  late final ScrollController _headerScrollController;
  late final ScrollController _gridScrollController;
  final columnas = ['P1', 'P2', 'P3', 'P4', 'P5', 'R6'];

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _headerScrollController = _controllers.createScrollController();
    _gridScrollController = _controllers.createScrollController();

    _timer =
        Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _headerScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now().toLocal();
    final minutes = now.hour * 60 + now.minute;
    final currentTop = (hourHeight / 60) * minutes;
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = currentTop - screenHeight / 2 + 100;

    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutExpo,
    );
  }

  void _zoomKeepingCenter({required double newHourHeight}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentScrollOffset = _scrollController.offset;
    final centerPixel = currentScrollOffset + screenHeight / 2;
    final currentMinuteAtCenter = (centerPixel / hourHeight) * 60;

    setState(() {
      hourHeight = newHourHeight;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newCenterPixel = (currentMinuteAtCenter / 60) * hourHeight;
      final newScrollOffset = newCenterPixel - screenHeight / 2;

      _scrollController.animateTo(
        newScrollOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  int _contarEventosPorColumna(String columna) {
    return context
        .read<EventosProvider>()
        .eventos
        .where((e) => e.posicion == columna)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final eventos = context.watch<EventosProvider>().eventos;
    final totalMinutes = 24 * 60;
    final timelineHeight = (hourHeight / 60) * totalMinutes;
    final columnWidths = _calcularAnchosColumnas(context);
    final columnColors = _generarColoresColumnas();
    final totalWidth = columnWidths.reduce((a, b) => a + b);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 6, 98, 219), // lavanda pastel
                  Color.fromARGB(255, 6, 98, 219), // celeste claro
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Timeline Diarios',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          SizedBox(
            height: 65,
            child: Row(
              children: [
                const SizedBox(width: 60),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: List.generate(
                        columnas.length,
                        (i) => Container(
                          width: columnWidths[i],
                          alignment: Alignment.center,
                          color: columnColors[i % columnColors.length],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                columnas[i],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '(${_contarEventosPorColumna(columnas[i])})',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grilla
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: timelineHeight + 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HourColumn(hourHeight: hourHeight),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _gridScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: totalWidth,
                          child: Stack(
                            children: [
                              TimelineGrid(
                                eventos: eventos,
                                columnas: columnas,
                                hourHeight: hourHeight,
                                columnWidths: columnWidths,
                                columnColors: columnColors,
                              ),
                              CurrentTimeLine(hourHeight: hourHeight),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () {
              final newHeight = hourHeight + 20;
              _zoomKeepingCenter(newHourHeight: newHeight);
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () {
              if (hourHeight > 40) {
                final newHeight = hourHeight - 20;
                _zoomKeepingCenter(newHourHeight: newHeight);
              }
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }

  int _calcularMaxSolapamiento(List<Evento> eventos) {
    if (eventos.isEmpty) return 1;

    // Ordena por hora de inicio
    final ordenados = [...eventos]..sort((a, b) {
        final aMin = a.inicio.hour * 60 + a.inicio.minute;
        final bMin = b.inicio.hour * 60 + b.inicio.minute;
        return aMin.compareTo(bMin);
      });

    // Lista de pistas, cada pista es una lista de eventos que no se pisan
    List<List<Evento>> pistas = [];

    for (final evento in ordenados) {
      bool asignado = false;

      for (final pista in pistas) {
        final ultimo = pista.last;
        final finUltimo = ultimo.fin.hour * 60 + ultimo.fin.minute;
        final inicioActual = evento.inicio.hour * 60 + evento.inicio.minute;

        if (inicioActual >= finUltimo) {
          pista.add(evento);
          asignado = true;
          break;
        }
      }

      if (!asignado) {
        pistas.add([evento]);
      }
    }

    debugPrint('🎯 Colisión encadenada: ${pistas.length} pistas necesarias');
    return pistas.length;
  }

  int _calcularPistasNecesarias(List<Evento> eventos) {
    final pistas = <List<Evento>>[];

    for (final evento in eventos) {
      bool asignado = false;
      for (final pista in pistas) {
        if (!pista.any((e) => _seSuperponen(e, evento))) {
          pista.add(evento);
          asignado = true;
          break;
        }
      }
      if (!asignado) {
        pistas.add([evento]);
      }
    }

    return pistas.length;
  }

  List<double> _calcularAnchosColumnas(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return columnas.map((col) {
      final eventosCol = context
          .read<EventosProvider>()
          .eventos
          .where((e) => e.posicion == col)
          .toList();

      if (eventosCol.isEmpty) {
        // Si no hay eventos, asignamos el ancho base
        final baseWidth = screenWidth / columnas.length;
        debugPrint(
            '📏 Columna $col → sin eventos → ancho base: ${baseWidth.toStringAsFixed(2)}');
        return baseWidth;
      }

      // ✅ Calcular pistas para evitar solapamientos
      final pistas = <List<Evento>>[];
      for (final evento in eventosCol) {
        bool asignado = false;
        for (final pista in pistas) {
          if (!pista.any((e) => _seSuperponen(e, evento))) {
            pista.add(evento);
            asignado = true;
            break;
          }
        }
        if (!asignado) {
          pistas.add([evento]);
        }
      }

      final pistasNecesarias = pistas.length;
      final baseWidth = screenWidth / columnas.length;
      final anchoFinal = baseWidth * pistasNecesarias;

      debugPrint(
          '📏 Columna $col → $pistasNecesarias pistas → ancho: ${anchoFinal.toStringAsFixed(2)}');

      return anchoFinal;
    }).toList();
  }

  List<Color> _generarColoresColumnas() {
    const pastel = Color(0xFFF3F4F6); // Gris claro pastel (puedes cambiarlo)
    const blanco = Colors.white;

    return List.generate(columnas.length, (index) {
      return index.isEven ? pastel : blanco;
    });
  }

  List<List<Evento>> _agruparEventosEnBloques(List<Evento> eventos) {
    final List<List<Evento>> bloques = [];

    for (final evento in eventos) {
      bool asignado = false;

      for (final grupo in bloques) {
        if (grupo.any((e) => _seSuperponen(e, evento))) {
          grupo.add(evento);
          asignado = true;
          break;
        }
      }

      if (!asignado) {
        bloques.add([evento]);
      }
    }

    return bloques;
  }

  bool _seSuperponen(Evento a, Evento b) {
    final aInicio = a.inicio.hour * 60 + a.inicio.minute;
    final aFin = a.fin.hour * 60 + a.fin.minute;
    final bInicio = b.inicio.hour * 60 + b.inicio.minute;
    final bFin = b.fin.hour * 60 + b.fin.minute;

    return aInicio < bFin && bInicio < aFin;
  }
}
