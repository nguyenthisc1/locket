import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';

class VerifyPhonePage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const VerifyPhonePage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      DisplayMessage.error(context, 'Vui lòng nhập mã OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // final result = await signInWithPhoneUsecase(
      //   widget.phoneNumber,
      //   widget.verificationId,
      //   _otpController.text,
      // );

      // result.fold(
      //   (failure) {
      //     DisplayMessage.error(context, failure.message);
      //   },
      //   (user) {
      //     DisplayMessage.success(context, 'Đăng nhập thành công!');
      //     AppNavigator.pop(context);
      //   },
      // );

      // Temporary success message for now
      DisplayMessage.success(context, 'OTP verification successful!');
      // AppNavigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nhập mã xác thực', style: AppTypography.displaySmall),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Mã đã được gửi đến ${widget.phoneNumber}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTypography.displaySmall,
              decoration: const InputDecoration(
                hintText: 'Nhập mã OTP',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.md,
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: AppDimensions.iconLg,
                          width: AppDimensions.iconLg,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Xác thực',
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
