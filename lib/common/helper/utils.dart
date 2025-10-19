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
  /// Safely parses a dynamic value to DateTime and converts to local time.
  /// Returns the parsed DateTime if successful, otherwise returns the fallback.
  ///
  /// Supports:
  /// - DateTime objects (converted to local time)
  /// - String values (parsed using DateTime.tryParse and converted to local)
  /// - int/double values (treated as milliseconds since epoch, converted to local)
  /// - null values (returns fallback)
  static DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
    if (value == null) {
      return fallback ?? DateTime.now();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      if (value.isEmpty) {
        return fallback ?? DateTime.now();
      }
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }

    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      } catch (e) {
        // Invalid timestamp
      }
    }

    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
      } catch (e) {
        // Invalid timestamp
      }
    }

    // If all parsing attempts fail, return fallback
    return fallback ?? DateTime.now();
  }

  /// Safely parses a dynamic value to nullable DateTime and converts to local time.
  /// Returns null if parsing fails or value is null/empty.
  static DateTime? parseDateTimeNullable(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      if (value.isEmpty) {
        return null;
      }
      final parsed = DateTime.tryParse(value);
      return parsed?.toLocal();
    }

    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      } catch (e) {
        return null;
      }
    }

    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
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

  /// Parses timestamp string and converts to local time
  /// Specifically for handling server timestamps that need local conversion
  static DateTime parseTimestamp(String timestamp) {
    return DateTime.parse(timestamp).toLocal();
  }

  /// Parses nullable timestamp string and converts to local time
  static DateTime? parseTimestampNullable(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return null;
    }
    return DateTime.tryParse(timestamp)?.toLocal();
  }

  /// Synchronizes a DateTime to current local timezone
  /// Useful for ensuring all times are displayed in user's local time
  static DateTime syncToLocal(DateTime dateTime) {
    return dateTime.toLocal();
  }

  /// Gets current local time
  static DateTime nowLocal() {
    return DateTime.now().toLocal();
  }

  /// Converts DateTime to local time and formats for display
  static String formatLocalTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Formats a [DateTime] into a Vietnamese-friendly timestamp string.
/// - Today: returns "HH:mm"
/// - Yesterday: returns "Hôm qua, HH:mm"
/// - Other: returns "dd thg x, HH:mm"
///
/// Automatically converts to local time for proper display
String formatVietnameseTimestamp(DateTime dateTime) {
  // Ensure we're working with local time
  final localDateTime = dateTime.toLocal();
  final now = DateTime.now().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDay = DateTime(
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
  );

  const vietnameseMonths = [
    '', // 0 index not used
    'thg 1', 'thg 2', 'thg 3', 'thg 4', 'thg 5', 'thg 6',
    'thg 7', 'thg 8', 'thg 9', 'thg 10', 'thg 11', 'thg 12',
  ];

  final hourMinute =
      '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';

  if (messageDay == today) {
    return hourMinute;
  } else if (messageDay == yesterday) {
    return '$hourMinute Hôm qua';
  } else {
    final day = localDateTime.day.toString();
    final month = vietnameseMonths[localDateTime.month];
    return '$hourMinute $day $month';
  }
}

String createLocalUri(String filePath) {
  // Handle case where filePath might already have a prefix
  String cleanPath = filePath;

  // Remove any existing prefixes
  if (cleanPath.startsWith('local:////')) {
    cleanPath = cleanPath.substring(10);
  } else if (cleanPath.startsWith('local:///')) {
    cleanPath = cleanPath.substring(9);
  } else if (cleanPath.startsWith('file:///')) {
    cleanPath = cleanPath.substring(8);
  } else if (cleanPath.startsWith('file://')) {
    cleanPath = cleanPath.substring(7);
  }

  // Handle case where path starts with additional slashes
  while (cleanPath.startsWith('//')) {
    cleanPath = cleanPath.substring(1);
  }

  // Ensure we have an absolute path
  if (cleanPath.isNotEmpty && !cleanPath.startsWith('/')) {
    cleanPath = '/$cleanPath';
  }

  // Return with consistent local:// prefix (single slash after colon)
  return 'local://$cleanPath';
}

String getActualFilePath(String path) {
  // Remove prefixes and handle malformed URIs
  String cleanPath = path;

  // Handle various local prefix formats
  if (cleanPath.startsWith('local:////')) {
    cleanPath = cleanPath.substring(10); // Remove 'local:////' prefix
  } else if (cleanPath.startsWith('local:///')) {
    cleanPath = cleanPath.substring(9); // Remove 'local:///' prefix
  } else if (cleanPath.startsWith('local://')) {
    cleanPath = cleanPath.substring(8); // Remove 'local://' prefix (new format)
  } else if (cleanPath.startsWith('file:///')) {
    cleanPath = cleanPath.substring(8); // Remove 'file:///' prefix
  } else if (cleanPath.startsWith('file://')) {
    cleanPath = cleanPath.substring(7); // Remove 'file://' prefix
  }

  // Handle case where path starts with additional slashes
  while (cleanPath.startsWith('//')) {
    cleanPath = cleanPath.substring(1);
  }

  // Ensure we have an absolute path
  if (cleanPath.isNotEmpty && !cleanPath.startsWith('/')) {
    cleanPath = '/$cleanPath';
  }

  return cleanPath;
}

bool isLocalFilePath(String path) {
  // Check if it's a local file path or has our local prefix
  // Accepts various local prefixes for compatibility
  return path.startsWith('local://') || // New format
      path.startsWith('local:///') ||
      path.startsWith('local:////') ||
      path.startsWith('/') ||
      path.startsWith('file://') ||
      path.contains('/var/mobile/') ||
      path.contains('/Documents/') ||
      !path.startsWith('http');
}
