// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';
import 'package:locket/presentation/auth/pages/phone_login_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_detail_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_page.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller.dart';
import 'package:locket/presentation/home/pages/gallery_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';
import 'package:locket/presentation/splash/pages/splash_page.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// Global RouteObserver for GoRouter
final RouteObserver<ModalRoute> goRouterObserver = RouteObserver<ModalRoute>();

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();
  static final Middleware _middleware = getIt<Middleware>();

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
        final redirectPath = await _middleware.routeMiddleware(state);
        print('rediectPath: $redirectPath');
        return redirectPath;
      } catch (e) {
        print('❌ Error in router redirect: $e');
        return '/onboarding';
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/converstion',
        builder: (context, state) => ConversationPage(),
      ),
      GoRoute(
        path: '/gallery',
        pageBuilder: (context, state) {
          final extra = state.extra as Map;
          final controller = extra['controller'] as FeedController;

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
            // Provide the FeedController, not the state
            child: Provider<FeedController>.value(
              value: controller,
              child: GalleryPage(),
            ),
          );
        },
      ),
      GoRoute(
        path: '/converstion/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ConversationDetailPage(conversationId: id);
        },
      ),
    ],
  );
}

/// Custom NavigatorObserver for logging navigation events.
class NavObserver extends NavigatorObserver {
  NavObserver() {
    log.onRecord.listen((e) => debugPrint('$e'));
  }

  final log = Logger('NavObserver');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.info('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      log.info('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) => log.info(
    'didStartUserGesture: ${route.str}, '
    'previousRoute= ${previousRoute?.str}',
  );

  @override
  void didStopUserGesture() => log.info('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
