import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  void _showBottomSheet(BuildContext context) {

    final authController = context.read<AuthController>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  authController.logout();
                  context.pushReplacement('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: const UserImage(),
    );
  }
}
