// splash_page.dart
import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/logo.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/core/services/token_validation_service.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller.dart';
import 'package:locket/di.dart';
import 'package:logger/logger.dart';

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
  late final AuthController _authController;
  late final TokenValidationService _tokenValidationService;
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  @override
  void initState() {
    super.initState();

    _authController = getIt<AuthController>();
    _tokenValidationService = getIt<TokenValidationService>();

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
    try {
      _logger.d('🚀 Initializing app...');
      
      // Validate tokens and clean up expired ones
      final hasValidTokens = await _tokenValidationService.validateAndCleanupTokens();
      
      if (hasValidTokens) {
        final validTokens = await _tokenValidationService.getValidTokens();
        if (validTokens != null) {
          _logger.d('✅ Valid tokens found, proceeding to home');
          
          // Log token info for debugging
          final tokenInfo = await _tokenValidationService.getTokenInfo();
          _logger.d('Token info: $tokenInfo');
          
          // Add any app initialization logic here
          await Future.delayed(const Duration(seconds: 2));
          
          if (!mounted) return;
          
          // Wait for auth initialization to complete before navigating
          _authController.init();
          AppNavigator.pushReplacement(context, '/home');
          return;
        }
      }
      
      _logger.d('❌ No valid tokens found, redirecting to onboarding');
      
      // Add any app initialization logic here
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      AppNavigator.pushReplacement(context, '/email-login');
    } catch (e) {
      _logger.e('❌ Error during app initialization: $e');
      
      // Fallback to onboarding on error
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      AppNavigator.pushReplacement(context, '/email-login');
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
