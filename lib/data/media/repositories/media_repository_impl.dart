import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/media/services/media_api_service.dart';
import 'package:locket/domain/media/repositories/media_repository.dart';
import 'package:logger/logger.dart';

class MediaRepositoryImpl extends MediaRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final MediaApiService _mediaApiService;

  MediaRepositoryImpl(this._mediaApiService);

  @override
  Future<Either<Failure, BaseResponse>> uploadFeed(
    Map<String, dynamic> payload,
  ) async {
    final result = await _mediaApiService.uploadFeed(payload);

    return result.fold(
      (failure) {
        logger.e('Upload Media Feed failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Upload Media Feed successful for: ${result.data}');
        return Right(result);
      },
    );
  }
}
