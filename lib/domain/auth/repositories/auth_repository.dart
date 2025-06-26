import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signup();
  Future<Either<Failure, UserEntity>> logout();
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  });
  Future<Either<Failure, String>> getToken();
}
