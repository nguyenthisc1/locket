import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, BaseResponse>> login({
    required String identifier,
    required String password,
  });
  Future<void> logout();


}
