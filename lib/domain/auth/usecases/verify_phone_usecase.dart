import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';

class VerifyPhoneUsecase {
  final AuthFirebaseRepository authFirebaseRepository;

  VerifyPhoneUsecase(this.authFirebaseRepository);

  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await authFirebaseRepository.verifyPhone(phoneNumber);
  }
}
