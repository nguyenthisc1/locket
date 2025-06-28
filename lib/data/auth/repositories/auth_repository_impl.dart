import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:logger/web.dart';

class AuthRepositoryImpl extends AuthRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  final AuthApiService _authApiService = AuthApiServiceImpl();

  // Auth state management
  UserEntity? _currentUser;
  final StreamController<Either<Failure, UserEntity?>> _authStateController =
      StreamController<Either<Failure, UserEntity?>>.broadcast();

  @override
  Future<Either<Failure, String>> getToken() async {
    final response = await _authApiService.getToken();

    return response.fold(
      (failure) {
        logger.e('get token failed: ${failure.toString()}');
        return Left(
          AuthFailure(message: 'get token failed: ${failure.toString()}'),
        );
      },
      (data) {
        logger.d('get token successful for: $data');
        return Right(data.toString());
      },
    );
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    final response = await _authApiService.refreshToken();

    return response.fold(
      (failure) {
        logger.e('refresh token failed: ${failure.toString()}');
        return Left(
          AuthFailure(message: 'refresh token failed: ${failure.toString()}'),
        );
      },
      (data) {
        logger.d('refresh token successful');
        return Right(data.toString());
      },
    );
  }

  @override
  Future<Either<Failure, bool>> isTokenExpired() async {
    final response = await _authApiService.isTokenExpired();

    return response.fold(
      (failure) {
        logger.e('token expiration check failed: ${failure.toString()}');
        return Left(
          AuthFailure(
            message: 'token expiration check failed: ${failure.toString()}',
          ),
        );
      },
      (isExpired) {
        logger.d('token expiration check: ${isExpired ? 'expired' : 'valid'}');
        return Right(isExpired);
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Check if we have a cached user
      if (_currentUser != null) {
        return Right(_currentUser);
      }

      // Check if user is authenticated
      final isAuthResult = await isAuthenticated();
      if (isAuthResult.isLeft() || !isAuthResult.getOrElse(() => false)) {
        return const Right(null);
      }

      // Fetch current user from API
      final response = await _authApiService.getCurrentUser();

      return response.fold(
        (failure) {
          logger.e('get current user failed: ${failure.toString()}');
          return Left(failure);
        },
        (user) {
          _currentUser = user;
          _emitAuthState(Right(user));
          logger.d('get current user successful: ${user.username}');
          return Right(user);
        },
      );
    } catch (e) {
      logger.e('get current user exception: $e');
      return Left(AuthFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      logger.d('AuthRepository - isAuthenticated: Starting');
      final tokenResult = await getToken();
      logger.d('AuthRepository - isAuthenticated: Token result: $tokenResult');

      return tokenResult.fold(
        (failure) {
          logger.e(
            'AuthRepository - isAuthenticated: Token failed, returning false',
          );
          return Right(false);
        },
        (token) {
          final hasToken = token.isNotEmpty;
          logger.d(
            'AuthRepository - isAuthenticated: Token length: ${token.length}, returning: $hasToken',
          );
          return Right(hasToken);
        },
      );
    } catch (e) {
      logger.e('AuthRepository - isAuthenticated: Exception: $e');
      return Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    final response = await _authApiService.updateUserProfile(user);

    return response.fold(
      (failure) {
        logger.e('update user profile failed: ${failure.toString()}');
        return Left(failure);
      },
      (updatedUser) {
        _currentUser = updatedUser;
        _emitAuthState(Right(updatedUser));
        logger.d('update user profile successful: ${updatedUser.username}');
        return const Right(null);
      },
    );
  }

  @override
  Stream<Either<Failure, UserEntity?>> watchAuthState() async* {
    logger.d('AuthRepository - watchAuthState: Starting');

    yield const Right(null);

    // Then check authentication status and emit the actual state
    try {
      final isAuthResult = await isAuthenticated();
      logger.d('AuthRepository - watchAuthState: Auth result: $isAuthResult');

      if (isAuthResult.isLeft()) {
        logger.e('AuthRepository - watchAuthState: Auth failed');
        yield Left(
          isAuthResult.fold(
            (failure) => failure,
            (success) => AuthFailure(message: 'Unexpected success'),
          ),
        );
        return;
      }

      final isUserAuthenticated = isAuthResult.getOrElse(() => false);

      if (!isUserAuthenticated) {
        logger.e(
          'AuthRepository - watchAuthState: Not authenticated, emitting null',
        );
        yield const Right(null);
        return;
      }

      // If authenticated, try to get current user
      final userResult = await getCurrentUser();
      logger.d('AuthRepository - watchAuthState: User result: $userResult');

      if (userResult.isLeft()) {
        logger.e('AuthRepository - watchAuthState: Get user failed');
        yield Left(
          userResult.fold(
            (failure) => failure,
            (user) => AuthFailure(message: 'Unexpected user'),
          ),
        );
        return;
      }

      final user = userResult.getOrElse(() => null);
      logger.d(
        'AuthRepository - watchAuthState: Emitting user: ${user?.username}',
      );
      yield Right(user);
    } catch (e) {
      logger.e('AuthRepository - watchAuthState: Exception: $e');
      yield Left(AuthFailure(message: 'Failed to check auth state: $e'));
    }

    logger.d('AuthRepository - watchAuthState: Continuing with stream updates');
    // Continue listening to the stream for updates
    yield* _authStateController.stream;
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _authApiService.login(
      identifier: identifier,
      password: password,
    );

    return response.fold(
      (failure) {
        logger.e('Login failed: ${failure.toString()}');
        return Left(
          AuthFailure(message: 'Login failed: ${failure.toString()}'),
        );
      },
      (user) {
        _currentUser = user;
        _emitAuthState(Right(user));
        logger.d('Login successful for: ${user.username}');
        return Right(user);
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> logout() async {
    try {
      await _authApiService.logout();

      // Clear current user and emit auth state
      _currentUser = null;
      _emitAuthState(const Right(null));

      return Right(
        UserEntity(id: '', username: '', email: null, phoneNumber: null),
      );
    } catch (e) {
      logger.e('Logout exception: $e');
      return Left(AuthFailure(message: 'Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup() {
    // TODO: implement signup
    throw UnimplementedError();
  }

  // Private methods for auth state management
  void _emitCurrentAuthState() {
    _emitAuthState(Right(_currentUser));
  }

  void _emitAuthState(Either<Failure, UserEntity?> state) {
    if (!_authStateController.isClosed) {
      _authStateController.add(state);
    }
  }

  // Cleanup method
  void dispose() {
    _authStateController.close();
  }
}
