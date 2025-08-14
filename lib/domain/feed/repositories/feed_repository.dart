import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

abstract class FeedRepository {
  Future<Either<Failure, BaseResponse>> getFeed(Map<String, dynamic> query);
  Future<Either<Failure, BaseResponse>> uploadFeed(Map<String, dynamic> payload);
}
