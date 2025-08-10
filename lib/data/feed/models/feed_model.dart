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
  
  // New media properties
  final MediaType mediaType;
  final String format;
  final int width;
  final int height;
  final int fileSize;

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
    this.mediaType = MediaType.image,
    this.format = 'jpg',
    this.width = 0,
    this.height = 0,
    this.fileSize = 0,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    // Handle both nested and simple photo structure
    Map<String, dynamic>? photoData;
    
    // Check if it's the new simple structure (direct photo object)
    if (json.containsKey('id') && json.containsKey('userId')) {
      photoData = json;
    } else {
      // Old nested structure
      photoData = json['photo']?['photo'] as Map<String, dynamic>?;
    }
    
    if (photoData == null) {
      throw Exception('Invalid feed format: missing photo data');
    }

    // Extract user information
    FeedUser extractUser(dynamic userField) {
      if (userField is String) {
        return FeedUser(id: userField, username: '', avatarUrl: '');
      } else if (userField is Map<String, dynamic>) {
        final id = userField['_id'] as String? ?? userField['id'] as String?;
        final username = userField['username'] as String? ?? '';
        final avatarUrl = userField['avatarUrl'] as String? ?? '';
        if (id != null) {
          return FeedUser(id: id, username: username, avatarUrl: avatarUrl);
        }
      }
      throw Exception('Invalid user format');
    }

    // Parse media type - check format since API mediaType is inconsistent
    MediaType parseMediaType(String? type, String? format) {
      // First check format since it's more reliable
      if (format?.toLowerCase() == 'mp4' || format?.toLowerCase() == 'mov' || format?.toLowerCase() == 'avi') {
        return MediaType.video;
      }
      
      // Fallback to mediaType field
      switch (type?.toLowerCase()) {
        case 'video':
          return MediaType.video;
        case 'image':
        default:
          return MediaType.image;
      }
    }

    return FeedModel(
      id: photoData['id'] as String? ?? photoData['_id'] as String,
      user: extractUser(photoData['userId']),
      imageUrl: photoData['imageUrl'] as String,
      publicId: photoData['publicId'] as String?,
      caption: photoData['caption'] as String?,
      sharedWith: (photoData['sharedWith'] as List<dynamic>?)
              ?.map((e) => SharedWithUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      location: photoData['location'] != null
          ? LocationModel.fromJson(photoData['location'] as Map<String, dynamic>)
          : null,
      reactions: (photoData['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(photoData['createdAt'] as String),
      updatedAt: photoData['updatedAt'] != null
          ? DateTime.tryParse(photoData['updatedAt'] as String)
          : null,
      format: photoData['format'] as String? ??  'jpg',
      mediaType: parseMediaType(photoData['mediaType'] as String?, photoData['format'] as String?),
      width: photoData['width'] as int? ?? 0,
      height: photoData['height'] as int? ?? 0,
      fileSize: photoData['fileSize'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'photo': {
          'photo': {
            'id': id,
            'userId': {
              '_id': user.id,
              'username': user.username,
              'avatarUrl': user.avatarUrl,
            },
            'imageUrl': imageUrl,
            'caption': caption,
            'sharedWith': sharedWith.map((u) => u.toJson()).toList(),
            'location': location?.toJson(),
            'reactions': reactions.map((r) => r.toJson()).toList(),
            'mediaType': mediaType == MediaType.video ? 'video' : 'image',
            'format': format,
            'width': width,
            'height': height,
            'fileSize': fileSize,
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          },
          'user': null,
        },
     
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
        mediaType,
        format,
        width,
        height,
        fileSize,
      ];
}