import 'package:flutter/material.dart';
import 'package:locket/domain/user/entities/user_profile_entity.dart';

/// Pure state class for user profile - only holds data, no business logic
class UserControllerState extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  UserProfileEntity? _userProfile;
  bool _hasInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  UserProfileEntity? get userProfile => _userProfile;
  bool get hasInitialized => _hasInitialized;

  // State update methods (no business logic)
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setRefreshing(bool value) {
    if (_isRefreshing != value) {
      _isRefreshing = value;
      notifyListeners();
    }
  }

  void setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  void setUserProfile(UserProfileEntity? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void setInitialized(bool value) {
    if (_hasInitialized != value) {
      _hasInitialized = value;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    _userProfile = null;
    _hasInitialized = false;
    notifyListeners();
  }
}
