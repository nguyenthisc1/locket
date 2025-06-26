import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/data/auth/repositories/auth_firebase_repository_impl.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';
import 'package:locket/domain/auth/usecases_firebase/email_login_usecase.dart';
import 'package:locket/presentation/auth/widgets/email_login_form.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthFirebaseRepository authFirebaseRepository =
        AuthFirebaseRepositoryImpl();
    // final EmailLinkSendUsecase emailLinkSendUsecase = EmailLinkSendUsecase(
    //   AuthFirebaseRepository,
    // );
    final EmailLoginUseCase emailLoginUseCase = EmailLoginUseCase(
      authFirebaseRepository,
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
