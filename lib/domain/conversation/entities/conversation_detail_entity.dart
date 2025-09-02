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

  /// Parses participants based on group type:
  /// - For groups (isGroup = true): participants should be a List
  /// - For single conversations (isGroup = false): participants should be a Map (single participant)
  static List<ConversationParticipantEntity> _parseParticipants(
    dynamic jsonValue,
    bool isGroup,
  ) {
    if (jsonValue == null) return [];

    if (isGroup) {
      // For groups, expect a list of participants
      if (jsonValue is List) {
        return jsonValue
            .map<ConversationParticipantEntity>(
              (e) => ConversationParticipantEntity(
                id: (e['_id'] ?? e['id']) as String,
                username: e['username'] as String?,
                email: e['email'] as String?,
                avatarUrl: e['avatarUrl'] as String?,
              ),
            )
            .toList();
      } else if (jsonValue is Map<String, dynamic>) {
        // Fallback: if single participant provided for group, wrap in list
        return [
          ConversationParticipantEntity(
            id: (jsonValue['_id'] ?? jsonValue['id']) as String,
            username: jsonValue['username'] as String?,
            email: jsonValue['email'] as String?,
            avatarUrl: jsonValue['avatarUrl'] as String?,
          ),
        ];
      }
    } else {
      // For single conversations, expect a single participant as Map
      if (jsonValue is Map<String, dynamic>) {
        return [
          ConversationParticipantEntity(
            id: (jsonValue['_id'] ?? jsonValue['id']) as String,
            username: jsonValue['username'] as String?,
            email: jsonValue['email'] as String?,
            avatarUrl: jsonValue['avatarUrl'] as String?,
          ),
        ];
      } else if (jsonValue is List && jsonValue.isNotEmpty) {
        // Fallback: if list provided for single conversation, take first participant
        final firstParticipant = jsonValue.first;
        return [
          ConversationParticipantEntity(
            id: (firstParticipant['_id'] ?? firstParticipant['id']) as String,
            username: firstParticipant['username'] as String?,
            email: firstParticipant['email'] as String?,
            avatarUrl: firstParticipant['avatarUrl'] as String?,
          ),
        ];
      }
    }

    return [];
  }

  factory ConversationDetailEntity.fromJson(Map<String, dynamic> json) {
    final isGroup = json['isGroup'] as bool? ?? false;

    return ConversationDetailEntity(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: _parseParticipants(json['participants'], isGroup),
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
                'id': e.id,
                'username': e.username,
                'email': e.email,
                'avatarUrl': e.avatarUrl,
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
