import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';

class PhoneLoginUsecase {
  final AuthFirebaseRepository authFirebaseRepository;

  PhoneLoginUsecase(this.authFirebaseRepository);

  Future<Either<Failure, UserEntity>> call(
    String phoneNumber,
    String verificationId,
    String smsCode,
  ) {
    return authFirebaseRepository.signInWithPhone(
      phoneNumber,
      verificationId,
      smsCode,
    );
  }
}
