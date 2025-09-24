import 'package:locket/data/conversation/models/message_model.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class MessageMapper {
  static MessageEntity toEntity(MessageModel model) {
    return MessageEntity(
      id: model.id,
      conversationId: model.conversationId,
      senderId: model.senderId,
      text: model.text,
      type: model.type,
      attachments: List<Map<String, dynamic>>.from(model.attachments),
      replyTo: model.replyTo,
      replyInfo: model.replyInfo,
      forwardedFrom: model.forwardedFrom,
      forwardInfo: model.forwardInfo,
      threadInfo: model.threadInfo,
      reactions: List<Map<String, dynamic>>.from(model.reactions),
      messageStatus: model.messageStatus,
      isEdited: model.isEdited,
      isDeleted: model.isDeleted,
      isPinned: model.isPinned,
      editHistory: List<Map<String, dynamic>>.from(model.editHistory),
      metadata: Map<String, dynamic>.from(model.metadata),
      sticker: model.sticker,
      emote: model.emote,
      updatedAt: model.updatedAt,
      createdAt: model.createdAt,
      timestamp: model.timestamp,
    );
  }

  static MessageModel toModel(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      text: entity.text,
      type: entity.type,
      attachments: List<Map<String, dynamic>>.from(entity.attachments),
      replyTo: entity.replyTo,
      replyInfo: entity.replyInfo,
      forwardedFrom: entity.forwardedFrom,
      forwardInfo: entity.forwardInfo,
      threadInfo: entity.threadInfo,
      reactions: List<Map<String, dynamic>>.from(entity.reactions),
      messageStatus: entity.messageStatus,
      isEdited: entity.isEdited,
      isDeleted: entity.isDeleted,
      isPinned: entity.isPinned,
      editHistory: List<Map<String, dynamic>>.from(entity.editHistory),
      metadata: Map<String, dynamic>.from(entity.metadata),
      sticker: entity.sticker,
      emote: entity.emote,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
      timestamp: entity.timestamp,
    );
  }

  static List<MessageEntity> toEntityList(List<MessageModel> models) {
    return models.map((m) => toEntity(m)).toList();
  }

  static List<MessageModel> toModelList(List<MessageEntity> entities) {
    return entities.map((e) => toModel(e)).toList();
  }
}