import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/validation.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller_state.dart';
import 'package:provider/provider.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({super.key});

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final _emailController = TextEditingController(text: 'admin@gmail.com');
  final _passwordController = TextEditingController(text: 'User123');
  final _formKey = GlobalKey<FormState>();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = getIt<AuthController>();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authController.login(
      identifier: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      DisplayMessage.success(context, 'Đăng nhập thành công');
      AppNavigator.pushAndRemove(context, '/home');
    } else {
      final errorMessage =
          _authController.state.errorMessage ?? 'Đăng nhập thất bại';
      DisplayMessage.error(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthControllerState>();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đăng nhập bằng Email',
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xl),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: ValidationHelper.validateEmail,
            keyboardType: TextInputType.emailAddress,
            enabled: !authState.isLoading,
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: _passwordController,
            obscureText: authState.obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(
                  authState.obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: _authController.togglePasswordVisibility,
              ),
            ),
            validator: ValidationHelper.validatePassword,
            enabled: !authState.isLoading,
          ),
          const SizedBox(height: AppDimensions.xl),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            child:
                authState.isLoading
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
