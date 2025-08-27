import 'package:equatable/equatable.dart';
import 'package:locket/data/user/models/friend_model.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? lastActiveAt;
  final List<FriendProfileModel>? friends;
  final List<String>? chatRooms;

  const UserProfileEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    this.lastActiveAt,
    this.friends = const [],
    this.chatRooms = const [],
  });

  /// Creates a [UserProfileEntity] from a JSON map.
  factory UserProfileEntity.fromJson(Map<String, dynamic> json) {
    return UserProfileEntity(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastActiveAt:
          json['lastActiveAt'] != null
              ? DateTime.tryParse(json['lastActiveAt'].toString())
              : null,
      friends: (json['friends'] as List<dynamic>?)
              ?.map((e) => FriendProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      chatRooms:
          (json['chatRooms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Converts this [UserProfileEntity] to a JSON map.
  Map<String, dynamic> toJson() {
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
    };
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    phoneNumber,
    avatarUrl,
    isVerified,
    lastActiveAt,
    friends,
    chatRooms,
  ];
}
