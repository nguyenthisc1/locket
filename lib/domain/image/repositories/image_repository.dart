abstract class ImageRepository {
  Future<void> uploadImageData(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getImages();
}
