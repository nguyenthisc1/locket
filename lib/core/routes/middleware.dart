import 'package:fresh_dio/fresh_dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:logger/logger.dart';

class Middleware {
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  TokenStorage<AuthTokenPair> get _tokenStorage =>
      GetIt.instance<TokenStorage<AuthTokenPair>>();

  Future<bool> _hasValidTokens() async {
    try {
      _logger.d('Checking for tokens in storage...');
      final tokenPair = await _tokenStorage.read();

      if (tokenPair == null) {
        _logger.d('No tokens found in storage');
        return false;
      }

      final hasAccessToken = tokenPair.accessToken.isNotEmpty;
      final hasRefreshToken = tokenPair.refreshToken.isNotEmpty;

      _logger.d('Token check - Access: $hasAccessToken, Refresh: $hasRefreshToken');

      if (hasAccessToken && hasRefreshToken) {
        _logger.d('Access Token: ${tokenPair.accessToken.substring(0, 10)}...');
        _logger.d('Refresh Token: ${tokenPair.refreshToken.substring(0, 10)}...');
      }

      return hasAccessToken && hasRefreshToken;
    } catch (e) {
      _logger.e('Error checking tokens: $e');
      return false;
    }
  }

  bool _isPublicRoute(String path) {
    final publicRoutes = [
      '/',
      '/splashPage',
      '/onboarding',
      '/login',
      '/register',
      '/email-login',
      '/phone-login',
      '/verify-phone',
      '/email-link-verification',
    ];
    return publicRoutes.contains(path);
  }

  bool _isProtectedRoute(String path) {
    final protectedRoutes = [
      '/home',
      '/converstion',
      '/profile',
      '/settings',
      '/gallery',
      '/feed',
    ];

    if (protectedRoutes.contains(path)) return true;

    for (final protectedRoute in protectedRoutes) {
      if (protectedRoute.contains(':')) {
        final pattern = protectedRoute.replaceAll(':id', r'\\d+');
        if (RegExp(pattern).hasMatch(path)) return true;
      }
    }

    return false;
  }

  Future<String?> routeMiddleware(GoRouterState state) async {
    try {
      // print('state Go ${state.path}');
      final path = state.fullPath ?? '/onboarding';
      // _logger.d('Middleware checking path: $path ${state.path}');
      // _logger.d('Is public route: ${_isPublicRoute(path)}');
      // _logger.d('Is protected route: ${_isProtectedRoute(path)}');

      final hasValidTokens = await _hasValidTokens();
      // _logger.d('Has valid tokens: $hasValidTokens');

      if (_isPublicRoute(path)) {
        // _logger.d('Public route accessed: $path');
        return null;
      }

      if (_isProtectedRoute(path) && !hasValidTokens) {
        // _logger.d('Protected route accessed without tokens: $path');
        // _logger.d('Redirecting to /onboarding');
        return '/onboarding';
      }

      if (hasValidTokens && _isAuthOnlyRoute(path)) {
        // _logger.d('Authenticated user accessing auth page: $path');
        // _logger.d('Redirecting to /home');
        return '/home';
      }

      // _logger.d('Route access granted: $path');
      return null;
    } catch (e) {
      _logger.e('Error in middleware: $e');
      return '/onboarding';
    }
  }

  bool _isAuthOnlyRoute(String path) {
    final authOnlyRoutes = [
      '/onboarding',
      '/login',
      '/register',
      '/email-login',
      '/phone-login',
      '/verify-phone',
      '/email-link-verification',
    ];
    return authOnlyRoutes.contains(path);
  }

  Future<void> clearTokens() async {
    try {
      await _tokenStorage.delete();
      _logger.d('Tokens cleared successfully');
    } catch (e) {
      _logger.e('Error clearing tokens: $e');
    }
  }

  Future<AuthTokenPair?> getCurrentTokens() async {
    try {
      return await _tokenStorage.read();
    } catch (e) {
      _logger.e('Error getting current tokens: $e');
      return null;
    }
  }
}