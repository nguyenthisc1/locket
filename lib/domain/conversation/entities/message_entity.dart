import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final List<dynamic> attachments;
  final String? replyTo;
  final Map<String, dynamic>? replyInfo;
  final String? forwardedFrom;
  final Map<String, dynamic>? forwardInfo;
  final Map<String, dynamic>? threadInfo;
  final List<Map<String, dynamic>> reactions;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final bool isPinned;
  final List<dynamic> editHistory;
  final Map<String, dynamic> metadata;
  final String? sticker;
  final String? emote;
  final DateTime createdAt;
  final String timestamp;
  final bool isMe;

  const MessageEntity({
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

  factory MessageEntity.empty() => MessageEntity(
    id: '',
    conversationId: '',
    senderId: '',
    senderName: '',
    text: '',
    type: '',
    attachments: const [],
    replyTo: null,
    replyInfo: null,
    forwardedFrom: null,
    forwardInfo: null,
    threadInfo: null,
    reactions: const [],
    isRead: false,
    isEdited: false,
    isDeleted: false,
    isPinned: false,
    editHistory: const [],
    metadata: const {},
    sticker: null,
    emote: null,
    createdAt: DateTime.now(),
    timestamp: '',
    isMe: false,
  );

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    String? type,
    List<dynamic>? attachments,
    String? replyTo,
    Map<String, dynamic>? replyInfo,
    String? forwardedFrom,
    Map<String, dynamic>? forwardInfo,
    Map<String, dynamic>? threadInfo,
    List<Map<String, dynamic>>? reactions,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    bool? isPinned,
    List<dynamic>? editHistory,
    Map<String, dynamic>? metadata,
    String? sticker,
    String? emote,
    DateTime? createdAt,
    String? timestamp,
    bool? isMe,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      type: type ?? this.type,
      attachments: attachments ?? List<dynamic>.from(this.attachments),
      replyTo: replyTo ?? this.replyTo,
      replyInfo:
          replyInfo ??
          (this.replyInfo != null
              ? Map<String, dynamic>.from(this.replyInfo!)
              : null),
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      forwardInfo:
          forwardInfo ??
          (this.forwardInfo != null
              ? Map<String, dynamic>.from(this.forwardInfo!)
              : null),
      threadInfo:
          threadInfo ??
          (this.threadInfo != null
              ? Map<String, dynamic>.from(this.threadInfo!)
              : null),
      reactions: reactions ?? List<Map<String, dynamic>>.from(this.reactions),
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      editHistory: editHistory ?? List<dynamic>.from(this.editHistory),
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      sticker: sticker ?? this.sticker,
      emote: emote ?? this.emote,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    text,
    type,
    attachments,
    replyTo,
    replyInfo,
    forwardedFrom,
    forwardInfo,
    threadInfo,
    reactions,
    isRead,
    isEdited,
    isDeleted,
    isPinned,
    editHistory,
    metadata,
    sticker,
    emote,
    createdAt,
    timestamp,
    isMe,
  ];
}
