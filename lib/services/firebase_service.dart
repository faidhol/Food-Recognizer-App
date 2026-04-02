import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveResult({
    required String label,
    required String confidence,
  }) async {
    await _db.collection('results').add({
      'label': label,
      'confidence': confidence,
      'created_at': Timestamp.now(),
    });
  }
}