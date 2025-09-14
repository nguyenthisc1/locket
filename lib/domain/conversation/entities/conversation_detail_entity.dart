import 'package:equatable/equatable.dart';
import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ThreadInfoEntity extends Equatable {
  final int threadCount;

  const ThreadInfoEntity({required this.threadCount});

  factory ThreadInfoEntity.fromJson(Map<String, dynamic> json) {
    return ThreadInfoEntity(threadCount: json['threadCount'] as int);
  }

  Map<String, dynamic> toJson() => {'threadCount': threadCount};

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

  /// Parses participants from JSON array.
  /// Participants now always come as an array for both group and single conversations.
  static List<ConversationParticipantEntity> _parseParticipants(
    dynamic jsonValue,
  ) {
    if (jsonValue == null) return [];

    // Participants should always be a list now
    if (jsonValue is List) {
      return jsonValue
          .map<ConversationParticipantEntity>(
            (e) => ConversationParticipantEntity(
              id: (e['userId'] ?? e['_id'] ?? e['id']) as String,
              username: e['username'] as String?,
              email: e['email'] as String?,
              avatarUrl: e['avatarUrl'] as String?,
              lastReadMessageId: e['lastReadMessageId'] as String?,
              lastReadAt: e['lastReadAt'] as String?,
              joinedAt: e['joinedAt'] as String?,
            ),
          )
          .toList();
    } else if (jsonValue is Map<String, dynamic>) {
      // Fallback: if single participant object provided, wrap in list
      return [
        ConversationParticipantEntity(
          id: (jsonValue['userId'] ?? jsonValue['_id'] ?? jsonValue['id']) as String,
          username: jsonValue['username'] as String?,
          email: jsonValue['email'] as String?,
          avatarUrl: jsonValue['avatarUrl'] as String?,
          lastReadMessageId: jsonValue['lastReadMessageId'] as String?,
          lastReadAt: jsonValue['lastReadAt'] as String?,
          joinedAt: jsonValue['joinedAt'] as String?,
        ),
      ];
    }

    return [];
  }

  factory ConversationDetailEntity.fromJson(Map<String, dynamic> json) {
    final isGroup = json['isGroup'] as bool? ?? false;

    return ConversationDetailEntity(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: _parseParticipants(json['participants']),
      isGroup: isGroup,
      groupSettings:
          json['groupSettings'] != null
              ? GroupSettingsEntity(
                allowMemberInvite:
                    (json['groupSettings']
                            as Map<String, dynamic>)['allowMemberInvite']
                        as bool? ??
                    false,
                allowMemberEdit:
                    (json['groupSettings']
                            as Map<String, dynamic>)['allowMemberEdit']
                        as bool? ??
                    false,
                allowMemberDelete:
                    (json['groupSettings']
                            as Map<String, dynamic>)['allowMemberDelete']
                        as bool? ??
                    false,
                allowMemberPin:
                    (json['groupSettings']
                            as Map<String, dynamic>)['allowMemberPin']
                        as bool? ??
                    false,
              )
              : null,
      lastMessage:
          json['lastMessage'] != null
              ? LastMessageEntity.fromJson(
                json['lastMessage'] as Map<String, dynamic>,
              )
              : null,
      threadInfo:
          json['threadInfo'] != null
              ? ThreadInfoEntity.fromJson(
                json['threadInfo'] as Map<String, dynamic>,
              )
              : null,
      isActive: json['isActive'] as bool? ?? false,
      pinnedMessages: List<dynamic>.from(json['pinnedMessages'] ?? []),
      settings:
          json['settings'] != null
              ? ConversationSettingsEntity.fromJson(
                json['settings'] as Map<String, dynamic>,
              )
              : null,
      startedAt: DateTime.parse(json['startedAt'] as String),
      readReceipts: List<dynamic>.from(json['readReceipts'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'participants':
        participants
            .map(
              (e) => {
                'userId': e.id,
                'username': e.username,
                'email': e.email,
                'avatarUrl': e.avatarUrl,
                'lastReadMessageId': e.lastReadMessageId,
                'lastReadAt': e.lastReadAt,
                'joinedAt': e.joinedAt,
              },
            )
            .toList(),
    'isGroup': isGroup,
    'groupSettings':
        groupSettings != null
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
