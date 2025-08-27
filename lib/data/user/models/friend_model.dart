
import 'package:equatable/equatable.dart';

class FriendProfileModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;

  const FriendProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  factory FriendProfileModel.fromJson(Map<String, dynamic> json) {
    return FriendProfileModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, username, email, avatarUrl];
}
