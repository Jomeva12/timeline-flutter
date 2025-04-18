import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/linked_scroll_controller.dart';
import 'package:timeline/models/eventos_provider.dart';
import 'package:timeline/widgets/crear_vuelo_bottomsheet.dart';
import 'package:timeline/widgets/curve_appbar_clipper.dart';
import 'package:timeline/widgets/custom_app_bar.dart';
import 'package:timeline/widgets/header_timeline.dart';
import 'package:timeline/widgets/importar_excel_bottomsheet.dart';
import 'package:timeline/widgets/timeline_wrapper.dart';
import 'package:timeline/widgets/floating_zoom_buttons.dart';
import 'package:timeline/utils/layout_helpers.dart';
import 'package:timeline/utils/color_utils.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  double hourHeight = 100;
  late Timer _timer;
  late ScrollController _verticalScroll;

  final columnas = ['P1', 'P2', 'P3', 'P4', 'P5', 'R6'];

  late final LinkedScrollControllerGroup _controllers;
  late final ScrollController _headerScrollController;
  late final ScrollController _gridScrollController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _verticalScroll = ScrollController();
    _controllers = LinkedScrollControllerGroup();
    _headerScrollController = _controllers.createScrollController();
    _gridScrollController = _controllers.createScrollController();

    // ⏱ Actualizar la línea de hora actual cada 30 segundos
    _timer =
        Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    _verticalScroll.dispose();
    _scrollController.dispose();
    _headerScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime({int retry = 0}) {
    final now = DateTime.now();
    final minutos = now.hour * 60 + now.minute;
    final top = (hourHeight / 60) * minutos;
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = top - screenHeight / 2;

    if (!_verticalScroll.hasClients ||
        !_verticalScroll.position.hasContentDimensions) {
      if (retry < 5) {
        debugPrint('🔁 Reintentando scroll... intento #$retry');
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToCurrentTime(retry: retry + 1);
        });
      }
      return;
    }

    final clamped =
        offset.clamp(0.0, _verticalScroll.position.maxScrollExtent.toDouble());
    _verticalScroll.animateTo(
      clamped,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutExpo,
    );
  }

  void _zoom(double factor) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentOffset = _verticalScroll.offset;
    final centerPixel = currentOffset + screenHeight / 2;
    final centerMinute = (centerPixel / hourHeight) * 60;

    setState(() {
      hourHeight += factor;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newCenterPixel = (centerMinute / 60) * hourHeight;
      final newOffset = newCenterPixel - screenHeight / 2;
      _verticalScroll.animateTo(
        newOffset.clamp(0, _verticalScroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventos = context.watch<EventosProvider>().eventos;
    final columnWidths = calcularAnchosColumnas(
        context, columnas, MediaQuery.of(context).size.width);
    final totalWidth = columnWidths.fold(0.0, (a, b) => a + b);
    final colors = generarColoresColumnas(columnas.length);
    final timelineHeight = (hourHeight / 60) * 24 * 60;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CurvedAppBarMenu(
          onImportExcel: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ImportarExcelBottomSheet(),
            );
          },
          onCrearVuelo: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // ✅ permite que se expanda con el teclado
              backgroundColor: Colors.transparent,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // ✅ desplaza el contenido
                  ),
                  child: CrearVueloBottomSheet(
                    onGuardar: () {
                      debugPrint('✈️ Guardar vuelo presionado');
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          HeaderTimeline(
            columnas: columnas,
            controller: _headerScrollController,
            columnWidths: columnWidths,
            columnColors: colors,
          ),
          TimelineWrapper(
            eventos: eventos,
            columnas: columnas,
            hourHeight: hourHeight,
            timelineHeight: timelineHeight,
            columnWidths: columnWidths,
            columnColors: colors,
            verticalScrollController: _verticalScroll,
            horizontalScrollController: _gridScrollController,
          ),
        ],
      ),
      floatingActionButton: FloatingZoomButtons(
        onZoomIn: () => _zoom(20),
        onZoomOut: () => _zoom(-20),
        hourHeight: hourHeight,
      ),
    );
  }
}
