import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<Either<Failure, BaseResponse>> call({
    required String identifier,
    required String password,
  }) async {
    return await _authRepository.login(
      identifier: identifier,
      password: password,
    );
  }
}
