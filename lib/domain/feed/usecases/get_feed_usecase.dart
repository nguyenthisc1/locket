import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/feed/repositories/feed_repository.dart';

class GetFeedUsecase {
    final FeedRepository _feedRepository;

  GetFeedUsecase(this._feedRepository);

  Future<Either<Failure, BaseResponse>> call(Map<String, dynamic> query) async {
    return await _feedRepository.getFeed(query);
  }
}