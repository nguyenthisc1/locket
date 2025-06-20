import 'package:flutter/material.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/presentation/auth/pages/login_page.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl();

    return StreamBuilder<UserEntity?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
