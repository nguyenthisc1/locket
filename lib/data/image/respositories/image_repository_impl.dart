import 'package:locket/domain/image/repositories/image_repository.dart';
import 'package:locket/core/network/firebase_client.dart';

class ImageRepositoryImpl extends ImageRepository {
  final FirebaseClient _client;

  ImageRepositoryImpl(this._client);

  @override
  Future<void> uploadImageData(Map<String, dynamic> data) {
    return _client.create('images', data);
  }

  @override
  Future<List<Map<String, dynamic>>> getImages() async {
    final snapshot = await _client.readAll('images');
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
