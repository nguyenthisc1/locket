import 'package:equatable/equatable.dart';
import 'package:locket/domain/image/entities/image_entity.dart';

class ReactionModel extends Equatable {
  final String userId;
  final String type;
  final DateTime createdAt;

  const ReactionModel({
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory ReactionModel.fromEntity(ReactionEntity entity) {
    return ReactionModel(
      userId: entity.userId,
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }

  ReactionEntity toEntity() {
    return ReactionEntity(userId: userId, type: type, createdAt: createdAt);
  }

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      userId: json['userId'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, type, createdAt];
}

class LocationModel extends Equatable {
  final double lat;
  final double lng;

  const LocationModel({required this.lat, required this.lng});

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(lat: entity.lat, lng: entity.lng);
  }

  LocationEntity toEntity() {
    return LocationEntity(lat: lat, lng: lng);
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }

  @override
  List<Object?> get props => [lat, lng];
}

class ImageModel extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String? publicId;
  final String? caption;
  final List<String>? sharedWith;
  final LocationModel? location;
  final List<ReactionModel> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ImageModel({
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

  factory ImageModel.fromEntity(ImageEntity entity) {
    return ImageModel(
      id: entity.id,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      publicId: entity.publicId,
      caption: entity.caption,
      sharedWith: entity.sharedWith,
      location:
          entity.location != null
              ? LocationModel.fromEntity(entity.location!)
              : null,
      reactions:
          entity.reactions.map((e) => ReactionModel.fromEntity(e)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ImageEntity toEntity() {
    return ImageEntity(
      id: id,
      userId: userId,
      imageUrl: imageUrl,
      publicId: publicId,
      caption: caption,
      sharedWith: sharedWith,
      location: location?.toEntity(),
      reactions: reactions.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      publicId: json['publicId'] as String?,
      caption: json['caption'] as String?,
      sharedWith:
          (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      location:
          json['location'] != null
              ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
              : null,
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'publicId': publicId,
      'caption': caption,
      'sharedWith': sharedWith,
      'location': location?.toJson(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
}
