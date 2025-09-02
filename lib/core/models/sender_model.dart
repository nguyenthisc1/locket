import 'package:equatable/equatable.dart';
import 'package:locket/core/entities/sender_entity.dart';

class SenderModel extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const SenderModel({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: (json['_id'] ?? json['id']) as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }

  /// Creates a SenderModel from a SenderEntity
  factory SenderModel.fromEntity(SenderEntity entity) {
    return SenderModel(
      id: entity.id,
      username: entity.username,
      avatarUrl: entity.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, username, avatarUrl];
}