import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/auth/usecases/email_link_send_usecase.dart';
import 'package:locket/domain/auth/usecases/email_login_usecase.dart';
import 'package:locket/presentation/auth/widgets/email_link_login_form.dart';
import 'package:locket/presentation/auth/widgets/email_login_form.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepositoryImpl();
    // final EmailLinkSendUsecase emailLinkSendUsecase = EmailLinkSendUsecase(
    //   authRepository,
    // );
    final EmailLoginUseCase emailLoginUseCase = EmailLoginUseCase(
      authRepository,
    );

    return Scaffold(
      appBar: const BasicAppbar(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          bottom: AppDimensions.appBarHeight,
        ),
        child: Column(
          children: [EmailLoginForm(emailLoginUseCase: emailLoginUseCase)],
        ),
      ),
    );
  }
}
