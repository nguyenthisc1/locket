import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class EmailLinkLoginUsecase {
  final AuthRepository authRepository;

  EmailLinkLoginUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String emailLink,
  ) async {
    return authRepository.signInWithEmailLink(email, emailLink);
  }
}
