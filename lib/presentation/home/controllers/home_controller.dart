import 'package:flutter/material.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/user/repositories/user_repository_impl.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';

class HomeControllerState extends ChangeNotifier {
  final PageController outerController = PageController();
  final PageController innerController = PageController();

  static List<String> get _galleryImages =>
      List.generate(50, (i) => 'https://picsum.photos/seed/$i/300/300');

  int _currentOuterPage = 0;
  bool _enteredFeed = false;
  bool _isLoadingProfile = true;
  bool _hasProfileFetched = false; // Flag to ensure profile is fetched only once

  // Getters
  int get currentOuterPage => _currentOuterPage;
  bool get enteredFeed => _enteredFeed;
  List<String> get gallery => _galleryImages;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get hasProfileFetched => _hasProfileFetched;

  void init() {
    outerController.addListener(_outerPageListener);
    _initializeUser();
  }

  void _outerPageListener() {
    final int newPage =
        outerController.hasClients ? outerController.page?.round() ?? 0 : 0;

    if (newPage != _currentOuterPage) {
      if (_currentOuterPage == 0 && newPage == 1) {
        _enteredFeed = true;
        notifyListeners();
      }

      if (_currentOuterPage == 1 && newPage == 0) {
        _enteredFeed = false;
        notifyListeners();
      }

      _currentOuterPage = newPage;
    }
  }

  void handleScrollPageViewOuter(int page) {
    if (outerController.hasClients) {
      outerController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _initializeUser() async {
    // Only initialize if not already done
    if (_hasProfileFetched) {
      return;
    }

    final userService = getIt<UserService>();
    
    try {
      // Load cached user data first
      await userService.loadUserFromStorage();
      
      // If we have cached user data, show it immediately
      if (userService.isLoggedIn) {
        _isLoadingProfile = false;
        notifyListeners();
      }
      
      // Fetch fresh data from API (only once)
      await _fetchProfile();
    } catch (e) {
      print('Error initializing user: $e');
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProfile() async {
    // Don't fetch if already fetched
    if (_hasProfileFetched) {
      return;
    }

    try {
      final userRepository = getIt<UserRepositoryImpl>();
      final getProfileUsecase = GetProfileUsecase(userRepository);
      
      final result = await getProfileUsecase();
      
      result.fold(
        (failure) {
          print('Failed to fetch profile: ${failure.message}');
          
          // If API fails and no cached user, redirect to login
          final userService = getIt<UserService>();
          if (!userService.isLoggedIn) {
            // Note: Navigation should be handled by the calling widget
            print('No cached user data and API failed - should redirect to login');
          }
        },
        (response) {
          print('Profile fetched successfully');
          _hasProfileFetched = true; // Mark as fetched successfully
        },
      );
    } catch (e) {
      print('Error fetching profile: $e');
      
      // If there's an exception and no cached user, it's a critical error
      final userService = getIt<UserService>();
      if (!userService.isLoggedIn) {
        print('Critical error: No user data available');
      }
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Manually refresh profile (useful for pull-to-refresh scenarios)
  Future<void> refreshProfile() async {
    _hasProfileFetched = false; // Reset the flag to allow re-fetching
    _isLoadingProfile = true;
    notifyListeners();
    
    await _fetchProfile();
  }

  /// Reset the controller state (useful when logging out)
  void resetState() {
    _hasProfileFetched = false;
    _isLoadingProfile = true;
    _currentOuterPage = 0;
    _enteredFeed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    outerController.removeListener(_outerPageListener);
    outerController.dispose();
    innerController.dispose();
    super.dispose();
  }
}
