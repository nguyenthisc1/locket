abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithPhone(String phoneNumber);
  Future<void> verifyOtp(String verificationId, String smsCode);
  Future<void> signOut();
}
