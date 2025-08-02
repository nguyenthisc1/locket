import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/logo.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
                  Logo(),
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
                onPressed:
                    () {
                      context.go('/home');
                    },
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
