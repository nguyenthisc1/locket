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
  Future<Either<Failure, String>> refreshToken();
  Future<Either<Failure, bool>> isTokenExpired();

  // Current user management
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);

  // Auth state stream
  Stream<Either<Failure, UserEntity?>> watchAuthState();
}
