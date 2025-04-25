import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/vuelo/vuelo.dart';
import '../models/vuelo/vuelo_import.dart';

class VueloProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Vuelo> _vuelos = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _vuelosSub;

  List<Vuelo> get vuelos => _vuelos;

  String _obtenerRutaDia(DateTime fecha) {
    final y = fecha.year.toString();
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// Para fetch puntual (si lo necesitas en otro flujo)
  Future<void> getVuelosPorFecha(DateTime? fecha) async {
    try {
      final rutaDia = _obtenerRutaDia(fecha ?? DateTime.now());
      final snap = await _db
          .collection('vuelos')
          .doc(rutaDia)
          .collection('vuelos_dia')
          .get();
      _vuelos = snap.docs
          .map((d) => Vuelo.fromMap(d.id, d.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al obtener vuelos: $e');
      rethrow;
    }
  }

  /// Se subscribe en tiempo real y rellena [_vuelos]
  void listenVuelosPorFecha(DateTime? fecha) {
    final rutaDia = _obtenerRutaDia(fecha ?? DateTime.now());
    _vuelosSub?.cancel();
    _vuelosSub = _db
        .collection('vuelos')
        .doc(rutaDia)
        .collection('vuelos_dia')
        .snapshots()
        .listen((snap) {
      _vuelos = snap.docs
          .map((d) => Vuelo.fromMap(d.id, d.data()))
          .toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Error en stream de vuelos: $e');
    });
  }

  /// Crea o actualiza un vuelo en Firestore; NO toca [_vuelos]
  Future<void> crearVuelo(
      String empresaId,
      String empresaName,
      String numeroVueloLlegada,
      String numeroVueloSalida,
      String origen,
      String destino,
      DateTime fecha,
      TimeOfDay horaLlegada,
      TimeOfDay horaSalida,
      String posicion,
      ) async {
    final rutaDia = _obtenerRutaDia(fecha);

    // Asegurar doc padre
    final diaRef = _db.collection('vuelos').doc(rutaDia);
    await diaRef.set({
      'fecha': fecha.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Construir datos del vuelo
    final fechaLleg = DateTime(
      fecha.year, fecha.month, fecha.day,
      horaLlegada.hour, horaLlegada.minute,
    );
    final fechaSal = DateTime(
      fecha.year, fecha.month, fecha.day,
      horaSalida.hour, horaSalida.minute,
    );
    final data = {
      'empresaId': empresaId,
      'empresaName': empresaName,
      'numeroVueloLlegada': numeroVueloLlegada,
      'numeroVueloSalida': numeroVueloSalida,
      'origen': origen,
      'destino': destino,
      'fecha': fecha.toIso8601String(),
      'horaLlegada': fechaLleg.toIso8601String(),
      'horaSalida': fechaSal.toIso8601String(),
      'posicion': posicion,
    };

    // Escritura con merge para crear o actualizar
    await diaRef
        .collection('vuelos_dia')
        .doc(numeroVueloLlegada)
        .set(data, SetOptions(merge: true));

    debugPrint('✅ Vuelo escrito en Firestore: $rutaDia/$numeroVueloLlegada');
  }

  /// Actualiza campos de un vuelo existente; NO toca [_vuelos]
  Future<void> actualizarVuelo(
      String vueloId,
      String empresaId,
      String empresaName,
      String numeroVueloLlegada,
      String numeroVueloSalida,
      String origen,
      String destino,
      DateTime fecha,
      TimeOfDay horaLlegada,
      TimeOfDay horaSalida,
      String posicion,
      ) async {
    final rutaDia = _obtenerRutaDia(fecha);

    final fechaLleg = DateTime(
      fecha.year, fecha.month, fecha.day,
      horaLlegada.hour, horaLlegada.minute,
    );
    final fechaSal = DateTime(
      fecha.year, fecha.month, fecha.day,
      horaSalida.hour, horaSalida.minute,
    );
    final data = {
      'empresaId': empresaId,
      'empresaName': empresaName,
      'numeroVueloLlegada': numeroVueloLlegada,
      'numeroVueloSalida': numeroVueloSalida,
      'origen': origen,
      'destino': destino,
      'fecha': fecha.toIso8601String(),
      'horaLlegada': fechaLleg.toIso8601String(),
      'horaSalida': fechaSal.toIso8601String(),
      'posicion': posicion,
    };

    await _db
        .collection('vuelos')
        .doc(rutaDia)
        .collection('vuelos_dia')
        .doc(vueloId)
        .update(data);

    debugPrint('🔄 Vuelo actualizado en Firestore: $rutaDia/$vueloId');
  }

  Future<void> eliminarVuelo(String vueloId, DateTime fecha) async {
    final rutaDia = _obtenerRutaDia(fecha);
    await _db
        .collection('vuelos')
        .doc(rutaDia)
        .collection('vuelos_dia')
        .doc(vueloId)
        .delete();
    debugPrint('🗑️ Vuelo eliminado: $rutaDia/$vueloId');
    // El stream notificará la eliminación automáticamente
  }

  Future<List<DateTime>> getDiasConVuelos(DateTime mes) async {
    try {
      final mesStr = '${mes.year}${mes.month.toString().padLeft(2, '0')}';
      final snap = await _db
          .collection('vuelos')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '${mesStr}01')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '${mesStr}31')
          .get();

      return snap.docs.map((d) {
        final id = d.id;
        return DateTime(
          int.parse(id.substring(0, 4)),
          int.parse(id.substring(4, 6)),
          int.parse(id.substring(6, 8)),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error al obtener días con vuelos: $e');
      return [];
    }
  }

  Future<void> importarVuelos(List<VueloImport> vuelos) async {
    for (var vuelo in vuelos) {
      if (vuelo.empresaId == null) {
        throw Exception('ID de empresa no encontrado para: ${vuelo.empresaNombre}');
      }
      await crearVuelo(
        vuelo.empresaId!,
        vuelo.empresaNombre,
        vuelo.numeroVueloLlegada,
        vuelo.numeroVueloSalida,
        vuelo.origen,
        vuelo.destino,
        vuelo.fecha,
        TimeOfDay(
          hour: vuelo.horaLlegada.hour,
          minute: vuelo.horaLlegada.minute,
        ),
        TimeOfDay(
          hour: vuelo.horaSalida.hour,
          minute: vuelo.horaSalida.minute,
        ),
        vuelo.posicion,
      );
    }
    debugPrint('✅ Importación masiva completada');
    // El stream actualizará la lista automáticamente
  }

  @override
  void dispose() {
    _vuelosSub?.cancel();
    super.dispose();
  }
}
