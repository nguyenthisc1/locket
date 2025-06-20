// splash_page.dart
import 'package:flutter/material.dart';
import 'package:locket/common/wigets/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<bool> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }

    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstLaunch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isFirstLaunch = snapshot.data!;
        if (isFirstLaunch) {
          return const OnboardingPage();
        } else {
          return const AuthGate();
        }
      },
    );
  }
}
