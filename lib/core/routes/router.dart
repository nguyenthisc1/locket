// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';
import 'package:locket/presentation/auth/pages/phone_login_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';
import 'package:locket/presentation/splash/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();
  static final Middleware _middleware = GetIt.instance<Middleware>();

  final GoRouter router = GoRouter(
    initialLocation: '/splashPage',
    routerNeglect: false,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      try {
        print('🛣️ Router redirect called for: ${state.path}');
        final redirectPath = await _middleware.routeMiddleware(state);
        print('🛣️ Router redirect result: ${state.path} -> $redirectPath');
        return redirectPath;
      } catch (e) {
        print('❌ Error in router redirect: $e');
        return '/onboarding';
      }
    },
    routes: [
      GoRoute(
        path: '/splashPage',
        builder: (context, state) => const SplashPage(),
      ),
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
        path: '/converstion/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return Container();
          // return ConversationDetailPage(conversationId: id);
        },
      ),
    ],
  );
}
