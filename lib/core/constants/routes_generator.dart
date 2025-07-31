import 'package:flutter/material.dart';
import 'package:locket/core/services/auth_middleware_service.dart';
import 'package:locket/presentation/conversation/pages/conversation_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

class AppRouteGenerator {
  static final AuthMiddlewareService _authMiddleware = AuthMiddlewareService();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/converstion':
        return MaterialPageRoute(builder: (_) => ConversationPage());

      case '/converstion:id':
        // Extract the ID from the route
        final id = settings.name!.split(':').last;
        return MaterialPageRoute(
          // builder: (_) => ConversationDetailPage(conversationId: id),
          builder: (_) => Container(),
        );

      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }

  static Future<String> getInitialRoute() async {
    return await _authMiddleware.getInitialRoute();
  }
}
