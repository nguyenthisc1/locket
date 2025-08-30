import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/feed/repositories/feed_repository.dart';

class GetFeedsUsecase {
  final FeedRepository _feedRepository;

  GetFeedsUsecase(this._feedRepository);

  Future<Either<Failure, BaseResponse>> call({
    String? query,
    DateTime? lastCreatedAt,
    int? limit,
  }) async {
    return await _feedRepository.getFeeds(
      query: query,
      lastCreatedAt: lastCreatedAt,
      limit: limit,
    );
  }
}
