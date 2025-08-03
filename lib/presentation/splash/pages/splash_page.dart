// splash_page.dart
import 'package:flutter/material.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/logo.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/di.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late Animation<double> logoScaleAnimation;
  late Animation<double> textAnimation;
  late AnimationController logoController;
  late AnimationController textController;

  final _tokenStorage = getIt<TokenStorage<AuthTokenPair>>();

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Text animation controller (starts after logo animation)
    textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Logo scale animation (center to left)
    logoScaleAnimation = Tween<double>(begin: 0, end: 80.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeOutBack),
    );

    // Text fade in animation
    textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: textController, curve: Curves.easeInOut));

    // Start logo animation
    logoController.forward().then((_) async {
      // When logo animation completes, start text animation
      textController.forward();

      await Future.delayed(const Duration(milliseconds: 500));
      _initializeApp();
    });
  }

  @override
  void dispose() {
    logoController.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final tokenPair = await _tokenStorage.read();

    // Add any app initialization logic here
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (tokenPair != null && tokenPair.accessToken?.isNotEmpty == true) {
        AppNavigator.pushAndRemove(context, '/home');
      } else {
        AppNavigator.pushAndRemove(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([logoController, textController]),
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: logoScaleAnimation.value / 80.0,
                  child: Logo(size: 80.0),
                ),
                const SizedBox(width: AppDimensions.md),
                Opacity(
                  opacity: textAnimation.value,
                  child: const Text(
                    'Locket',
                    style: AppTypography.displayLarge,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
