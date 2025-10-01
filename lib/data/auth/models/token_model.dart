import 'package:jwt_decoder/jwt_decoder.dart';

class AuthTokenPair {
  /// Access-token for accessing server resources for an authorized user.
  final String accessToken;
/// Refresh-token for updating the access-token.
  final String refreshToken;
  /// Create an instance of AuthTokenPair.
  const AuthTokenPair({
    required this.accessToken,
    required this.refreshToken,
  });
  /// Create an instance of AuthTokenPair from json.
  factory AuthTokenPair.fromJson(Map<String, dynamic> json) {
    return AuthTokenPair(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
  /// Convert an instance of AuthTokenPair to json.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  /// Check if the access token is expired
  bool get isAccessTokenExpired {
    if (accessToken.isEmpty) return true;
    
    try {
      return JwtDecoder.isExpired(accessToken);
    } catch (e) {
      // If we can't decode the token, consider it expired
      return true;
    }
  }

  /// Check if the refresh token is expired
  bool get isRefreshTokenExpired {
    if (refreshToken.isEmpty) return true;
    
    try {
      return JwtDecoder.isExpired(refreshToken);
    } catch (e) {
      // If we can't decode the token, consider it expired
      return true;
    }
  }

  /// Check if both tokens are expired
  bool get areTokensExpired {
    return isAccessTokenExpired && isRefreshTokenExpired;
  }

  /// Check if tokens are valid (not expired and not empty)
  bool get areTokensValid {
    return accessToken.isNotEmpty && 
           refreshToken.isNotEmpty && 
           !areTokensExpired;
  }

  /// Get the expiration date of the access token
  DateTime? get accessTokenExpirationDate {
    if (accessToken.isEmpty) return null;
    
    try {
      return JwtDecoder.getExpirationDate(accessToken);
    } catch (e) {
      return null;
    }
  }

  /// Get the expiration date of the refresh token
  DateTime? get refreshTokenExpirationDate {
    if (refreshToken.isEmpty) return null;
    
    try {
      return JwtDecoder.getExpirationDate(refreshToken);
    } catch (e) {
      return null;
    }
  }

  /// Get remaining time until access token expires
  Duration? get accessTokenRemainingTime {
    final expirationDate = accessTokenExpirationDate;
    if (expirationDate == null) return null;
    
    final now = DateTime.now();
    if (expirationDate.isBefore(now)) return Duration.zero;
    
    return expirationDate.difference(now);
  }

  /// Check if access token will expire within the given duration
  bool willAccessTokenExpireWithin(Duration duration) {
    final remainingTime = accessTokenRemainingTime;
    if (remainingTime == null) return true;
    
    return remainingTime <= duration;
  }
}