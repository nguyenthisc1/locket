import 'package:flutter/material.dart';

/// Pure state class for home - only holds data, no business logic
class HomeControllerState extends ChangeNotifier {
  // Private fields
  int _currentOuterPage = 0;
  bool _enteredFeed = false;
  bool _isLoadingProfile = true;
  bool _hasProfileFetched = false;
  String? _errorMessage;

  // Getters
  int get currentOuterPage => _currentOuterPage;
  bool get enteredFeed => _enteredFeed;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get hasProfileFetched => _hasProfileFetched;
  String? get errorMessage => _errorMessage;

  // State update methods (no business logic)
  void setCurrentOuterPage(int page) {
    if (_currentOuterPage != page) {
      _currentOuterPage = page;
      notifyListeners();
    }
  }

  void setEnteredFeed(bool value) {
    if (_enteredFeed != value) {
      _enteredFeed = value;
      notifyListeners();
    }
  }

  void setLoadingProfile(bool value) {
    if (_isLoadingProfile != value) {
      _isLoadingProfile = value;
      notifyListeners();
    }
  }

  void setProfileFetched(bool value) {
    if (_hasProfileFetched != value) {
      _hasProfileFetched = value;
      notifyListeners();
    }
  }

  void setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
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
    _currentOuterPage = 0;
    _enteredFeed = false;
    _isLoadingProfile = true;
    _hasProfileFetched = false;
    _errorMessage = null;
    notifyListeners();
  }
}