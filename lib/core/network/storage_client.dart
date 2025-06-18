import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageClient {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _basePath = 'uploads/';

  // Upload a file to Firebase Storage
  Future<String> uploadFile(File file, {String? customPath}) async {
    try {
      final String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          file.path.split('/').last;
      final String path = customPath ?? _basePath + fileName;

      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload an image from ImagePicker
  Future<String> uploadImage(XFile image, {String? customPath}) async {
    return uploadFile(File(image.path), customPath: customPath);
  }

  // Download a file from Firebase Storage
  Future<File> downloadFile(String downloadUrl, String localPath) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final File file = File(localPath);

      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // List files in a directory
  Future<List<String>> listFiles({String? directory}) async {
    try {
      final String path = directory ?? _basePath;
      final ListResult result = await _storage.ref().child(path).listAll();

      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
