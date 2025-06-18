// firebase_client.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseClient {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> create(String collection, Map<String, dynamic> data) {
    return _firestore.collection(collection).add(data);
  }

  Future<void> update(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> delete(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  Future<QuerySnapshot> readAll(String collection) {
    return _firestore.collection(collection).get();
  }

  Future<String> uploadImage(
    String path,
    String fileName,
    Uint8List fileBytes,
  ) async {
    final ref = _storage.ref().child('$path/$fileName');
    final result = await ref.putData(fileBytes);
    return await result.ref.getDownloadURL();
  }
}
