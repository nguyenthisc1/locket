import 'package:equatable/equatable.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class SenderEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const SenderEntity({
    required this.id,
   required this.username,
    this.avatarUrl,
  });

  factory SenderEntity.fromJson(Map<String, dynamic> json) {
    return SenderEntity(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatarUrl': avatarUrl,
      };

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

class LastMessageEntity extends Equatable {
  final String messageId;
  final String text;
  final SenderEntity sender;
  final DateTime timestamp;
  final bool isRead;

  const LastMessageEntity({
    required this.messageId,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isRead,
  });

  factory LastMessageEntity.fromJson(Map<String, dynamic> json) {
    return LastMessageEntity(
      messageId: json['messageId'] as String,
      text: json['text'] as String,
      sender: json['sender'] is Map<String, dynamic>
          ? SenderEntity.fromJson(json['sender'] as Map<String, dynamic>)
          : throw ArgumentError('Invalid sender format in LastMessageEntity.fromJson'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  /// Creates a LastMessageEntity from a LastMessageModel
  factory LastMessageEntity.fromModel(dynamic model) {
    // Accepts a model with the same fields as LastMessageModel
    return LastMessageEntity(
      messageId: model.messageId,
      text: model.text,
      sender: model.sender,
      timestamp: model.timestamp,
      isRead: model.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'sender': sender,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  @override
  List<Object?> get props => [messageId, text, sender, timestamp, isRead];
}

class ThreadInfoEntity extends Equatable {
  final int threadCount;

  const ThreadInfoEntity({required this.threadCount});

  factory ThreadInfoEntity.fromJson(Map<String, dynamic> json) {
    return ThreadInfoEntity(
      threadCount: json['threadCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'threadCount': threadCount,
      };

  @override
  List<Object?> get props => [threadCount];
}

class ConversationDetailEntity extends Equatable {
  final String id;
  final String? name;
  final List<ConversationParticipantEntity> participants;
  final bool isGroup;
  final GroupSettingsEntity? groupSettings;
  final LastMessageEntity? lastMessage;
  final ThreadInfoEntity? threadInfo;
  final bool isActive;
  final List<dynamic> pinnedMessages;
  final ConversationSettingsEntity? settings;
  final DateTime startedAt;
  final List<dynamic> readReceipts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ConversationDetailEntity({
    required this.id,
    this.name,
    required this.participants,
    required this.isGroup,
    this.groupSettings,
    this.lastMessage,
    this.threadInfo,
    required this.isActive,
    required this.pinnedMessages,
    this.settings,
    required this.startedAt,
    required this.readReceipts,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConversationDetailEntity.fromJson(Map<String, dynamic> json) {
    return ConversationDetailEntity(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: (json['participants'] is List
              ? (json['participants'] as List)
              : [json['participants']])
          .map<ConversationParticipantEntity>(
              (e) => ConversationParticipantEntity(
                    id: e['id'] as String,
                    username: e['username'] as String?,
                    email: e['email'] as String?,
                    avatarUrl: e['avatarUrl'] as String?,
                  ))
          .toList(),
      isGroup: json['isGroup'] as bool? ?? false,
      groupSettings: json['groupSettings'] != null
          ? GroupSettingsEntity(
              allowMemberInvite: (json['groupSettings'] as Map<String, dynamic>)['allowMemberInvite'] as bool? ?? false,
              allowMemberEdit: (json['groupSettings'] as Map<String, dynamic>)['allowMemberEdit'] as bool? ?? false,
              allowMemberDelete: (json['groupSettings'] as Map<String, dynamic>)['allowMemberDelete'] as bool? ?? false,
              allowMemberPin: (json['groupSettings'] as Map<String, dynamic>)['allowMemberPin'] as bool? ?? false,
            )
          : null,
      lastMessage: json['lastMessage'] != null
          ? LastMessageEntity.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      threadInfo: json['threadInfo'] != null
          ? ThreadInfoEntity.fromJson(json['threadInfo'] as Map<String, dynamic>)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      pinnedMessages: List<dynamic>.from(json['pinnedMessages'] ?? []),
      settings: json['settings'] != null
          ? ConversationSettingsEntity.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      startedAt: DateTime.parse(json['startedAt'] as String),
      readReceipts: List<dynamic>.from(json['readReceipts'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'participants': participants
            .map((e) => {
                  'id': e.id,
                  'username': e.username,
                  'email': e.email,
                  'avatarUrl': e.avatarUrl,
                })
            .toList(),
        'isGroup': isGroup,
        'groupSettings': groupSettings != null
            ? {
                'allowMemberInvite': groupSettings!.allowMemberInvite,
                'allowMemberEdit': groupSettings!.allowMemberEdit,
                'allowMemberDelete': groupSettings!.allowMemberDelete,
                'allowMemberPin': groupSettings!.allowMemberPin,
              }
            : null,
        'lastMessage': lastMessage?.toJson(),
        'threadInfo': threadInfo?.toJson(),
        'isActive': isActive,
        'pinnedMessages': pinnedMessages,
        'settings': settings?.toJson(),
        'startedAt': startedAt.toIso8601String(),
        'readReceipts': readReceipts,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        participants,
        isGroup,
        groupSettings,
        lastMessage,
        threadInfo,
        isActive,
        pinnedMessages,
        settings,
        startedAt,
        readReceipts,
        createdAt,
        updatedAt,
      ];
}