import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/auth/usecases/email_login_usecase.dart';
import 'package:locket/presentation/auth/widgets/email_login_form.dart';
import 'package:locket/presentation/auth/widgets/phone_login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _isPhoneLogin = true;
  late final AuthRepository _authRepository;
  late final EmailLoginUseCase _emailLoginUseCase;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl();
    _emailLoginUseCase = EmailLoginUseCase(_authRepository);
  }

  void _toggleLoginMethod() {
    setState(() {
      _isPhoneLogin = !_isPhoneLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          bottom: AppDimensions.appBarHeight,
        ),
        child: Center(
          child: Column(
            children: [
              _isPhoneLogin
                  ? const PhoneLoginForm()
                  : EmailLoginForm(emailLoginUseCase: _emailLoginUseCase),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: _toggleLoginMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(
                  _isPhoneLogin ? 'Sử dụng email' : 'Sử dụng số điện thoại',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
