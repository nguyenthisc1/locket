import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/media/usecases/media_upload_usecase.dart';
import 'package:logger/logger.dart';

class MediaService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  
  final MediaUploadFeedUsecase _uploadFeedUsecase;

  MediaService(this._uploadFeedUsecase);

  /// Upload media feed (image or video) to the server
  /// 
  /// [payload] should contain:
  /// - filePath: String - Path to the media file
  /// - fileName: String - Name of the file
  /// - mediaType: String - 'image' or 'video'
  /// - isFrontCamera: bool - Whether the media was captured with front camera
  /// 
  /// Returns Either<Failure, BaseResponse> with upload result
  Future<Either<Failure, BaseResponse>> uploadMediaFeed(
    Map<String, dynamic> payload,
  ) async {
    try {
      _logger.d('📤 Starting media upload: ${payload['fileName']}');
      
      // Validate required fields
      if (!payload.containsKey('filePath') || 
          !payload.containsKey('fileName') || 
          !payload.containsKey('mediaType')) {
        return Left(ValidationFailure(
          message: 'Missing required fields: filePath, fileName, mediaType',
        ));
      }

      final result = await _uploadFeedUsecase(payload);
      
      return result.fold(
        (failure) {
          _logger.e('❌ Media upload failed: ${failure.toString()}');
          return Left(failure);
        },
        (response) {
          _logger.d('✅ Media upload successful: ${response.data}');
          return Right(response);
        },
      );
    } catch (e) {
      _logger.e('❌ Media upload error: ${e.toString()}');
      return Left(FeedFailure(message: e.toString()));
    }
  }
}
