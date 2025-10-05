// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/core/services/token_validation_service.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';
import 'package:locket/presentation/auth/pages/phone_login_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_detail_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_page.dart';
import 'package:locket/presentation/home/pages/gallery_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';
import 'package:locket/presentation/splash/pages/splash_page.dart';
import 'package:logging/logging.dart';
import 'package:logger/logger.dart' as logger;

// Global RouteObserver for GoRouter
final RouteObserver<ModalRoute> goRouterObserver = RouteObserver<ModalRoute>();

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();
  static final Middleware _middleware = getIt<Middleware>();
  static final TokenValidationService _tokenValidationService = getIt<TokenValidationService>();
  static final logger.Logger _logger = logger.Logger(
    printer: logger.PrettyPrinter(colors: true, printEmojis: true),
  );

  final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routerNeglect: false,
    debugLogDiagnostics: true,
    observers: [
      NavObserver(),
      goRouterObserver, // Add this for RouteAware support
    ],
    redirect: (context, state) async {
      try {
        _logger.d('🧭 Router redirect called for: ${state.fullPath}');
        
        // Get token info for debugging
        final tokenInfo = await _tokenValidationService.getTokenInfo();
        _logger.d('🔍 Token status: ${tokenInfo['status']}');
        
        final redirectPath = await _middleware.routeMiddleware(state);
        
        if (redirectPath != null) {
          _logger.d('🔄 Redirecting from ${state.fullPath} to $redirectPath');
        } else {
          _logger.d('✅ No redirect needed for ${state.fullPath}');
        }
        
        return redirectPath;
      } catch (e) {
        _logger.e('❌ Error in router redirect: $e');
        
        // Clear potentially corrupted tokens on router error
        try {
          await _middleware.clearTokens();
          _logger.d('🗑️ Cleared tokens due to router error');
        } catch (clearError) {
          _logger.e('❌ Failed to clear tokens: $clearError');
        }
        
        return '/email-login';
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/email-login',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),

      // GoRoute(
      //   path: '/gallery',
      //   pageBuilder: (context, state) {
      //     final extra = state.extra as Map;
      //     final controller = extra['controller'] as FeedController;

      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       transitionsBuilder: (
      //         context,
      //         animation,
      //         secondaryAnimation,
      //         child,
      //       ) {
      //         return FadeTransition(
      //           opacity: CurvedAnimation(
      //             parent: animation,
      //             curve: Curves.easeInOut,
      //             reverseCurve: Curves.easeInOut,
      //           ),
      //           child: child,
      //         );
      //       },
      //       // Provide the FeedController, not the state
      //       child: Provider<FeedController>.value(
      //         value: controller,
      //         child: GalleryPage(),
      //       ),
      //     );
      //   },
      // ),
      GoRoute(
        path: '/gallery',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                  reverseCurve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            child: GalleryPage(),
          );
        },
      ),
      GoRoute(
        path: '/conversation',
        builder: (context, state) => ConversationPage(),
      ),
      GoRoute(
        path: '/converstion/:id',
        builder: (context, state) {
          final conversationId = state.extra as String? ?? '';
          return ConversationDetailPage(conversationId: conversationId);
        },
      ),
    ],
  );

  /// Handle token expiration by clearing tokens and redirecting to onboarding
  static Future<void> handleTokenExpiration() async {
    try {
      _logger.w('⚠️ Handling token expiration...');
      
      // Clear expired tokens
      await _middleware.clearTokens();
      
      // Navigate to onboarding
      instance.router.go('/onboarding');
      
      _logger.d('✅ Token expiration handled successfully');
    } catch (e) {
      _logger.e('❌ Error handling token expiration: $e');
    }
  }

  /// Get current token information for debugging
  static Future<Map<String, dynamic>> getTokenInfo() async {
    return await _tokenValidationService.getTokenInfo();
  }
}

/// Custom NavigatorObserver for logging navigation events.
class NavObserver extends NavigatorObserver {
  NavObserver() {
    log.onRecord.listen((e) => debugPrint('$e'));
  }

  final log = Logger('NavObserver');
  final logger.Logger _logger = logger.Logger(
    printer: logger.PrettyPrinter(colors: true, printEmojis: true),
  );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.info('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');
    _logger.d('🚀 Navigation: didPush ${route.str}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.info('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');
    _logger.d('⬅️ Navigation: didPop ${route.str}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.info('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');
    _logger.d('🗑️ Navigation: didRemove ${route.str}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    log.info('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');
    _logger.d('🔄 Navigation: didReplace ${newRoute?.str}');
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    log.info(
      'didStartUserGesture: ${route.str}, '
      'previousRoute= ${previousRoute?.str}',
    );
    _logger.d('👆 Navigation: didStartUserGesture ${route.str}');
  }

  @override
  void didStopUserGesture() {
    log.info('didStopUserGesture');
    _logger.d('🛑 Navigation: didStopUserGesture');
  }
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
