import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/media/entities/media_feed_entity.dart';
import 'package:locket/domain/media/usecases/media_upload_usecase.dart';
import 'package:logger/logger.dart';

class MediaService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  final MediaUploadFeedUsecase _uploadFeedUsecase;

  MediaService(this._uploadFeedUsecase);

  Future<BaseResponse> uploadMediaFeed(Map<String, dynamic> payload) async {
    _logger.d('📤 Starting media upload: $payload');

    // Validate required fields
    if (!payload.containsKey('filePath') ||
        !payload.containsKey('fileName') ||
        !payload.containsKey('mediaType')) {
      throw ValidationFailure(
        message: 'Missing required fields: filePath, fileName, mediaType',
      );
    }

    final result = await _uploadFeedUsecase(payload);

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null);
      _logger.e('❌ Media upload failed: ${failure.toString()}');
      throw failure ?? Exception('Media upload failed');
    }

    final baseResponse = result.fold((l) => null, (r) => r);

    _logger.d('✅ Media upload successful: ${baseResponse?.data}');
    if (baseResponse?.data == null || baseResponse!.data['media'] == null) {
      throw Exception('No media entity found in response');
    }
    return baseResponse;
  }
}
