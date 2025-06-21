import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/core/configs/assets/app_images.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/auth/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    child: Image.asset(
                      AppImages.logo,
                      width: AppDimensions.avatarLg,
                      height: AppDimensions.avatarLg,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Text('Locket', style: AppTypography.displayLarge),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'Theo dõi ảnh từ bạn bè, trên màn hình chính của bạn',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),
              ElevatedButton(
                onPressed: () => AppNavigator.push(context, const LoginPage()),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('Tạo tài khoản'),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: () => AppNavigator.push(context, const LoginPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
