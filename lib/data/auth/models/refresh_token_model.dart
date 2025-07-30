class RefreshTokenModel {
  final String refreshToken;
  final String accessToken;

  RefreshTokenModel({
      required this.refreshToken,
      required this.accessToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
      'accessToken': accessToken,
    };
  }
}