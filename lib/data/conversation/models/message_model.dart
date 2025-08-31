import 'package:locket/domain/conversation/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.type,
    required super.attachments,
    super.replyTo,
    super.replyInfo,
    super.forwardedFrom,
    super.forwardInfo,
    super.threadInfo,
    required super.reactions,
    required super.isRead,
    required super.isEdited,
    required super.isDeleted,
    required super.isPinned,
    required super.editHistory,
    required super.metadata,
    super.sticker,
    super.emote,
    required super.createdAt,
    required super.timestamp,
    required super.isMe,
  });

  /// Creates a [MessageModel] from a map (e.g., from JSON or database).
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime _parseCreatedAt(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? '',
      attachments:
          map['attachments'] is List
              ? List<Map<String, dynamic>>.from(map['attachments'])
              : const [],
      replyTo: map['replyTo'],
      replyInfo:
          map['replyInfo'] is Map<String, dynamic>
              ? ReplyInfoEntity.fromJson(
                Map<String, dynamic>.from(map['replyInfo']),
              )
              : null,
      forwardedFrom: map['forwardedFrom'],
      forwardInfo:
          map['forwardInfo'] is Map
              ? Map<String, dynamic>.from(map['forwardInfo'])
              : null,
      threadInfo:
          map['threadInfo'] is Map
              ? Map<String, dynamic>.from(map['threadInfo'])
              : null,
      reactions:
          map['reactions'] is List
              ? List<Map<String, dynamic>>.from(map['reactions'])
              : const [],
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      isPinned: map['isPinned'] ?? false,
      editHistory:
          map['editHistory'] is List
              ? List<Map<String, dynamic>>.from(map['editHistory'])
              : const [],
      metadata:
          map['metadata'] is Map
              ? Map<String, dynamic>.from(map['metadata'])
              : const {},
      sticker: map['sticker'],
      emote: map['emote'],
      createdAt: _parseCreatedAt(map['createdAt']),
      timestamp: map['timestamp'] ?? '',
      isMe: map['isMe'] ?? false,
    );
  }

  /// Converts this [MessageModel] to a map (e.g., for JSON or database).
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type,
      'attachments': attachments,
      'replyTo': replyTo,
      'replyInfo': replyInfo?.toJson(),
      'forwardedFrom': forwardedFrom,
      'forwardInfo': forwardInfo,
      'threadInfo': threadInfo,
      'reactions': reactions,
      'isRead': isRead,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'editHistory': editHistory,
      'metadata': metadata,
      'sticker': sticker,
      'emote': emote,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp,
      'isMe': isMe,
    };
  }

  /// Creates a [MessageModel] from a [MessageEntity].
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      text: entity.text,
      type: entity.type,
      attachments: List<Map<String, dynamic>>.from(entity.attachments),
      replyTo: entity.replyTo,
      replyInfo: entity.replyInfo,
      forwardedFrom: entity.forwardedFrom,
      forwardInfo: entity.forwardInfo,
      threadInfo: entity.threadInfo,
      reactions: List<Map<String, dynamic>>.from(entity.reactions),
      isRead: entity.isRead,
      isEdited: entity.isEdited,
      isDeleted: entity.isDeleted,
      isPinned: entity.isPinned,
      editHistory: List<Map<String, dynamic>>.from(entity.editHistory),
      metadata: Map<String, dynamic>.from(entity.metadata),
      sticker: entity.sticker,
      emote: entity.emote,
      createdAt: entity.createdAt,
      timestamp: entity.timestamp,
      isMe: entity.isMe,
    );
  }
}
