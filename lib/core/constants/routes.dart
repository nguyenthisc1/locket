import 'package:flutter/material.dart';
import 'package:locket/common/wigets/auth_route_gate.dart';
import 'package:locket/presentation/conversation/pages/conversation_detail_page.dart';
import 'package:locket/presentation/conversation/pages/conversation_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/onboarding': (_) => AuthRouteGuard(
        route: '/onboarding',
        child: const OnboardingPage(),
      ),
  '/home': (_) => AuthRouteGuard(
        route: '/home',
        child: const HomePage(),
      ),
  '/converstion': (_) => AuthRouteGuard(
        route: '/converstion',
        child: ConversationPage(),
      ),
  '/converstion:id': (_) => AuthRouteGuard(
        route: '/converstion:id',
        child: const ConversationDetailPage(),
      ),
};