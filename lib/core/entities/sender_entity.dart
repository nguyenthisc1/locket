import 'package:equatable/equatable.dart';

class SenderEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const SenderEntity({
    required this.id,
   required this.username,
    this.avatarUrl,
  });

  factory SenderEntity.fromJson(Map<String, dynamic> json) {
    return SenderEntity(
      id: (json['_id'] ?? json['id']) as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatarUrl': avatarUrl,
      };

  @override
  List<Object?> get props => [id, username, avatarUrl];
}
