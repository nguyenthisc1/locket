import 'package:locket/core/services/user_service.dart';
import 'package:locket/domain/user/entities/user_profile_entity.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';
import 'package:locket/presentation/user/controllers/user/user_controller_state.dart';
import 'package:logger/logger.dart';

/// Business logic controller for user profile management
class UserController {
  final UserControllerState _state;
  final GetProfileUsecase _getProfileUsecase;
  final UserService _userService;
  final Logger _logger;

  UserController({
    required UserControllerState state,
    required GetProfileUsecase getProfileUsecase,
    required UserService userService,
    Logger? logger,
  }) : _state = state,
       _getProfileUsecase = getProfileUsecase,
       _userService = userService,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

  // Getters for external access
  UserControllerState get state => _state;

  /// Initialize user profile
  Future<void> init() async {
    if (_state.hasInitialized) {
      return;
    }

    // Load cached user first
    await _loadCachedUser();

    // Then fetch fresh profile
    await fetchProfile();
    _state.setInitialized(true);
  }

  /// Load cached user data
  Future<void> _loadCachedUser() async {
    try {
      await _userService.loadUserFromStorage();
      if (_userService.currentUser != null) {
        // Convert UserProfileModel to UserProfileEntity if needed
        _logger.d('Loaded cached user: ${_userService.currentUser?.email}');
      }
    } catch (e) {
      _logger.e('Error loading cached user: $e');
    }
  }

  /// Fetch user profile from API
  Future<void> fetchProfile({bool isRefresh = false}) async {
    if (isRefresh) {
      _state.setRefreshing(true);
    } else {
      _state.setLoading(true);
    }
    _state.clearError();

    try {
      final result = await _getProfileUsecase.call();

      result.fold(
        (failure) {
          _logger.e('Failed to fetch profile: ${failure.message}');
          _state.setError(failure.message);
        },
        (response) {
          _logger.d('Profile fetched successfully');
          _state.clearError();
          // Handle profile data here
        },
      );
    } catch (e) {
      _logger.e('Error fetching profile: $e');
      _state.setError('An unexpected error occurred');
    } finally {
      _state.setLoading(false);
      _state.setRefreshing(false);
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    await fetchProfile(isRefresh: true);
  }

  /// Update user profile
  Future<bool> updateProfile(UserProfileEntity updatedProfile) async {
    _state.setLoading(true);
    _state.clearError();

    try {
      // Add update profile use case call here
      _state.setUserProfile(updatedProfile);
      _logger.d('Profile updated successfully');
      return true;
    } catch (e) {
      _logger.e('Error updating profile: $e');
      _state.setError('Failed to update profile');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  /// Clear user data
  Future<void> clearProfile() async {
    await _userService.clearUser();
    _state.reset();
  }
}
