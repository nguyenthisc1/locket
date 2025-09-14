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
}