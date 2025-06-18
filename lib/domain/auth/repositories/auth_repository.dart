import 'package:locket/domain/auth/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile({String? displayName, String? photoURL});
  Future<void> updateUserEmail(String newEmail);
  Future<void> updateUserPassword(String newPassword);
  Future<void> deleteAccount();
}
