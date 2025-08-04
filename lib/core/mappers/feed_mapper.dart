import 'package:locket/data/feed/models/feed_model.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';

class FeedMapper {
  static FeedEntity toEntity(FeedModel model) {
    return FeedEntity(
      id: model.id,
      userId: model.userId,
      imageUrl: model.imageUrl,
      publicId: model.publicId,
      caption: model.caption,
      sharedWith: model.sharedWith,
      location: model.location,
      reactions: model.reactions,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static FeedModel fromEntity(FeedEntity entity) {
    return FeedModel(
      id: entity.id,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      publicId: entity.publicId,
      caption: entity.caption,
      sharedWith: entity.sharedWith,
      location: entity.location,
      reactions: entity.reactions,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

    static FeedModel toModel(FeedModel model) {
    return FeedModel(
      id: model.id,
      userId: model.userId,
      imageUrl: model.imageUrl,
      publicId: model.publicId,
      caption: model.caption,
      sharedWith: model.sharedWith,
      location: model.location,
      reactions: model.reactions,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static List<FeedEntity> toEntityList(List<FeedModel> models) =>
    models.map(toEntity).toList();
}
