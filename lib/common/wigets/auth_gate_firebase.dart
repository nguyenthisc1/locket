import 'package:flutter/material.dart';

class AuthGateFirebase extends StatelessWidget {
  const AuthGateFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    // final AuthFirebaseRepositoryImpl authFirebaseRepositoryImpl =
    //     AuthFirebaseRepositoryImpl();
    // final WatchAuthStateUseCase watchAuthStateUseCase = WatchAuthStateUseCase(
    //   authFirebaseRepositoryImpl,
    // );

    // return StreamBuilder<Either<Failure, UserEntity?>>(
    //   stream: watchAuthStateUseCase(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }

    //     if (snapshot.hasData) {
    //       return snapshot.data!.fold(
    //         (failure) => const OnboardingPage(),
    //         (user) => user != null ? const HomePage() : const OnboardingPage(),
    //       );
    //     } else {
    //       return const OnboardingPage();
    //     }
    //   },
    // );

    return Container();
  }
}
