import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/seguridad/master_key.dart';

class MasterKeyProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String masterKeyDocId = 'yAJMgcm0VL9G5LXsms9f';
  MasterKey? _currentMasterKey;

  String get ownerName => _currentMasterKey?.ownerName ?? 'No disponible';

  Future<void> loadMasterKeyInfo() async {
    try {
      print('Intentando cargar documento con ID: $masterKeyDocId');

      final doc = await _db
          .collection('master_keys')
          .doc(masterKeyDocId)
          .get();

      if (doc.exists) {
        print('Documento encontrado: ${doc.data()}');
        _currentMasterKey = MasterKey.fromDocument(doc);
        print('MasterKey creado - ownerName: ${_currentMasterKey?.ownerName}, key: ${_currentMasterKey?.key}');
        notifyListeners();
      } else {
        print('El documento no existe. Ruta completa: master_keys/$masterKeyDocId');

        // Intentemos listar todos los documentos de la colección para debug
        final allDocs = await _db.collection('master_keys').get();
        print('Documentos en la colección master_keys:');
        for (var doc in allDocs.docs) {
          print('ID: ${doc.id}, Data: ${doc.data()}');
        }
      }
    } catch (e) {
      print('Error loading master key: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<bool> validateMasterKey(String inputKey) async {
    try {
      if (_currentMasterKey == null) {
        await loadMasterKeyInfo();
      }
      print('Validando clave: Input=$inputKey, Stored=${_currentMasterKey?.key}');
      return _currentMasterKey?.key == inputKey;
    } catch (e) {
      print('Error validating master key: $e');
      return false;
    }
  }
}