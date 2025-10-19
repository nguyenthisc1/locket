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
  final bool isFrontCamera;
  final List<SharedWithUser> sharedWith;
  final LocationModel? location;
  final List<ReactionModel> reactions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Media properties
  final MediaType mediaType;
  final String format;
  final int width;
  final int height;
  final int fileSize;
  final double? duration; // Duration field for videos

  // Upload status
  final FeedStatus status;

  const FeedModel({
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

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    // Defensive checks for required fields
    final idVal = json['id']?.toString() ?? '';
    final imageUrlVal = json['imageUrl']?.toString() ?? '';

    // Null safety: handle case where user can be missing at root or set to null
    FeedUser extractUser(dynamic userField) {
      if (userField == null) {
        return FeedUser(id: '', username: '', avatarUrl: '');
      }
      if (userField is String) {
        return FeedUser(id: userField, username: '', avatarUrl: '');
      } else if (userField is Map<String, dynamic>) {
        final id =
            userField['_id'] as String? ?? userField['id'] as String? ?? '';
        final username = userField['username'] as String? ?? '';
        final avatarUrl = userField['avatarUrl'] as String?;
        return FeedUser(id: id, username: username, avatarUrl: avatarUrl);
      }
      throw Exception('Invalid user format');
    }

    // Parse media type - check format since API mediaType is inconsistent
    MediaType parseMediaType(String? type, String? format) {
      if (format?.toLowerCase() == 'mp4' ||
          format?.toLowerCase() == 'mov' ||
          format?.toLowerCase() == 'avi') {
        return MediaType.video;
      }
      switch (type?.toLowerCase()) {
        case 'video':
          return MediaType.video;
        case 'image':
        default:
          return MediaType.image;
      }
    }

    // Parse feed status
    FeedStatus parseStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'draft':
          return FeedStatus.draft;
        case 'uploading':
          return FeedStatus.uploading;
        case 'uploaded':
          return FeedStatus.uploaded;
        case 'failed':
          return FeedStatus.failed;
        default:
          return FeedStatus.uploaded; // Default to uploaded for server feeds
      }
    }

    return FeedModel(
      id: idVal,
      user: extractUser(json['user']),
      imageUrl: imageUrlVal,
      publicId: json['publicId']?.toString(),
      caption: json['caption']?.toString(),
      isFrontCamera:
          json['isFrontCamera'] is bool
              ? json['isFrontCamera'] as bool
              : json['isFrontCamera']?.toString().toLowerCase() == 'true',
      sharedWith:
          (json['sharedWith'] as List<dynamic>? ?? [])
              .map(
                (u) =>
                    u is Map<String, dynamic>
                        ? SharedWithUser.fromJson(u)
                        : SharedWithUser.fromJson(
                          Map<String, dynamic>.from(u as Map),
                        ),
              ) // fallback
              .toList(),
      location:
          json['location'] != null
              ? LocationModel.fromJson(
                Map<String, dynamic>.from(json['location']),
              )
              : null,
      reactions:
          (json['reactions'] as List<dynamic>? ?? [])
              .map(
                (r) =>
                    r is Map<String, dynamic>
                        ? ReactionModel.fromJson(r)
                        : ReactionModel.fromJson(
                          Map<String, dynamic>.from(r as Map),
                        ),
              ) // fallback
              .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
      mediaType: parseMediaType(
        json['mediaType']?.toString(),
        json['format']?.toString(),
      ),
      format: json['format']?.toString() ?? 'jpg',
      width:
          json['width'] is int
              ? json['width'] as int
              : int.tryParse('${json['width'] ?? "0"}') ?? 0,
      height:
          json['height'] is int
              ? json['height'] as int
              : int.tryParse('${json['height'] ?? "0"}') ?? 0,
      fileSize:
          json['fileSize'] is int
              ? json['fileSize'] as int
              : int.tryParse('${json['fileSize'] ?? "0"}') ?? 0,
      duration:
          json['duration'] is double
              ? json['duration'] as double
              : (json['duration'] != null
                  ? double.tryParse('${json['duration']}')
                  : null),
      status: parseStatus(json['status']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': {
      '_id': user.id,
      'username': user.username,
      'avatarUrl': user.avatarUrl,
    },
    'imageUrl': imageUrl,
    'caption': caption,
    'isFrontCamera': isFrontCamera,
    'sharedWith': sharedWith.map((u) => u.toJson()).toList(),
    'location': location?.toJson(),
    'reactions': reactions.map((r) => r.toJson()).toList(),
    'mediaType': mediaType == MediaType.video ? 'video' : 'image',
    'format': format,
    'width': width,
    'height': height,
    'fileSize': fileSize,
    'duration': duration,
    'status': status.name,
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
