import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? lastActiveAt;
  final List<String> friends;
  final List<String> chatRooms;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.username,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    this.lastActiveAt,
    List<String>? friends,
    List<String>? chatRooms,
    DateTime? createdAt,
  }) : friends = friends ?? const [],
       chatRooms = chatRooms ?? const [],
       createdAt = createdAt ?? DateTime.now();

  factory UserEntity.empty() => UserEntity(
    id: '',
    username: '',
    email: null,
    phoneNumber: null,
    avatarUrl: null,
    isVerified: false,
    lastActiveAt: null,
    friends: const [],
    chatRooms: const [],
    createdAt: DateTime.now(),
  );

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? passwordHash,
    String? avatarUrl,
    bool? isVerified,
    DateTime? lastActiveAt,
    List<String>? friends,
    List<String>? chatRooms,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      friends: friends ?? List<String>.from(this.friends),
      chatRooms: chatRooms ?? List<String>.from(this.chatRooms),
      createdAt: createdAt ?? this.createdAt,
    );
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
    createdAt,
  ];
}
