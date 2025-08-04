import 'package:equatable/equatable.dart';
import 'package:locket/core/models/location_model.dart';
import 'package:locket/core/models/reaction_model.dart';
import 'package:locket/core/models/share_with_user_model.dart';

class FeedEntity extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String? publicId;
  final String? caption;
  final List<SharedWithUser> sharedWith;
  final LocationModel? location;
  final List<ReactionModel> reactions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedEntity({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.publicId,
    this.caption,
    this.sharedWith = const [],
    this.location,
    this.reactions = const [],
    required this.createdAt,
    this.updatedAt,
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
}
