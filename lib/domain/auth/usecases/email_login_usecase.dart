import 'package:dartz/dartz.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

import '../../../core/error/failures.dart';

class EmailLoginUseCase {
  final AuthRepository authRepository;

  EmailLoginUseCase(this.authRepository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return Left(AuthFailure(message: 'Email and password cannot be empty'));
    }

    try {
      final user = await authRepository.signInWithEmailAndPassword(
        email.trim(),
        password.trim(),
      );
      return Right(user);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(AuthFailure(message: 'Đăng nhập thất bại'));
    }
  }
}
