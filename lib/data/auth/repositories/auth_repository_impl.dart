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
      (data) {
        logger.d('Login successful for: $data');
        return Right(data);
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> logout() async {
    try {
      await _authApiService.logout();

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
}
