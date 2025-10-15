import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/media/repositories/media_repository.dart';

class MediaUploadFeedUsecase {
  final MediaRepository _mediaRepository;

  MediaUploadFeedUsecase(this._mediaRepository);

  Future<Either<Failure, BaseResponse>> call(
    Map<String, dynamic> payload,
  ) async {
    return await _mediaRepository.uploadFeed(payload);
  }
}
