import 'package:cloud_firestore/cloud_firestore.dart';

class MasterKey {
  final String id;
  final String ownerName;
  final String key;

  MasterKey({
    required this.id,
    required this.ownerName,
    required this.key,
  });

  factory MasterKey.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print('Datos raw del documento: $data'); // Debug log
    return MasterKey(
      id: doc.id,
      ownerName: data['ownerName']?.toString() ?? '',
      key: data['key']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'MasterKey(id: $id, ownerName: $ownerName, key: $key)';
  }
}