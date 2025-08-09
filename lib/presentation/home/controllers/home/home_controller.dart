import 'package:flutter/material.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';
import 'package:locket/presentation/home/controllers/home/home_controller_state.dart';
import 'package:logger/logger.dart';

/// Business logic controller for home page functionality
class HomeController {
  final HomeControllerState _state;
  final GetProfileUsecase _getProfileUsecase;
  final UserService _userService;
  final Logger _logger;
  final PageController _outerController;
  final PageController _innerController;

  HomeController({
    required HomeControllerState state,
    required GetProfileUsecase getProfileUsecase,
    required UserService userService,
    Logger? logger,
  })  : _state = state,
        _getProfileUsecase = getProfileUsecase,
        _userService = userService,
        _logger = logger ?? Logger(printer: PrettyPrinter(colors: true, printEmojis: true)),
        _outerController = PageController(),
        _innerController = PageController() {
    _outerController.addListener(_outerPageListener);
  }

  // Getters for external access
  HomeControllerState get state => _state;
  PageController get outerController => _outerController;
  PageController get innerController => _innerController;

  /// Initialize home functionality
  Future<void> init() async {
    await _initializeUser();
  }

  /// Handle outer page view scroll changes
  void _outerPageListener() {
    final int newPage = _outerController.hasClients 
        ? _outerController.page?.round() ?? 0 
        : 0;

    if (newPage != _state.currentOuterPage) {
      // Update feed entry state
      if (_state.currentOuterPage == 0 && newPage == 1) {
        _state.setEnteredFeed(true);
      }

      if (_state.currentOuterPage == 1 && newPage == 0) {
        _state.setEnteredFeed(false);
      }

      _state.setCurrentOuterPage(newPage);
    }
  }

  /// Navigate to specific page in outer page view
  void handleScrollPageViewOuter(int page) {
    if (_outerController.hasClients) {
      _outerController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Initialize user profile
  Future<void> _initializeUser() async {
    _logger.d('Initializing user - Profile fetched: ${_state.hasProfileFetched}');

    if (_state.hasProfileFetched) {
      return;
    }

    try {
      // Load cached user data first
      await _userService.loadUserFromStorage();

      // If we have cached user data, show it immediately
      if (_userService.isLoggedIn) {
        _state.setLoadingProfile(false);
      }

      // Fetch fresh data from API (only once)
      await _fetchProfile();
    } catch (e) {
      _logger.e('Error initializing user: $e');
      _state.setError('Failed to initialize user');
      _state.setLoadingProfile(false);
    }
  }

  /// Fetch user profile from API
  Future<void> _fetchProfile() async {
    // Don't fetch if already fetched
    if (_state.hasProfileFetched) {
      return;
    }

    try {
      final result = await _getProfileUsecase.call();

      result.fold(
        (failure) {
          _logger.e('Failed to fetch profile: ${failure.message}');

          // If API fails and no cached user, set error for navigation handling
          if (!_userService.isLoggedIn) {
            _state.setError('Authentication required');
            _logger.d('No cached user data and API failed - should redirect to login');
          }
        },
        (response) {
          _logger.d('Profile fetched successfully');
          _state.setProfileFetched(true);
          _state.clearError();
        },
      );
    } catch (e) {
      _logger.e('Error fetching profile: $e');
      _state.setError('Network error occurred');

      // If there's an exception and no cached user, it's a critical error
      if (!_userService.isLoggedIn) {
        _logger.e('Critical error: No user data available');
      }
    } finally {
      _state.setLoadingProfile(false);
    }
  }

  /// Manually refresh profile (useful for pull-to-refresh scenarios)
  Future<void> refreshProfile() async {
    _state.setProfileFetched(false); // Reset the flag to allow re-fetching
    _state.setLoadingProfile(true);
    _state.clearError();

    await _fetchProfile();
  }

  /// Reset the controller state (useful when logging out)
  void resetState() {
    _state.reset();
  }

  /// Check if user should be redirected to login
  bool shouldRedirectToLogin() {
    return !_state.isLoadingProfile && 
           _state.hasProfileFetched && 
           !_userService.isLoggedIn;
  }

  /// Dispose resources
  void dispose() {
    _outerController.removeListener(_outerPageListener);
    _outerController.dispose();
    _innerController.dispose();
  }
}