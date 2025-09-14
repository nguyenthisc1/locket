import 'dart:ui';

/// Extension to safely apply opacity to a [Color].
extension SafeOpacity on Color {
  /// Returns a new color with the given [opacity] (0.0 - 1.0).
  /// Ensures the alpha value is within the valid range.
  Color safeOpacity(double opacity) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((clampedOpacity * 255).round());
  }
}

/// Formats a [DateTime] into a Vietnamese-friendly timestamp string.
/// - Today: returns "HH:mm"
/// - Yesterday: returns "Hôm qua, HH:mm"
/// - Other: returns "dd thg x, HH:mm"
String formatVietnameseTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

  const vietnameseMonths = [
    '', // 0 index not used
    'thg 1', 'thg 2', 'thg 3', 'thg 4', 'thg 5', 'thg 6',
    'thg 7', 'thg 8', 'thg 9', 'thg 10', 'thg 11', 'thg 12',
  ];

  final hourMinute =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  if (messageDay == today) {
    return hourMinute;
  } else if (messageDay == yesterday) {
    return '$hourMinute Hôm qua';
  } else {
    final day = dateTime.day.toString();
    final month = vietnameseMonths[dateTime.month];
    return '$hourMinute $day $month';
  }
}
