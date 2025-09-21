import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/models/last_message_model.dart';
import 'package:locket/core/models/sender_model.dart';

class LastMessageMapper {
  /// Converts a LastMessageModel to a LastMessageEntity
  static LastMessageEntity toEntity(LastMessageModel model) {
    return LastMessageEntity(
      messageId: model.messageId,
      text: model.text,
      sender: model.sender.toEntity(),
      timestamp: model.timestamp,
    );
  }

  /// Converts a LastMessageEntity to a LastMessageModel
  static LastMessageModel toModel(LastMessageEntity entity) {
    return LastMessageModel(
      messageId: entity.messageId,
      text: entity.text,
      sender: SenderModel.fromEntity(entity.sender),
      timestamp: entity.timestamp,
    );
  }
}
