import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:logger/logger.dart';

class AuthRepositoryImpl extends AuthRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<Either<Failure, BaseResponse<Map<String, dynamic>>>> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _authApiService.login(
      identifier: identifier,
      password: password,
    );

    return result.fold(
      (failure) {
        logger.e('Repository Login failed: ${failure.toString()}');
        return Left(failure);
      },
      (data) {
        logger.d('Repository Login successful for: ${data.data?['user']}');
        return Right(data);
      },
    );
  }

  @override
  Future<void> logout() async {
    await _authApiService.logout();
  }
}
