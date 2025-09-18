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

/// Utility class for safe DateTime parsing operations
class DateTimeUtils {
  /// Safely parses a dynamic value to DateTime.
  /// Returns the parsed DateTime if successful, otherwise returns the fallback.
  /// 
  /// Supports:
  /// - DateTime objects (returned as-is)
  /// - String values (parsed using DateTime.tryParse)
  /// - int/double values (treated as milliseconds since epoch)
  /// - null values (returns fallback)
  static DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
    if (value == null) {
      return fallback ?? DateTime.now();
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      if (value.isEmpty) {
        return fallback ?? DateTime.now();
      }
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        // Invalid timestamp
      }
    }
    
    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      } catch (e) {
        // Invalid timestamp
      }
    }
    
    // If all parsing attempts fail, return fallback
    return fallback ?? DateTime.now();
  }
  
  /// Safely parses a dynamic value to nullable DateTime.
  /// Returns null if parsing fails or value is null/empty.
  static DateTime? parseDateTimeNullable(dynamic value) {
    if (value == null) {
      return null;
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      if (value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(value);
    }
    
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }
    
    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
  
  /// Safely converts DateTime to ISO 8601 string.
  /// Returns null if the DateTime is null.
  static String? toIsoString(DateTime? dateTime) {
    return dateTime?.toIso8601String();
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
