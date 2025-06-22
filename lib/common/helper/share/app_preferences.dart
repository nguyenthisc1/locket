import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String firstLaunchKey = 'is_first_launch';
  static const String emailForSignIn = 'email_for_sign_in';

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(firstLaunchKey) ?? true;
    if (hasLaunched) {
      await prefs.setBool(firstLaunchKey, false); // Đánh dấu đã mở
    }
    return hasLaunched;
  }

  Future<String?> getEmailForSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailForSignIn);
  }

  Future<void> setEmailForSignIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(emailForSignIn, email);
  }
}
