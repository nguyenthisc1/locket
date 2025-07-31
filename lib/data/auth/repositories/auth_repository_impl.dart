import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:logger/logger.dart';

class AuthRepositoryImpl extends AuthRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _authApiService.login(
      identifier: identifier,
      password: password,
    );

    return result.fold(
      (failure) {
        logger.e('Login failed: ${failure.toString()}');

        return Left(AuthFailure(message: failure.toString()));
      },
      (data) {
        logger.d('Login successful for: ${data.email}');
        return Right(data);
      },
    );
  }

  @override
  Future<void> logout() async {
    await _authApiService.logout();
  }
}
