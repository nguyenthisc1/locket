import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  /// Create an instance of AuthTokenModel from json.
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    if (json['expiresAt'] != null) {
      expiresAt = DateTime.parse(json['expiresAt'] as String);
    }

    return AuthTokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: expiresAt,
    );
  }

  /// Convert an instance of AuthTokenModel to json.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Check if the access token is expired
  bool get isExpired {
    if (expiresAt == null) {
      // If no expiration time, try to decode from JWT
      return _isJwtExpired(accessToken);
    }

    // Consider token expired if it expires within the next 5 minutes
    final bufferTime = Duration(minutes: 5);
    return DateTime.now().isAfter(expiresAt!.subtract(bufferTime));
  }

  /// Check if the access token will expire soon (within 10 minutes)
  bool get willExpireSoon {
    if (expiresAt == null) {
      return _isJwtExpiringSoon(accessToken);
    }

    final bufferTime = Duration(minutes: 10);
    return DateTime.now().isAfter(expiresAt!.subtract(bufferTime));
  }

  /// Decode JWT token and check if it's expired
  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true; // Assume expired on error
    }
  }

  /// Check if JWT token will expire soon
  bool _isJwtExpiringSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final bufferTime = Duration(minutes: 10);
      return DateTime.now().isAfter(expirationTime.subtract(bufferTime));
    } catch (e) {
      return true; // Assume expiring soon on error
    }
  }

  /// Get token expiration time from JWT
  DateTime? get jwtExpirationTime {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      return null;
    }
  }

  /// Create a copy with updated tokens
  AuthTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'AuthTokenModel(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthTokenModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ refreshToken.hashCode ^ expiresAt.hashCode;
  }
}

/// Token Manager for handling token storage and retrieval
class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _tokenExpiryKey = 'tokenExpiry';

  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  /// Save tokens to secure storage
  static Future<void> saveTokens(AuthTokenModel tokens) async {
    try {
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);

      if (tokens.expiresAt != null) {
        await _storage.write(
          key: _tokenExpiryKey,
          value: tokens.expiresAt!.toIso8601String(),
        );
      }

      _logger.d('✅ Tokens saved to secure storage');
    } catch (e) {
      _logger.e('❌ Failed to save tokens: $e');
      rethrow;
    }
  }

  /// Load tokens from secure storage
  static Future<AuthTokenModel?> loadTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final expiryString = await _storage.read(key: _tokenExpiryKey);

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      DateTime? expiresAt;
      if (expiryString != null) {
        expiresAt = DateTime.parse(expiryString);
      }

      return AuthTokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
    } catch (e) {
      _logger.e('❌ Failed to load tokens: $e');
      return null;
    }
  }

  /// Clear all tokens from secure storage
  static Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenExpiryKey);

      _logger.d('🧹 Tokens cleared from secure storage');
    } catch (e) {
      _logger.e('❌ Failed to clear tokens: $e');
      rethrow;
    }
  }

  /// Check if tokens exist in storage
  static Future<bool> hasTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      return accessToken != null && refreshToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Get only the access token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.e('❌ Failed to get access token: $e');
      return null;
    }
  }

  /// Get only the refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.e('❌ Failed to get refresh token: $e');
      return null;
    }
  }
}
