import 'package:flutter/material.dart';
import 'package:locket/core/constants/routes.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/splash/pages/splash_page.dart';

import 'core/configs/theme/index.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // Initialize dynamic links service for email link authentication
  // final dynamicLinksService = DynamicLinksServiceR();
  // await dynamicLinksService.initDynamicLinks();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket Clone',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      navigatorObservers: [routeObserver],
    );
  }
}
