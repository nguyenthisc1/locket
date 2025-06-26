import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/domain/auth/usecases_firebase/verify_phone_usecase.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';
import 'package:locket/presentation/auth/pages/verify_phone_page.dart';

class PhoneLoginForm extends StatefulWidget {
  final VerifyPhoneUsecase verifyPhoneUsecase;

  const PhoneLoginForm({super.key, required this.verifyPhoneUsecase});

  @override
  State<PhoneLoginForm> createState() => PhoneLoginFormState();
}

class PhoneLoginFormState extends State<PhoneLoginForm> {
  final _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _isLoading = false;

  void _verifyPhone() async {
    if (_completePhoneNumber.isEmpty) {
      DisplayMessage.error(context, 'Vui lòng nhập số điện thoại hợp lệ');
      return;
    }

    if (Platform.isIOS && !Platform.isMacOS && !Platform.isAndroid) {
      DisplayMessage.error(
        context,
        'Không hỗ trợ xác minh số điện thoại trên iOS Simulator.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.verifyPhoneUsecase(_completePhoneNumber);

      result.fold(
        (failure) {
          DisplayMessage.error(context, failure.message);
        },
        (verificationId) {
          DisplayMessage.success(context, 'Mã xác thực đã được gửi!');
          // Navigate to OTP verification screen
          AppNavigator.push(
            context,
            VerifyPhonePage(
              phoneNumber: _completePhoneNumber,
              verificationId: verificationId,
            ),
          );
        },
      );
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đăng nhập bằng số điện thoại',
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: AppDimensions.xl),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.displaySmall,
                  decoration: InputDecoration(
                    hintText: 'Nhập số điện thoại',
                    hintStyle: AppTypography.bodyLarge,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _completePhoneNumber = '+84$value';
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                ElevatedButton(
                  onPressed:
                      () => AppNavigator.push(context, const EmailLoginPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dark,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text(
                    'Sử dụng email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhone,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: AppDimensions.iconLg,
                        width: AppDimensions.iconLg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Tiếp theo',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                            size: AppDimensions.iconLg,
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
