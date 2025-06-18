import 'package:image_picker/image_picker.dart';
import 'storage_client.dart';

class StorageExample {
  final StorageClient _storageClient = StorageClient();
  final ImagePicker _imagePicker = ImagePicker();

  // Example: Upload an image from camera
  Future<String> uploadImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image == null) throw Exception('No image selected');

      return await _storageClient.uploadImage(image);
    } catch (e) {
      throw Exception('Failed to upload image from camera: $e');
    }
  }

  // Example: Upload an image from gallery
  Future<String> uploadImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) throw Exception('No image selected');

      return await _storageClient.uploadImage(image);
    } catch (e) {
      throw Exception('Failed to upload image from gallery: $e');
    }
  }

  // Example: List all uploaded images
  Future<List<String>> listUploadedImages() async {
    try {
      return await _storageClient.listFiles();
    } catch (e) {
      throw Exception('Failed to list images: $e');
    }
  }

  // Example: Delete an image
  Future<void> deleteImage(String downloadUrl) async {
    try {
      await _storageClient.deleteFile(downloadUrl);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
