import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/data/auth/repositories/auth_firebase_repository_impl.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/usecases/watch_auth_state_usecase.dart';
import 'package:locket/presentation/home/pages/home_page.dart';
import 'package:locket/presentation/splash/pages/onboarding_page.dart';

class AuthGateFirebase extends StatelessWidget {
  const AuthGateFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthFirebaseRepositoryImpl authFirebaseRepositoryImpl =
        AuthFirebaseRepositoryImpl();
    final WatchAuthStateUseCase watchAuthStateUseCase = WatchAuthStateUseCase(
      authFirebaseRepositoryImpl,
    );

    return StreamBuilder<Either<Failure, UserEntity?>>(
      stream: watchAuthStateUseCase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) => const OnboardingPage(),
            (user) => user != null ? const HomePage() : const OnboardingPage(),
          );
        } else {
          return const OnboardingPage();
        }
      },
    );
  }
}
