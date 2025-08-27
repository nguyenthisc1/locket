import 'package:flutter/material.dart';
import 'package:locket/core/routes/router.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:provider/provider.dart';

import 'core/configs/theme/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // Initialize dynamic links service for email link authentication
  // final dynamicLinksService = DynamicLinksServiceR();
  // await dynamicLinksService.initDynamicLinks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<FeedControllerState>()),
        ChangeNotifierProvider.value(value: getIt<UserService>()),
        Provider.value(value: getIt<FeedController>()),
      ],
      child: MyApp(),
    ),
  );
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
      routerConfig: AppRouter.instance.router,
    );
  }
}
