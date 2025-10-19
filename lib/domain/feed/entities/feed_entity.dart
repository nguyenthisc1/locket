import 'package:equatable/equatable.dart';
import 'package:locket/core/models/location_model.dart';
import 'package:locket/core/models/reaction_model.dart';
import 'package:locket/core/models/share_with_user_model.dart';

class FeedUser extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const FeedUser({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

enum MediaType { image, video }

enum FeedStatus { draft, uploading, uploaded, failed }

class FeedEntity extends Equatable {
  final String id;
  final FeedUser user;
  final String imageUrl; 
  final String? publicId;
  final String? caption;
  final bool isFrontCamera;
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
  final double? duration;
  
  // Upload status
  final FeedStatus status;

  const FeedEntity({
    required this.id,
    required this.user,
    required this.imageUrl,
    this.publicId,
    this.caption,
    this.isFrontCamera = true,
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
    this.duration,
    this.status = FeedStatus.uploaded,
  });

  /// Helper getters for media type detection
  /// Since API has inconsistent mediaType, we check format for video detection
  bool get isVideo => format.toLowerCase() == 'mp4' || format.toLowerCase() == 'mov' || format.toLowerCase() == 'avi';
  bool get isImage => !isVideo;
  
  /// Get actual media type based on format
  MediaType get actualMediaType => isVideo ? MediaType.video : MediaType.image;
  
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

  /// Create a copy of this entity with optional parameter overrides
  FeedEntity copyWith({
    String? id,
    FeedUser? user,
    String? imageUrl,
    String? publicId,
    String? caption,
    bool? isFrontCamera,
    List<SharedWithUser>? sharedWith,
    LocationModel? location,
    List<ReactionModel>? reactions,
    DateTime? createdAt,
    DateTime? updatedAt,
    MediaType? mediaType,
    String? format,
    int? width,
    int? height,
    int? fileSize,
    double? duration,
    FeedStatus? status,
  }) {
    return FeedEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      publicId: publicId ?? this.publicId,
      caption: caption ?? this.caption,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      sharedWith: sharedWith ?? this.sharedWith,
      location: location ?? this.location,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaType: mediaType ?? this.mediaType,
      format: format ?? this.format,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        imageUrl,
        publicId,
        caption,
        isFrontCamera,
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
        duration,
        status,
      ];
}