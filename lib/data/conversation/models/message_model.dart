import 'package:locket/common/helper/utils.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String type;
  final List<Map<String, dynamic>> attachments;
  final String? replyTo;
  final ReplyInfoEntity? replyInfo;
  final String? forwardedFrom;
  final Map<String, dynamic>? forwardInfo;
  final Map<String, dynamic>? threadInfo;
  final List<Map<String, dynamic>> reactions;
  final MessageStatus messageStatus;
  final bool isEdited;
  final bool isDeleted;
  final bool isPinned;
  final List<Map<String, dynamic>> editHistory;
  final Map<String, dynamic> metadata;
  final String? sticker;
  final String? emote;
  final DateTime? updatedAt;
  final DateTime createdAt;
  final String timestamp;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.type,
    required this.attachments,
    this.replyTo,
    this.replyInfo,
    this.forwardedFrom,
    this.forwardInfo,
    this.threadInfo,
    required this.reactions,
    this.messageStatus = MessageStatus.sent,
    required this.isEdited,
    required this.isDeleted,
    required this.isPinned,
    required this.editHistory,
    required this.metadata,
    this.sticker,
    this.emote,
    this.updatedAt,
    required this.createdAt,
    required this.timestamp,
  });

  // Static helper methods for parsing (deprecated - use DateTimeUtils instead)
  static DateTime _parseCreatedAt(dynamic value) {
    return DateTimeUtils.parseDateTime(value);
  }

  static DateTime? _parseUpdatedAt(dynamic value) {
    return DateTimeUtils.parseDateTimeNullable(value);
  }

  static String _extractSenderId(dynamic senderIdValue) {
    if (senderIdValue is String) {
      return senderIdValue;
    } else if (senderIdValue is Map<String, dynamic>) {
      // Extract ID from sender object: {"_id": "...", "username": "...", "avatarUrl": "..."}
      return senderIdValue['_id'] ?? senderIdValue['id'] ?? '';
    }
    return '';
  }

  static String? _extractStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // If it's an empty object, return null
      if (value.isEmpty) return null;
      // If it has content, try to extract a meaningful string
      return value.toString();
    }
    return null;
  }

  /// Helper method to convert MessageStatus enum to string
  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  /// Helper method to parse MessageStatus from dynamic value
  static MessageStatus _parseMessageStatus(dynamic value) {
    if (value is MessageStatus) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'sent':
          return MessageStatus.sent;
        case 'delivered':
          return MessageStatus.delivered;
        case 'read':
          return MessageStatus.read;
        case 'failed':
          return MessageStatus.failed;
        default:
          return MessageStatus.sent;
      }
    }
    return MessageStatus.sent;
  }

  /// Creates a [MessageModel] from a map (e.g., from JSON or database).
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: _extractSenderId(map['senderId']),
      text: map['text'] ?? '',
      type: map['type'] ?? '',
      attachments:
          map['attachments'] is List
              ? List<Map<String, dynamic>>.from(map['attachments'])
              : const [],
      replyTo: _extractStringOrNull(map['replyTo']),
      replyInfo:
          map['replyInfo'] is Map<String, dynamic>
              ? ReplyInfoEntity.fromJson(
                Map<String, dynamic>.from(map['replyInfo']),
              )
              : null,
      forwardedFrom: _extractStringOrNull(map['forwardedFrom']),
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
      messageStatus: _parseMessageStatus(map['messageStatus'] ?? map['status']),
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
      sticker: _extractStringOrNull(map['sticker']),
      emote: _extractStringOrNull(map['emote']),
      updatedAt: _parseUpdatedAt(map['updatedAt']),
      createdAt: _parseCreatedAt(map['createdAt']),
      timestamp: map['timestamp'] ?? '',
    );
  }

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    try {
      return MessageModel(
        id: json['id'] ?? '',
        conversationId: json['conversationId'] ?? '',
        senderId: _extractSenderId(json['senderId']),
        text: json['text'] ?? '',
        type: json['type'] ?? '',
        attachments:
            json['attachments'] is List
                ? List<Map<String, dynamic>>.from(json['attachments'])
                : const [],
        replyTo: _extractStringOrNull(json['replyTo']),
        replyInfo:
            json['replyInfo'] is Map<String, dynamic>
                ? ReplyInfoEntity.fromJson(
                  Map<String, dynamic>.from(json['replyInfo']),
                )
                : null,
        forwardedFrom: _extractStringOrNull(json['forwardedFrom']),
        forwardInfo:
            json['forwardInfo'] is Map
                ? Map<String, dynamic>.from(json['forwardInfo'])
                : null,
        threadInfo:
            json['threadInfo'] is Map
                ? Map<String, dynamic>.from(json['threadInfo'])
                : null,
        reactions:
            json['reactions'] is List
                ? List<Map<String, dynamic>>.from(json['reactions'])
                : const [],
        messageStatus: _parseMessageStatus(
          json['messageStatus'] ?? json['status'],
        ),
        isEdited: json['isEdited'] ?? false,
        isDeleted: json['isDeleted'] ?? false,
        isPinned: json['isPinned'] ?? false,
        editHistory:
            json['editHistory'] is List
                ? List<Map<String, dynamic>>.from(json['editHistory'])
                : const [],
        metadata:
            json['metadata'] is Map
                ? Map<String, dynamic>.from(json['metadata'])
                : const {},
        sticker: _extractStringOrNull(json['sticker']),
        emote: _extractStringOrNull(json['emote']),
        updatedAt: _parseUpdatedAt(json['updatedAt']),
        createdAt: _parseCreatedAt(json['createdAt']),
        timestamp: json['timestamp'] ?? '',
      );
    } catch (e) {
      // Log the error and the problematic JSON for debugging
      print('❌ Error parsing MessageModel from JSON: $e');
      print('📄 Problematic JSON: $json');

      // Return a minimal valid MessageModel to prevent app crash
      return MessageModel(
        id: json['id']?.toString() ?? '',
        conversationId: json['conversationId']?.toString() ?? '',
        senderId: _extractSenderId(json['senderId']),
        text: json['text']?.toString() ?? '',
        type: json['type']?.toString() ?? 'text',
        attachments: const [],
        replyTo: null,
        replyInfo: null,
        forwardedFrom: null,
        forwardInfo: null,
        threadInfo: null,
        reactions: const [],
        messageStatus: MessageStatus.failed,
        isEdited: false,
        isDeleted: false,
        isPinned: false,
        editHistory: const [],
        metadata: const {},
        sticker: null,
        emote: null,
        updatedAt: _parseUpdatedAt(json['updatedAt']),
        createdAt: _parseCreatedAt(json['createdAt']),
        timestamp: json['timestamp']?.toString() ?? '',
      );
    }
  }

  /// Converts this [MessageModel] to a map (e.g., for JSON or database).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'attachments': attachments,
      'replyTo': replyTo,
      'replyInfo': replyInfo?.toJson(),
      'forwardedFrom': forwardedFrom,
      'forwardInfo': forwardInfo,
      'threadInfo': threadInfo,
      'reactions': reactions,
      'messageStatus': _messageStatusToString(messageStatus),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'editHistory': editHistory,
      'metadata': metadata,
      'sticker': sticker,
      'emote': emote,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp,
    };
  }

  /// Converts this [MessageModel] to a JSON map.
  Map<String, dynamic> toJson() => toMap();
}
