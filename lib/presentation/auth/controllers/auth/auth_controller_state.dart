import 'package:flutter/material.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

/// Pure state class for authentication - only holds data, no business logic
class AuthControllerState extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  UserEntity? _currentUser;
  bool _obscurePassword = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get obscurePassword => _obscurePassword;

  // State update methods (no business logic)
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }

  void setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  void setCurrentUser(UserEntity? user) {
    _currentUser = user;
    _isLoggedIn = user != null;
    notifyListeners();
  }

  void setObscurePassword(bool value) {
    if (_obscurePassword != value) {
      _obscurePassword = value;
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
    _isLoggedIn = false;
    _errorMessage = null;
    _currentUser = null;
    _obscurePassword = true;
    notifyListeners();
  }
}
