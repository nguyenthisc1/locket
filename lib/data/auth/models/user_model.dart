import 'package:locket/domain/auth/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.isVerified,
    super.lastActiveAt,
    super.friends,
    super.chatRooms,
    super.createdAt,
  });

  /// Create a UserModel from a map (e.g., from API or database).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      isVerified: map['isVerified'] ?? false,
      lastActiveAt:
          map['lastActiveAt'] != null
              ? DateTime.tryParse(map['lastActiveAt'])
              : null,
      friends:
          map['friends'] != null ? List<String>.from(map['friends']) : const [],
      chatRooms:
          map['chatRooms'] != null
              ? List<String>.from(map['chatRooms'])
              : const [],
      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'])
              : DateTime.now(),
    );
  }

  /// Convert the UserModel to a map for storage or transmission.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'friends': friends,
      'chatRooms': chatRooms,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
