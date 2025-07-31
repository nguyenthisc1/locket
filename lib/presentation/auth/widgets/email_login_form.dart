import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/validation.dart';
import 'package:locket/common/wigets/auth_route_gate.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';

class EmailLoginForm extends StatefulWidget {
  // final LoginUseCase loginUseCase;

  const EmailLoginForm({super.key});

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  // Set default values for email and password fields
  final _emailController = TextEditingController(text: 'admin@gmail.com');
  final _passwordController = TextEditingController(text: 'Adminadmin12');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // try {
    //   final result = await widget.loginUseCase(
    //     identifier: _emailController.text,
    //     password: _passwordController.text,
    //   );

    //   result.fold(
    //     (failure) {
    //       print(  failure.message);
    //       DisplayMessage.error(
    //         context,
    //         // 'Tài khoản hoặc mật khẩu không đúng',
    //         failure.message,
    //       );
    //     },
    //     (user) {
    //       DisplayMessage.success(context, 'Đăng nhập thành công!');
    //       AppNavigator.pushReplacement(context, const AuthGate());
    //     },
    //   );
    // } catch (e) {
    //   if (!mounted) {
    //     return;
    //   }
    //       print(  e);


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
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isLoading
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
