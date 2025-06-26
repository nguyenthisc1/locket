import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/validation.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/domain/auth/usecases_firebase/email_link_send_usecase.dart';
import 'package:locket/presentation/auth/pages/email_link_verification_page.dart';
import 'package:locket/presentation/auth/pages/phone_login_page.dart';

class EmailLinkLoginForm extends StatefulWidget {
  final EmailLinkSendUsecase emailLinkSendUsecase;

  const EmailLinkLoginForm({super.key, required this.emailLinkSendUsecase});

  @override
  State<EmailLinkLoginForm> createState() => EmailLinkLoginFormState();
}

class EmailLinkLoginFormState extends State<EmailLinkLoginForm> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await widget.emailLinkSendUsecase(_emailController.text);

      result.fold((failure) => DisplayMessage.error(context, failure.message), (
        _,
      ) {
        DisplayMessage.success(
          context,
          'Đã gửi liên kết đăng nhập đến ${_emailController.text}. Kiểm tra hộp thư và nhấp vào liên kết để đăng nhập.',
        );
        AppNavigator.push(
          context,
          EmailLinkVerificationPage(email: _emailController.text),
        );
      });
    } catch (e) {
      if (!mounted) return;
      DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đăng nhập bằng Email',
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ Email',
                    ),
                    validator: ValidationHelper.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // LOGIN WITH PHONE
                  ElevatedButton(
                    onPressed:
                        () =>
                            AppNavigator.push(context, const PhoneLoginPage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text(
                      'Sử dụng số điện thoại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendEmail,
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
                              'Gửi liên kết đăng nhập',
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
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
