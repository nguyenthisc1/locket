import 'dart:ui';

extension SafeOpacity on Color {
  Color safeOpacity(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}
