import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/feed/services/feed_api_service.dart';
import 'package:locket/domain/feed/repositories/feed_repository.dart';
import 'package:logger/logger.dart';

class FeedRepositoryImpl extends FeedRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final FeedApiService _feedApiService;

  FeedRepositoryImpl(this._feedApiService);

  @override
  Future<Either<Failure, BaseResponse>> getFeed(
    Map<String, dynamic> query,
  ) async {
    final result = await _feedApiService.getFeed(query);

    return result.fold(
      (failure) {
        logger.e('Repository Get Feed failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Get Feed successful for: ${result.data}');
        return Right(result);
      },
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> uploadFeed(
    Map<String, dynamic> payload,
  ) async {
    final result = await _feedApiService.uploadFeed(payload);

    return result.fold(
      (failure) {
        logger.e('Repository Upload Feed failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Upload Feed successful for: ${result.data}');
        return Right(result);
      },
    );
  }

  // @override
  // Future<Either<Failure, void>> refreshFeed() {
  //   // TODO: implement refreshFeed
  //   throw UnimplementedError();
  // }
}
