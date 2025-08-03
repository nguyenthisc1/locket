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

  // Getters
  int get currentOuterPage => _currentOuterPage;
  bool get enteredFeed => _enteredFeed;
  List<String> get gallery => _galleryImages;
  bool get isLoadingProfile => _isLoadingProfile;

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
    final userService = getIt<UserService>();
    
    // Load cached user data first
    await userService.loadUserFromStorage();
    
    if (userService.isLoggedIn) {
      _isLoadingProfile = false;
      notifyListeners();
    }
    
    // Fetch fresh data
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userRepository = getIt<UserRepositoryImpl>();
      final getProfileUsecase = GetProfileUsecase(userRepository);
      
      final result = await getProfileUsecase();
      
      result.fold(
        (failure) {
          print('Failed to fetch profile: ${failure.message}');
        },
        (response) {
          print('Profile fetched successfully');
        },
      );
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    outerController.removeListener(_outerPageListener);
    outerController.dispose();
    innerController.dispose();
    super.dispose();
  }
}
