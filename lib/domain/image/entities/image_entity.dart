import 'package:equatable/equatable.dart';

class ReactionEntity extends Equatable {
  final String userId;
  final String type; // e.g., ❤️ 😂 😮 etc.
  final DateTime createdAt;

  const ReactionEntity({
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, type, createdAt];

  ReactionEntity copyWith({String? userId, String? type, DateTime? createdAt}) {
    return ReactionEntity(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LocationEntity extends Equatable {
  final double lat;
  final double lng;

  const LocationEntity({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];

  LocationEntity copyWith({double? lat, double? lng}) {
    return LocationEntity(lat: lat ?? this.lat, lng: lng ?? this.lng);
  }
}

class ImageEntity extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String? publicId;
  final String? caption;
  final List<String>? sharedWith;
  final LocationEntity? location;
  final List<ReactionEntity> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ImageEntity({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.publicId,
    this.caption,
    this.sharedWith,
    this.location,
    this.reactions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    publicId,
    caption,
    sharedWith,
    location,
    reactions,
    createdAt,
    updatedAt,
  ];

  ImageEntity copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? publicId,
    String? caption,
    List<String>? sharedWith,
    LocationEntity? location,
    List<ReactionEntity>? reactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImageEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      publicId: publicId ?? this.publicId,
      caption: caption ?? this.caption,
      sharedWith: sharedWith ?? this.sharedWith,
      location: location ?? this.location,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
