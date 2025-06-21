// splash_page.dart
import 'package:flutter/material.dart';
import 'package:locket/common/wigets/auth_gate.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate();
  }
}
