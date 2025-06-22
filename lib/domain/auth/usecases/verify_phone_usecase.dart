import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class VerifyPhoneUsecase {
  final AuthRepository authRepository;

  VerifyPhoneUsecase(this.authRepository);

  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await authRepository.verifyPhone(phoneNumber);
  }
}
