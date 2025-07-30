
class UserModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  /// Converts this [UserModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
