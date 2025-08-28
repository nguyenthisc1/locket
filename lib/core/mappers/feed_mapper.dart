import 'package:locket/data/feed/models/feed_model.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';

class FeedMapper {
  static FeedEntity toEntity(FeedModel model) {
    return FeedEntity(
      id: model.id,
      user: model.user,
      imageUrl: model.imageUrl,
      publicId: model.publicId,
      caption: model.caption,
      sharedWith: model.sharedWith,
      location: model.location,
      reactions: model.reactions,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      mediaType: model.mediaType,
      format: model.format,
      width: model.width,
      height: model.height,
      fileSize: model.fileSize,
      duration: model.duration, 
    );
  }

  static FeedModel fromEntity(FeedEntity entity) {
    return FeedModel(
      id: entity.id,
      user: entity.user,
      imageUrl: entity.imageUrl,
      publicId: entity.publicId,
      caption: entity.caption,
      sharedWith: entity.sharedWith,
      location: entity.location,
      reactions: entity.reactions,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      mediaType: entity.mediaType,
      format: entity.format,
      width: entity.width,
      height: entity.height,
      fileSize: entity.fileSize,
      duration: entity.duration, 
    );
  }

  static FeedModel toModel(FeedEntity entity) {
    return fromEntity(entity);
  }

  static List<FeedEntity> toEntityList(List<FeedModel> models) =>
      models.map(toEntity).toList();

  static List<FeedModel> fromEntityList(List<FeedEntity> entities) =>
      entities.map(fromEntity).toList();

  static List<FeedModel> toModelList(List<FeedEntity> entities) =>
      entities.map(toModel).toList();
}