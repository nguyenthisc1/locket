import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/domain/auth/usecase/login_usecase.dart';
import 'package:locket/presentation/auth/widgets/email_login_form.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    final authRepository = GetIt.instance<AuthRepositoryImpl>();
    final LoginUsecase loginUseCase = LoginUsecase(authRepository);

    return Scaffold(
      appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.md,
            right: AppDimensions.md,
          ),
          child: Column(children: [EmailLoginForm(loginUsecase: loginUseCase,)]),
        ),
      ),
    );
  }
}
