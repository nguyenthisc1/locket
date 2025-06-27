import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/validation.dart';
import 'package:locket/common/wigets/auth_gate_firebase.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({super.key});

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _emailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // try {
    //   final result = await widget.emailLoginUseCase(
    //     _emailController.text,
    //     _passwordController.text,
    //   );

    //   result.fold(
    //     (failure) {
    //       DisplayMessage.error(context, failure.message);
    //     },
    //     (user) {
    //       DisplayMessage.success(
    //         context,
    //         'Đăng nhập thành công! Chuyển hướng đến trang chủ...',
    //       );
    //       AppNavigator.pushReplacement(context, const AuthGateFirebase());
    //     },
    //   );
    // } catch (e) {
    //   if (!mounted) {
    //     return;
    //   }

    //   DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đăng nhập bằng Email',
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xl),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: ValidationHelper.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
            validator: ValidationHelper.validatePassword,
          ),
          const SizedBox(height: AppDimensions.xl),
          ElevatedButton(
            onPressed: _isLoading ? null : _emailLogin,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
