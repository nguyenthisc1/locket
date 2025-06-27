import 'package:flutter/material.dart';
import 'package:locket/common/wigets/auth_gate_firebase.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/onboarding': (_) => const OnboardingPage(),
  '/auth': (_) => const AuthGateFirebase(),
  '/home': (_) => const HomePage(),
};
