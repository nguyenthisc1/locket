import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Either<Failure, UserEntity>> call({
    required String identifier,
    required String password,
  }) async {
    return await _authRepository.login(
      identifier: identifier,
      password: password,
    );
  }
}

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Either<Failure, UserEntity>> call() async {
    return await _authRepository.logout();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await _authRepository.getCurrentUser();
  }
}

/// Use case for checking authentication status
class IsAuthenticatedUseCase {
  final AuthRepository _authRepository;

  IsAuthenticatedUseCase(this._authRepository);

  Future<Either<Failure, bool>> call() async {
    return await _authRepository.isAuthenticated();
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final AuthRepository _authRepository;

  UpdateUserProfileUseCase(this._authRepository);

  Future<Either<Failure, void>> call(UserEntity user) async {
    return await _authRepository.updateUserProfile(user);
  }
}

/// Use case for watching auth state changes
class WatchAuthStateUseCase {
  final AuthRepository _authRepository;

  WatchAuthStateUseCase(this._authRepository);

  Stream<Either<Failure, UserEntity?>> call() {
    return _authRepository.watchAuthState();
  }
}
