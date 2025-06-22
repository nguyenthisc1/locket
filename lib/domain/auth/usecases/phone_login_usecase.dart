import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class PhoneLoginUsecase {
  final AuthRepository authRepository;

  PhoneLoginUsecase(this.authRepository);

  Future<Either<Failure, UserEntity>> call(
    String phoneNumber,
    String verificationId,
    String smsCode,
  ) {
    return authRepository.signInWithPhone(phoneNumber, verificationId, smsCode);
  }
}
