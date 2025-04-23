import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/vuelo/vuelo.dart';
import '../models/vuelo/vuelo_import.dart';

class VueloProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Vuelo> _vuelos = [];

  List<Vuelo> get vuelos => _vuelos;

  // Función auxiliar para obtener la ruta del documento del día
  String _obtenerRutaDia(DateTime fecha) {
    return '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}';
  }

  // Obtener vuelos por fecha del calendario
  Future<void> getVuelosPorFecha(DateTime? fecha) async {
    try {
      final fechaBusqueda = fecha ?? DateTime.now();
      final rutaDia = _obtenerRutaDia(fechaBusqueda);

      debugPrint('🔍 Buscando vuelos para el día: $rutaDia');

      final snapshot = await _db
          .collection('vuelos')
          .doc(rutaDia)
          .collection('vuelos_dia')
          .get();

      _vuelos = snapshot.docs
          .map((doc) => Vuelo.fromMap(doc.id, doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al obtener vuelos: $e');
      rethrow;
    }
  }

  // En VueloProvider
  Future<void> actualizarVuelo(
      String vueloId,
      String empresaId,
      String empresaName,
      String numeroVueloLlegada,
      String numeroVueloSalida,
      DateTime fecha,
      TimeOfDay horaLlegada,
      TimeOfDay horaSalida,
      String posicion,
      ) async {
    try {
      final rutaDia = _obtenerRutaDia(fecha);

      // Convertir TimeOfDay a DateTime
      final fechaLlegada = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaLlegada.hour,
        horaLlegada.minute,
      );

      final fechaSalida = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaSalida.hour,
        horaSalida.minute,
      );

      final vueloActualizado = Vuelo(
        id: vueloId,
        empresaId: empresaId,
        empresaName: empresaName,
        numeroVueloLlegada: numeroVueloLlegada,
        numeroVueloSalida: numeroVueloSalida,
        fecha: fecha,
        horaLlegada: fechaLlegada,
        horaSalida: fechaSalida,
        posicion: posicion,
      );

      // Referencia al documento del día
      final diaRef = _db.collection('vuelos').doc(rutaDia);
      final vueloRef = diaRef.collection('vuelos_dia').doc(vueloId);

      await vueloRef.update(vueloActualizado.toMap());
      debugPrint('🔄 Vuelo actualizado: /vuelos/$rutaDia/vuelos_dia/$vueloId');

      // Actualizar lista local
      final index = _vuelos.indexWhere((v) => v.id == vueloId);
      if (index != -1) {
        _vuelos[index] = vueloActualizado;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al actualizar vuelo: $e');
      rethrow;
    }
  }

  // Crear nuevo vuelo
  Future<void> crearVuelo(
      String empresaId,
      String empresaName,
      String numeroVueloLlegada,
      String numeroVueloSalida,
      DateTime fecha,
      TimeOfDay horaLlegada,
      TimeOfDay horaSalida,
      String posicion,
      ) async {
    try {
      final rutaDia = _obtenerRutaDia(fecha);

      // Convertir TimeOfDay a DateTime
      final fechaLlegada = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaLlegada.hour,
        horaLlegada.minute,
      );

      final fechaSalida = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaSalida.hour,
        horaSalida.minute,
      );

      final nuevoVuelo = Vuelo(
        id: numeroVueloLlegada, // Usar número de vuelo como ID
        empresaId: empresaId,
        empresaName: empresaName,
        numeroVueloLlegada: numeroVueloLlegada,
        numeroVueloSalida: numeroVueloSalida,
        fecha: fecha,
        horaLlegada: fechaLlegada,
        horaSalida: fechaSalida,
        posicion: posicion,
      );

      // Referencia al documento del día
      final diaRef = _db.collection('vuelos').doc(rutaDia);

      // Crear el documento del día si no existe
      await diaRef.set({
        'fecha': fecha.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Referencia al documento del vuelo usando numeroVueloLlegada como ID
      final vueloRef = diaRef.collection('vuelos_dia').doc(numeroVueloLlegada);

      // Verificar si el vuelo ya existe
      final vueloDoc = await vueloRef.get();

      if (vueloDoc.exists) {
        // Actualizar vuelo existente
        await vueloRef.update(nuevoVuelo.toMap());
        debugPrint('🔄 Vuelo actualizado: /vuelos/$rutaDia/vuelos_dia/$numeroVueloLlegada');

        // Actualizar lista local
        final index = _vuelos.indexWhere((v) => v.id == numeroVueloLlegada);
        if (index != -1) {
          _vuelos[index] = nuevoVuelo;
        } else {
          _vuelos.add(nuevoVuelo);
        }
      } else {
        // Crear nuevo vuelo
        await vueloRef.set(nuevoVuelo.toMap());
        debugPrint('✅ Vuelo creado: /vuelos/$rutaDia/vuelos_dia/$numeroVueloLlegada');

        // Agregar a lista local
        _vuelos.add(nuevoVuelo);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al crear/actualizar vuelo: $e');
      rethrow;
    }
  }

  // Opcional: Eliminar vuelo
  Future<void> eliminarVuelo(String vueloId, DateTime fecha) async {
    try {
      final rutaDia = _obtenerRutaDia(fecha);

      await _db
          .collection('vuelos')
          .doc(rutaDia)
          .collection('vuelos_dia')
          .doc(vueloId)
          .delete();

      _vuelos.removeWhere((vuelo) => vuelo.id == vueloId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al eliminar vuelo: $e');
      rethrow;
    }
  }

  // En VueloProvider
  Future<List<DateTime>> getDiasConVuelos(DateTime mes) async {
    try {
      String mesStr = '${mes.year}${mes.month.toString().padLeft(2, '0')}';
      debugPrint('🔍 Buscando documentos para el mes: $mesStr');

      final snapshot = await _db
          .collection('vuelos')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '${mesStr}01')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '${mesStr}31')
          .get();

      debugPrint('📄 Documentos encontrados: ${snapshot.docs.length}');
      debugPrint(
          '📄 IDs de documentos: ${snapshot.docs.map((d) => d.id).join(', ')}');

      List<DateTime> diasConVuelos = snapshot.docs.map((doc) {
        String fechaStr = doc.id;
        int year = int.parse(fechaStr.substring(0, 4));
        int month = int.parse(fechaStr.substring(4, 6));
        int day = int.parse(fechaStr.substring(6, 8));
        return DateTime(year, month, day);
      }).toList();

      debugPrint(
          '📅 Fechas convertidas: ${diasConVuelos.map((d) => '${d.year}-${d.month}-${d.day}').join(', ')}');
      return diasConVuelos;
    } catch (e) {
      debugPrint('❌ Error al obtener días con vuelos: $e');
      return [];
    }
  }

  // Método para importación masiva
  Future<void> importarVuelos(List<VueloImport> vuelos) async {
    try {
      for (var vuelo in vuelos) {
        if (vuelo.empresaId == null) {
          throw 'ID de empresa no encontrado para: ${vuelo.empresaNombre}';
        }

        await crearVuelo(
          vuelo.empresaId!,
          vuelo.empresaNombre,// Ahora estamos seguros que no es null
          vuelo.numeroVueloLlegada,
          vuelo.numeroVueloSalida,
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
      notifyListeners();
      debugPrint('✅ Importación masiva completada exitosamente');
    } catch (e) {
      debugPrint('❌ Error en importación masiva: $e');
      rethrow;
    }
  }

}
