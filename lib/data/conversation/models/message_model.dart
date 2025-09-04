import 'package:locket/domain/conversation/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final List<Map<String, dynamic>> attachments;
  final String? replyTo;
  final ReplyInfoEntity? replyInfo;
  final String? forwardedFrom;
  final Map<String, dynamic>? forwardInfo;
  final Map<String, dynamic>? threadInfo;
  final List<Map<String, dynamic>> reactions;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final bool isPinned;
  final List<Map<String, dynamic>> editHistory;
  final Map<String, dynamic> metadata;
  final String? sticker;
  final String? emote;
  final DateTime createdAt;
  final String timestamp;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.attachments,
    this.replyTo,
    this.replyInfo,
    this.forwardedFrom,
    this.forwardInfo,
    this.threadInfo,
    required this.reactions,
    required this.isRead,
    required this.isEdited,
    required this.isDeleted,
    required this.isPinned,
    required this.editHistory,
    required this.metadata,
    this.sticker,
    this.emote,
    required this.createdAt,
    required this.timestamp,
    required this.isMe,
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
      attachments: map['attachments'] is List
          ? List<Map<String, dynamic>>.from(map['attachments'])
          : const [],
      replyTo: map['replyTo'],
      replyInfo: map['replyInfo'] is Map<String, dynamic>
          ? ReplyInfoEntity.fromJson(
              Map<String, dynamic>.from(map['replyInfo']),
            )
          : null,
      forwardedFrom: map['forwardedFrom'],
      forwardInfo: map['forwardInfo'] is Map
          ? Map<String, dynamic>.from(map['forwardInfo'])
          : null,
      threadInfo: map['threadInfo'] is Map
          ? Map<String, dynamic>.from(map['threadInfo'])
          : null,
      reactions: map['reactions'] is List
          ? List<Map<String, dynamic>>.from(map['reactions'])
          : const [],
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      isPinned: map['isPinned'] ?? false,
      editHistory: map['editHistory'] is List
          ? List<Map<String, dynamic>>.from(map['editHistory'])
          : const [],
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'])
          : const {},
      sticker: map['sticker'],
      emote: map['emote'],
      createdAt: _parseCreatedAt(map['createdAt']),
      timestamp: map['timestamp'] ?? '',
      isMe: map['isMe'] ?? false,
    );
  }

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseCreatedAt(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      attachments: json['attachments'] is List
          ? List<Map<String, dynamic>>.from(json['attachments'])
          : const [],
      replyTo: json['replyTo'],
      replyInfo: json['replyInfo'] is Map<String, dynamic>
          ? ReplyInfoEntity.fromJson(
              Map<String, dynamic>.from(json['replyInfo']),
            )
          : null,
      forwardedFrom: json['forwardedFrom'],
      forwardInfo: json['forwardInfo'] is Map
          ? Map<String, dynamic>.from(json['forwardInfo'])
          : null,
      threadInfo: json['threadInfo'] is Map
          ? Map<String, dynamic>.from(json['threadInfo'])
          : null,
      reactions: json['reactions'] is List
          ? List<Map<String, dynamic>>.from(json['reactions'])
          : const [],
      isRead: json['isRead'] ?? false,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      editHistory: json['editHistory'] is List
          ? List<Map<String, dynamic>>.from(json['editHistory'])
          : const [],
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : const {},
      sticker: json['sticker'],
      emote: json['emote'],
      createdAt: _parseCreatedAt(json['createdAt']),
      timestamp: json['timestamp'] ?? '',
      isMe: json['isMe'] ?? false,
    );
  }

  /// Converts this [MessageModel] to a map (e.g., for JSON or database).
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

  /// Converts this [MessageModel] to a JSON map.
  Map<String, dynamic> toJson() => toMap();
}
