import 'package:equatable/equatable.dart';
import 'package:locket/core/models/location_model.dart';
import 'package:locket/core/models/reaction_model.dart';
import 'package:locket/core/models/share_with_user_model.dart';

class FeedUser extends Equatable {
  final String id;
  final String username;
  final String avatarUrl;

  const FeedUser({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

enum MediaType { image, video }

class FeedEntity extends Equatable {
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

  const FeedEntity({
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

  /// Helper getters for media type detection
  /// Since API has inconsistent mediaType, we check format for video detection
  bool get isVideo => format.toLowerCase() == 'mp4' || format.toLowerCase() == 'mov' || format.toLowerCase() == 'avi';
  bool get isImage => !isVideo;
  
  /// Get actual media type based on format
  MediaType get actualMediaType => isVideo ? MediaType.video : MediaType.image;
  
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

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