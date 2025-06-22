import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<Either<Failure, UserEntity?>> get authStateChanges;
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signInWithEmailLink(
    String email,
    String emailLink,
  );
  Future<Either<Failure, void>> sendEmailLink(String email);
  Future<Either<Failure, UserEntity>> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, String>> verifyPhone(String phoneNumber);
  Future<Either<Failure, UserEntity>> signInWithPhone(
    String phoneNumber,
    String verificationId,
    String smsCode,
  );
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  });
  Future<Either<Failure, void>> updateUserEmail(String newEmail);
  Future<Either<Failure, void>> updateUserPassword(String newPassword);
  Future<Either<Failure, void>> deleteAccount();
}
