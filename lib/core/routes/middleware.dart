import 'package:fresh_dio/fresh_dio.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/services/token_validation_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/di.dart';
import 'package:logger/logger.dart';

class Middleware {
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  final _tokenStorage = getIt<TokenStorage<AuthTokenPair>>();
  final _tokenValidationService = getIt<TokenValidationService>();

  Future<bool> _hasValidTokens() async {
    try {
      _logger.d('🔍 Middleware: Checking for valid tokens...');
      
      // Use TokenValidationService to check for valid, non-expired tokens
      final validTokens = await _tokenValidationService.getValidTokens();
      
      if (validTokens == null) {
        _logger.d('❌ No valid tokens found');
        return false;
      }
      
      // Log token status for debugging
      final tokenInfo = await _tokenValidationService.getTokenInfo();
      _logger.d('✅ Valid tokens found: ${tokenInfo['status']}');
      
      if (tokenInfo['access_token_remaining'] != null) {
        _logger.d('⏰ Access token expires in: ${tokenInfo['access_token_remaining']} minutes');
      }
      
      return true;
    } catch (e) {
      _logger.e('❌ Error checking tokens: $e');
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
      final path = state.fullPath ?? '/email-login';
      // _logger.d('Middleware checking path: $path ${state.path}');
      // _logger.d('Is public route: ${_isPublicRoute(path)}');
      // _logger.d('Is protected route: ${_isProtectedRoute(path)}');

      final hasValidTokens = await _hasValidTokens();
      _logger.d('🔐 Has valid tokens: $hasValidTokens');

      if (_isPublicRoute(path)) {
        _logger.d('🌐 Public route accessed: $path');
        return null;
      }

      if (!hasValidTokens) {
        _logger.d('🔒 Protected route accessed without valid tokens: $path');
        _logger.d('🔄 Redirecting to /email-login');
        return '/email-login';
      }

      if (hasValidTokens && _isAuthOnlyRoute(path)) {
        _logger.d('✅ Authenticated user accessing auth page: $path');
        _logger.d('🏠 Redirecting to /home');
        return '/home';
      }

      _logger.d('✅ Route access granted: $path');
      return null;
    } catch (e) {
      _logger.e('Error in middleware: $e');
      return '/email-login';
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
      _logger.d('🗑️ Tokens cleared successfully');
    } catch (e) {
      _logger.e('❌ Error clearing tokens: $e');
    }
  }

  Future<AuthTokenPair?> getCurrentTokens() async {
    try {
      // Use token validation service to get valid tokens only
      return await _tokenValidationService.getValidTokens();
    } catch (e) {
      _logger.e('❌ Error getting current tokens: $e');
      return null;
    }
  }

  /// Get detailed token information for debugging
  Future<Map<String, dynamic>> getTokenInfo() async {
    return await _tokenValidationService.getTokenInfo();
  }
}