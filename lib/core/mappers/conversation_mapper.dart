import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/models/last_message_model.dart';
import 'package:locket/data/conversation/models/converstation_model.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationMapper {
  static ConversationEntity toEntity(ConversationModel model) {
    return ConversationEntity(
      id: model.id,
      name: model.name,
      participants:
          model.participants
              .map(
                (p) => ConversationParticipantEntity(
                  id: p.id,
                  username: p.username,
                  email: p.email,
                  avatarUrl: p.avatarUrl,
                ),
              )
              .toList(),
      isGroup: model.isGroup,
      groupSettings:
          model.groupSettings != null
              ? GroupSettingsEntity(
                allowMemberInvite: model.groupSettings!.allowMemberInvite,
                allowMemberEdit: model.groupSettings!.allowMemberEdit,
                allowMemberDelete: model.groupSettings!.allowMemberDelete,
                allowMemberPin: model.groupSettings!.allowMemberPin,
              )
              : null,
      isActive: model.isActive,
      pinnedMessages: List<dynamic>.from(model.pinnedMessages),
      settings: ConversationSettingsEntity(
        muteNotifications: model.settings.muteNotifications,
        customEmoji: model.settings.customEmoji,
        theme: model.settings.theme,
        wallpaper: model.settings.wallpaper,
      ),
      readReceipts: List<dynamic>.from(model.readReceipts),
      lastMessage: model.lastMessage != null
          ? LastMessageEntity.fromModel(model.lastMessage!)
          : null,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ConversationModel toModel(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      name: entity.name,
      participants:
          entity.participants
              .map(
                (p) => ConversationParticipantModel(
                  id: p.id,
                  username: p.username,
                  email: p.email,
                  avatarUrl: p.avatarUrl,
                ),
              )
              .toList(),
      isGroup: entity.isGroup,
      groupSettings:
          entity.groupSettings != null
              ? GroupSettingsModel(
                allowMemberInvite: entity.groupSettings!.allowMemberInvite,
                allowMemberEdit: entity.groupSettings!.allowMemberEdit,
                allowMemberDelete: entity.groupSettings!.allowMemberDelete,
                allowMemberPin: entity.groupSettings!.allowMemberPin,
              )
              : null,
      isActive: entity.isActive,
      pinnedMessages: List<dynamic>.from(entity.pinnedMessages),
      settings: ConversationSettingsModel(
        muteNotifications: entity.settings.muteNotifications,
        customEmoji: entity.settings.customEmoji,
        theme: entity.settings.theme,
        wallpaper: entity.settings.wallpaper,
      ),
      readReceipts: List<dynamic>.from(entity.readReceipts),
      lastMessage: entity.lastMessage != null
          ? LastMessageModel.fromEntity(entity.lastMessage!)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<ConversationEntity> toEntityList(List<ConversationModel> models) {
    return models.map((m) => toEntity(m)).toList();
  }

  static List<ConversationModel> toModelList(
    List<ConversationEntity> entities,
  ) {
    return entities.map((e) => toModel(e)).toList();
  }
}
