import 'package:flutter/material.dart';
import 'package:locket/common/wigets/auth_gate.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/onboarding': (_) => const OnboardingPage(),
  '/auth': (_) => const AuthGate(),
};
