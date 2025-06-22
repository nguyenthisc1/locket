import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';

class EmailLinkVerificationPage extends StatelessWidget {
  final String email;

  const EmailLinkVerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Kiểm tra email của bạn',
              style: AppTypography.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Chúng tôi đã gửi liên kết đăng nhập đến:',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                email,
                style: AppTypography.titleLarge.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Nhấp vào liên kết trong email để hoàn tất đăng nhập.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xxl),
            ElevatedButton(
              onPressed:
                  () => AppNavigator.pushReplacement(
                    context,
                    const EmailLoginPage(),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text(
                'Gửi lại liên kết',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
