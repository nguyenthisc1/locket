import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:locket/data/user/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  UserProfileModel? _currentUser;

  UserProfileModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Sets the current user and persists the user to SharedPreferences.
  Future<void> setUser(UserProfileModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(user.toJson());
    await prefs.setString('currentUser', jsonStr);
    notifyListeners(); 
  }

  /// Loads the user from SharedPreferences, if present.
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('currentUser');
    if (jsonStr != null) {
      final json = jsonDecode(jsonStr);
      _currentUser = UserProfileModel.fromJson(json);
      notifyListeners(); 
    }
  }

  /// Clears the current user and removes the user from SharedPreferences.
  Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    notifyListeners();
  }
}
