import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller_state.dart';
import 'package:locket/presentation/auth/widgets/email_login_form.dart';
import 'package:provider/provider.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthControllerState>(
      builder: (context, authState, _) {
        return KeyboardDismisser(
          child: Scaffold(
            appBar: const BasicAppbar(hideBack: true),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.md,
                  right: AppDimensions.md,
                ),
                child: Column(children: [EmailLoginForm()]),
              ),
            ),
          ),
        );
      },
    );
  }
}
