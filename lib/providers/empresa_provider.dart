import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/empresa/empresa.dart';

class EmpresaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Empresa> _empresas = [];
  bool _isLoading = false;

  List<Empresa> get empresas => _empresas;
  bool get isLoading => _isLoading;

  // Obtener todas las empresas
  Future<void> loadEmpresas() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _db.collection('empresas').get();
      _empresas = snapshot.docs.map((doc) => Empresa.fromDocument(doc)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Agregar nueva empresa
  Future<void> addEmpresa(Empresa empresa) async {
    try {
      final docRef = await _db.collection('empresas').add(empresa.toMap());
      final newEmpresa = empresa.copyWith(id: docRef.id);
      _empresas.add(newEmpresa);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar empresa
  Future<void> updateEmpresa(Empresa empresa) async {
    try {
      await _db.collection('empresas').doc(empresa.id).update(empresa.toMap());
      final index = _empresas.indexWhere((e) => e.id == empresa.id);
      if (index != -1) {
        _empresas[index] = empresa;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<String?> getEmpresaIdByNombre(String nombre) async {
    try {
      final snapshot = await _db
          .collection('empresas')
          .where('nombre', isEqualTo: nombre)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error al buscar empresa por nombre: $e');
      return null;
    }
  }
  // Eliminar empresa
  Future<void> deleteEmpresa(String id) async {
    try {
      await _db.collection('empresas').doc(id).delete();
      _empresas.removeWhere((empresa) => empresa.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}