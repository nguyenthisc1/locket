import 'package:equatable/equatable.dart';
import 'package:locket/core/models/location_model.dart';
import 'package:locket/core/models/reaction_model.dart';
import 'package:locket/core/models/share_with_user_model.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';

class FeedModel extends Equatable {
  final String id;
  final FeedUser user;
  final String imageUrl;
  final String? publicId;
  final String? caption;
  final List<SharedWithUser> sharedWith;
  final LocationModel? location;
  final List<ReactionModel> reactions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedModel({
    required this.id,
    required this.user,
    required this.imageUrl,
    this.publicId,
    this.caption,
    this.sharedWith = const [],
    this.location,
    this.reactions = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    // Handle user as either a string (id) or an object with _id and username
    FeedUser extractUser(dynamic userField) {
      if (userField is String) {
        // Only id is available, username unknown
        return FeedUser(id: userField, username: '');
      } else if (userField is Map<String, dynamic>) {
        final id = userField['_id'] as String? ?? userField['id'] as String?;
        final username = userField['username'] as String? ?? '';
        if (id != null) {
          return FeedUser(id: id, username: username);
        }
      }
      throw Exception('Invalid user format');
    }

    return FeedModel(
      id: json['_id'] as String? ?? json['id'] as String,
      user: extractUser(json['userId']),
      imageUrl: json['imageUrl'] as String,
      publicId: json['publicId'] as String?,
      caption: json['caption'] as String?,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => SharedWithUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': {
          '_id': user.id,
          'username': user.username,
        },
        'imageUrl': imageUrl,
        'publicId': publicId,
        'caption': caption,
        'sharedWith': sharedWith.map((u) => u.toJson()).toList(),
        'location': location?.toJson(),
        'reactions': reactions.map((r) => r.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        user,
        imageUrl,
        publicId,
        caption,
        sharedWith,
        location,
        reactions,
        createdAt,
        updatedAt,
      ];
}
