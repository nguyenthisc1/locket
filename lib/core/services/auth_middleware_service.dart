import 'package:get_it/get_it.dart';
import 'package:locket/core/services/token_service.dart';
import 'package:locket/data/auth/repositories/token_store_impl.dart';

class AuthMiddlewareService {
  static final AuthMiddlewareService _instance = AuthMiddlewareService._internal();
  factory AuthMiddlewareService() => _instance;
  AuthMiddlewareService._internal();

  final TokenService _tokenService = TokenService();
  final TokenStorageImpl _tokenStorage = GetIt.instance<TokenStorageImpl>();

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      // Check both token service and secure storage
      final hasToken = await _tokenService.isAuthenticated();
      final secureToken = await _tokenStorage.read();
      
      return hasToken || secureToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Get the appropriate initial route based on auth state
  Future<String> getInitialRoute() async {
    final isAuth = await isAuthenticated();
    return isAuth ? '/home' : '/onboarding';
  }

  /// Check if a route requires authentication
  bool requiresAuth(String route) {
    final protectedRoutes = [
      '/home',
      '/converstion',
      '/converstion:id',
      '/profile',
      '/settings',
    ];
    
    return protectedRoutes.any((protectedRoute) {
      // Handle dynamic routes like '/converstion:id'
      if (protectedRoute.contains(':')) {
        final pattern = protectedRoute.replaceAll(':id', r'\d+');
        return RegExp(pattern).hasMatch(route);
      }
      return route == protectedRoute;
    });
  }

  /// Check if a route is auth-only (login/signup pages)
  bool isAuthOnlyRoute(String route) {
    final authOnlyRoutes = [
      '/onboarding',
      '/login',
      '/signup',
      '/email-login',
      '/phone-login',
    ];
    return authOnlyRoutes.contains(route);
  }

  /// Redirect to appropriate page based on auth state
  Future<String?> getRedirectRoute(String currentRoute) async {
    final isAuth = await isAuthenticated();
    
    // If user is authenticated but trying to access auth-only routes
    if (isAuth && isAuthOnlyRoute(currentRoute)) {
      return '/home';
    }
    
    // If user is not authenticated but trying to access protected routes
    if (!isAuth && requiresAuth(currentRoute)) {
      return '/onboarding';
    }
    
    // No redirect needed
    return null;
  }

  /// Clear auth data and redirect to login
  // Future<void> logout() async {
  //   await _tokenService.clearAuthData();
  //   await _tokenStorage.delete();
  // }
}