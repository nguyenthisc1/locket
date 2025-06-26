import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';

class EmailLinkLoginUsecase {
  final AuthFirebaseRepository authFirebaseRepository;

  EmailLinkLoginUsecase(this.authFirebaseRepository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String emailLink,
  ) async {
    return authFirebaseRepository.signInWithEmailLink(email, emailLink);
  }
}
