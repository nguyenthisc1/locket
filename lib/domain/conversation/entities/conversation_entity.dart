import 'package:equatable/equatable.dart';
import 'package:locket/core/entities/last_message_entity.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String name;
  final List<ConversationParticipantEntity> participants;
  final bool isGroup;
  final GroupSettingsEntity? groupSettings;
  final bool isActive;
  final List<dynamic> pinnedMessages;
  final ConversationSettingsEntity settings;
  final List<dynamic> readReceipts;
  final LastMessageEntity? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.isGroup,
    required this.isActive,
    required this.pinnedMessages,
    required this.settings,
    required this.readReceipts,
    required this.createdAt,
    required this.name,
    this.groupSettings,
    this.lastMessage,
    this.updatedAt,
  });

  ConversationEntity copyWith({
    String? id,
    String? name,
    List<ConversationParticipantEntity>? participants,
    bool? isGroup,
    GroupSettingsEntity? groupSettings,
    bool? isActive,
    List<dynamic>? pinnedMessages,
    ConversationSettingsEntity? settings,
    List<dynamic>? readReceipts,
    LastMessageEntity? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      participants: participants ?? List<ConversationParticipantEntity>.from(this.participants),
      isGroup: isGroup ?? this.isGroup,
      groupSettings: groupSettings ?? this.groupSettings,
      isActive: isActive ?? this.isActive,
      pinnedMessages: pinnedMessages ?? List<dynamic>.from(this.pinnedMessages),
      settings: settings ?? this.settings,
      readReceipts: readReceipts ?? List<dynamic>.from(this.readReceipts),
      lastMessage: lastMessage ?? (this.lastMessage != null ? LastMessageEntity.fromEntity(this.lastMessage!) : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    participants,
    isGroup,
    groupSettings,
    isActive,
    pinnedMessages,
    settings,
    readReceipts,
    lastMessage,
    createdAt,
    updatedAt,
  ];
}

class ConversationParticipantEntity extends Equatable {
  final String id;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String? lastReadMessageId;
  final DateTime? lastReadAt;
  final DateTime? joinedAt;

  const ConversationParticipantEntity({
    required this.id,
    this.username,
    this.email,
    this.avatarUrl,
    this.lastReadMessageId,
    this.lastReadAt,
    this.joinedAt,
  });

  ConversationParticipantEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? lastReadMessageId,
    DateTime? lastReadAt,
    DateTime? joinedAt,
  }) {
    return ConversationParticipantEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    avatarUrl,
    lastReadMessageId,
    lastReadAt,
    joinedAt,
  ];
}

class GroupSettingsEntity extends Equatable {
  final bool allowMemberInvite;
  final bool allowMemberEdit;
  final bool allowMemberDelete;
  final bool allowMemberPin;

  const GroupSettingsEntity({
    required this.allowMemberInvite,
    required this.allowMemberEdit,
    required this.allowMemberDelete,
    required this.allowMemberPin,
  });

  GroupSettingsEntity copyWith({
    bool? allowMemberInvite,
    bool? allowMemberEdit,
    bool? allowMemberDelete,
    bool? allowMemberPin,
  }) {
    return GroupSettingsEntity(
      allowMemberInvite: allowMemberInvite ?? this.allowMemberInvite,
      allowMemberEdit: allowMemberEdit ?? this.allowMemberEdit,
      allowMemberDelete: allowMemberDelete ?? this.allowMemberDelete,
      allowMemberPin: allowMemberPin ?? this.allowMemberPin,
    );
  }

  @override
  List<Object?> get props => [
    allowMemberInvite,
    allowMemberEdit,
    allowMemberDelete,
    allowMemberPin,
  ];
}

class ConversationSettingsEntity extends Equatable {
  final bool muteNotifications;
  final String? customEmoji;
  final String theme;
  final String? wallpaper;

  const ConversationSettingsEntity({
    required this.muteNotifications,
    this.customEmoji,
    required this.theme,
    this.wallpaper,
  });

  factory ConversationSettingsEntity.fromJson(Map<String, dynamic> json) {
    return ConversationSettingsEntity(
      muteNotifications: json['muteNotifications'] as bool? ?? false,
      customEmoji: json['customEmoji'] as String?,
      theme: json['theme'] as String? ?? '',
      wallpaper: json['wallpaper'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muteNotifications': muteNotifications,
      'customEmoji': customEmoji,
      'theme': theme,
      'wallpaper': wallpaper,
    };
  }

  ConversationSettingsEntity copyWith({
    bool? muteNotifications,
    String? customEmoji,
    String? theme,
    String? wallpaper,
  }) {
    return ConversationSettingsEntity(
      muteNotifications: muteNotifications ?? this.muteNotifications,
      customEmoji: customEmoji ?? this.customEmoji,
      theme: theme ?? this.theme,
      wallpaper: wallpaper ?? this.wallpaper,
    );
  }

  @override
  List<Object?> get props => [muteNotifications, customEmoji, theme, wallpaper];
}
