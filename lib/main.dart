import 'package:flutter/material.dart';
import 'package:locket/core/routes/router.dart';
import 'package:locket/di.dart';

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
    return MaterialApp.router(
      title: 'Locket Clone',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      // navigatorObservers: [routeObserver],
      routerConfig: AppRouter.instance.router,
    );
  }
}
