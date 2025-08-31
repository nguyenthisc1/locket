
import 'package:equatable/equatable.dart';
import 'package:locket/data/conversation/models/conversation_detail_model.dart';

class ConversationParticipantModel extends Equatable {
  final String id;
  final String? username;
  final String? email;
  final String? avatarUrl;

  const ConversationParticipantModel({
    required this.id,
    this.username,
    this.email,
    this.avatarUrl,
  });

  factory ConversationParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantModel(
      id: json['_id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, username, email, avatarUrl];
}

class GroupSettingsModel extends Equatable {
  final bool allowMemberInvite;
  final bool allowMemberEdit;
  final bool allowMemberDelete;
  final bool allowMemberPin;

  const GroupSettingsModel({
    required this.allowMemberInvite,
    required this.allowMemberEdit,
    required this.allowMemberDelete,
    required this.allowMemberPin,
  });

  factory GroupSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const GroupSettingsModel(
        allowMemberInvite: false,
        allowMemberEdit: false,
        allowMemberDelete: false,
        allowMemberPin: false,
      );
    }
    return GroupSettingsModel(
      allowMemberInvite: json['allowMemberInvite'] as bool? ?? false,
      allowMemberEdit: json['allowMemberEdit'] as bool? ?? false,
      allowMemberDelete: json['allowMemberDelete'] as bool? ?? false,
      allowMemberPin: json['allowMemberPin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowMemberInvite': allowMemberInvite,
      'allowMemberEdit': allowMemberEdit,
      'allowMemberDelete': allowMemberDelete,
      'allowMemberPin': allowMemberPin,
    };
  }

  @override
  List<Object?> get props => [
        allowMemberInvite,
        allowMemberEdit,
        allowMemberDelete,
        allowMemberPin,
      ];
}

class ConversationModel extends Equatable {
  final String id;
  final String? name;
  final List<ConversationParticipantModel> participants;
  final bool isGroup;
  final GroupSettingsModel? groupSettings;
  final bool isActive;
  final List<dynamic> pinnedMessages;
  final ConversationSettingsModel settings;
  final List<dynamic> readReceipts;
  final LastMessageModel? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ConversationModel({
    required this.id,
    this.name,
    required this.participants,
    required this.isGroup,
    required this.isActive,
    required this.pinnedMessages,
    this.groupSettings,
    required this.settings,
    required this.readReceipts,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) => ConversationParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isGroup: json['isGroup'] as bool? ?? false,
      groupSettings: json['groupSettings'] != null
          ? GroupSettingsModel.fromJson(json['groupSettings'] as Map<String, dynamic>)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      pinnedMessages: List<dynamic>.from(json['pinnedMessages'] ?? []),
      settings: ConversationSettingsModel.fromJson(json['settings'] ?? {}),
      readReceipts: List<dynamic>.from(json['readReceipts'] ?? []),
      lastMessage: json['lastMessage'] ?? null, 
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participants': participants.map((e) => e.toJson()).toList(),
      'isGroup': isGroup,
      'groupSettings': groupSettings?.toJson(),
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'settings': settings.toJson(),
      'readReceipts': readReceipts,
      'lastMessage': lastMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
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

class ConversationSettingsModel extends Equatable {
  final bool muteNotifications;
  final String? customEmoji;
  final String theme;
  final String? wallpaper;

  const ConversationSettingsModel({
    required this.muteNotifications,
    this.customEmoji,
    required this.theme,
    this.wallpaper,
  });

  factory ConversationSettingsModel.fromJson(Map<String, dynamic> json) {
    return ConversationSettingsModel(
      muteNotifications: json['muteNotifications'] as bool? ?? false,
      customEmoji: json['customEmoji'] as String?,
      theme: json['theme'] as String? ?? 'default',
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

  @override
  List<Object?> get props => [
        muteNotifications,
        customEmoji,
        theme,
        wallpaper,
      ];
}