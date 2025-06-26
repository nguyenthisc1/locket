import 'package:dartz/dartz.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';

import '../../../core/error/failures.dart';

class EmailLoginUseCase {
  final AuthFirebaseRepository authFirebaseRepository;

  EmailLoginUseCase(this.authFirebaseRepository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    return authFirebaseRepository.signInWithEmailAndPassword(email, password);
  }
}
