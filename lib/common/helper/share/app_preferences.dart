import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String firstLaunchKey = 'is_first_launch';

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(firstLaunchKey) ?? true;
    if (hasLaunched) {
      await prefs.setBool(firstLaunchKey, false); // Đánh dấu đã mở
    }
    return hasLaunched;
  }
}
