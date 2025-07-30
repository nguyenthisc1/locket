import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  /// Creates a [UserEntity] from a JSON map.
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  /// Converts this [UserEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  List<Object?> get props => [id, username, email, phoneNumber];
}