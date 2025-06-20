import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:locket/core/constants/routes.dart';
import 'package:locket/presentation/splash/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/configs/theme/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket Clone',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashPage(),
      initialRoute: onboardingComplete ? '/auth' : '/onboarding',
      routes: appRoutes,
    );
  }
}
