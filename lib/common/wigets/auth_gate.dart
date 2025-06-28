// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/auth/usecase/auth_usecases.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _authRepository;
  late final WatchAuthStateUseCase _watchAuthStateUseCase;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl();
    _watchAuthStateUseCase = WatchAuthStateUseCase(_authRepository);
  }

  @override
  void dispose() {
    // Clean up the repository
    if (_authRepository is AuthRepositoryImpl) {
      (_authRepository).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dartz.Either<Failure, UserEntity?>>(
      stream: _watchAuthStateUseCase(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('AuthGate - Data: ${snapshot.data}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          print('AuthGate - Error: ${snapshot.error}');
          return _buildErrorScreen(snapshot.error.toString());
        }

        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) {
              // Handle auth failure
              print('AuthGate - Auth Failure: ${failure.message}');
              _handleAuthFailure(failure);
              return const OnboardingPage();
            },
            (user) {
              print('AuthGate - User: ${user?.username ?? 'null'}');
              if (user != null) {
                return const HomePage();
              } else {
                return const OnboardingPage();
              }
            },
          );
        }

        // Default to onboarding if no data
        print('AuthGate - No data, defaulting to OnboardingPage');
        return const OnboardingPage();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang kiểm tra đăng nhập...',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Trigger a rebuild to retry
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuthFailure(Failure failure) {
    // Log the failure and show a message if needed
    print('Auth failure: ${failure.message}');

    // You can show a snackbar or dialog here if needed
    // DisplayMessage.error(context, failure.message);
  }
}
