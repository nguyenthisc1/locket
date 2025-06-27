import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

/// Use case for refreshing authentication tokens
class RefreshTokenUseCase {
  final AuthRepository _authRepository;

  RefreshTokenUseCase(this._authRepository);

  Future<Either<Failure, String>> call() async {
    return await _authRepository.refreshToken();
  }
}

/// Use case for checking if the current token is expired
class IsTokenExpiredUseCase {
  final AuthRepository _authRepository;

  IsTokenExpiredUseCase(this._authRepository);

  Future<Either<Failure, bool>> call() async {
    return await _authRepository.isTokenExpired();
  }
}
