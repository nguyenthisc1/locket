import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/data/auth/repositories/auth_firebase_repository_impl.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';
import 'package:locket/domain/auth/usecases/verify_phone_usecase.dart';
import 'package:locket/presentation/auth/widgets/phone_login_form.dart';

class PhoneLoginPage extends StatelessWidget {
  const PhoneLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthFirebaseRepository authFirebaseRepository =
        AuthFirebaseRepositoryImpl();
    final VerifyPhoneUsecase verifyPhoneUsecase = VerifyPhoneUsecase(
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
          children: [PhoneLoginForm(verifyPhoneUsecase: verifyPhoneUsecase)],
        ),
      ),
    );
  }
}
