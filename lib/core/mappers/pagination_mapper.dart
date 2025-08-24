import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/entities/pagination_entity.dart';

class PaginationMapper {
  static PaginationEntity toEntity(PaginationModel model) {
    return PaginationEntity(
      limit: model.limit,
      hasNextPage: model.hasNextPage,
      nextCursor: model.nextCursor,
    );
  }

  static PaginationModel fromEntity(PaginationEntity entity) {
    return PaginationModel(
      limit: entity.limit,
      hasNextPage: entity.hasNextPage,
      nextCursor: entity.nextCursor,
    );
  }

  static PaginationModel toModel(PaginationEntity entity) {
    return fromEntity(entity);
  }
}
