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

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? '',
      attachments:
          map['attachments'] != null
              ? List<dynamic>.from(map['attachments'])
              : const [],
      replyTo: map['replyTo'],
      replyInfo:
          map['replyInfo'] != null
              ? Map<String, dynamic>.from(map['replyInfo'])
              : null,
      forwardedFrom: map['forwardedFrom'],
      forwardInfo:
          map['forwardInfo'] != null
              ? Map<String, dynamic>.from(map['forwardInfo'])
              : null,
      threadInfo:
          map['threadInfo'] != null
              ? Map<String, dynamic>.from(map['threadInfo'])
              : null,
      reactions:
          map['reactions'] != null
              ? List<Map<String, dynamic>>.from(map['reactions'])
              : const [],
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      isPinned: map['isPinned'] ?? false,
      editHistory:
          map['editHistory'] != null
              ? List<dynamic>.from(map['editHistory'])
              : const [],
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(map['metadata'])
              : const {},
      sticker: map['sticker'],
      emote: map['emote'],
      createdAt:
          map['createdAt'] is DateTime
              ? map['createdAt']
              : map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
      timestamp: map['timestamp'] ?? '',
      isMe: map['isMe'] ?? false,
    );
  }

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
      'replyInfo': replyInfo,
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
}
