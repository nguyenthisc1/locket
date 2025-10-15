import 'package:locket/data/media/models/media_feed.dart';
import 'package:locket/domain/media/entities/media_feed_entity.dart';

class MediaFeedMapper {
  static MediaFeedEntity toEntity(MediaFeedModel model) {
    return MediaFeedEntity(
      url: model.url,
      publicId: model.publicId,
      mediaType: model.mediaType,
      isFrontCamera: model.isFrontCamera,
      location: model.location,
      duration: model.duration,
      format: model.format,
      width: model.width,
      height: model.height,
      fileSize: model.fileSize,
    );
  }

  static MediaFeedModel fromEntity(MediaFeedEntity entity) {
    return MediaFeedModel(
      url: entity.url,
      publicId: entity.publicId,
      mediaType: entity.mediaType,
      isFrontCamera: entity.isFrontCamera,
      location: entity.location,
      duration: entity.duration,
      format: entity.format,
      width: entity.width,
      height: entity.height,
      fileSize: entity.fileSize,
    );
  }

  static MediaFeedModel toModel(MediaFeedEntity entity) {
    return fromEntity(entity);
  }

  static List<MediaFeedEntity> toEntityList(List<MediaFeedModel> models) =>
      models.map(toEntity).toList();

  static List<MediaFeedModel> fromEntityList(List<MediaFeedEntity> entities) =>
      entities.map(fromEntity).toList();

  static List<MediaFeedModel> toModelList(List<MediaFeedEntity> entities) =>
      entities.map(toModel).toList();
}
