import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

abstract class UserRepository {
  Future<Either<Failure, BaseResponse>> getProfile();
  Future<void> logout();


}
