import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/presentation/conversation/pages/conversation_detail_page.dart';
import 'package:locket/presentation/conversation/widgets/converstation_item.dart';

class ConversationPage extends StatelessWidget {
  ConversationPage({super.key});

  // Example conversation data modeled after the provided Mongoose conversation schema
  final List<ConversationEntity> _conversations = [
    ConversationEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0a',
      name: 'Yến Vy',
      isGroup: false,
      participants: [
        '660f1a2b3c4d5e6f7a8b9c01', // current user
        '660f1a2b3c4d5e6f7a8b9c02', // Yến Vy
      ],
      admin: null,
      lastMessage: LastMessageEntity(
        messageId: '660f1a2b3c4d5e6f7a8b9c0d',
        text: 'Chào bạn! Bạn có khỏe không?',
        senderId: '660f1a2b3c4d5e6f7a8b9c02',
        timestamp: DateTime(2023, 5, 6, 10, 30),
      ),
      timestamp: 'Ngày 6 thg 5, 2023',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      isActive: true,
      pinnedMessages: [],
      settings: ConversationSettingsEntity(
        muteNotifications: false,
        customEmoji: null,
        theme: 'default',
        wallpaper: null,
      ),
      startedAt: DateTime(2023, 5, 6, 10, 30),
      readReceipts: [],
    ),
    ConversationEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0b',
      name: 'Minh Anh',
      isGroup: false,
      participants: ['660f1a2b3c4d5e6f7a8b9c01', '660f1a2b3c4d5e6f7a8b9c03'],
      admin: null,
      lastMessage: LastMessageEntity(
        messageId: '660f1a2b3c4d5e6f7a8b9c0e',
        text: 'Cảm ơn bạn đã giúp đỡ!',
        senderId: '660f1a2b3c4d5e6f7a8b9c03',
        timestamp: DateTime(2023, 5, 7, 18, 45),
      ),
      timestamp: 'Hôm qua',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      isActive: true,
      pinnedMessages: [],
      settings: ConversationSettingsEntity(
        muteNotifications: false,
        customEmoji: null,
        theme: 'default',
        wallpaper: null,
      ),
      startedAt: DateTime(2023, 5, 7, 18, 45),
      readReceipts: [],
    ),
    ConversationEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0c',
      name: 'Hoàng Nam',
      isGroup: false,
      participants: ['660f1a2b3c4d5e6f7a8b9c01', '660f1a2b3c4d5e6f7a8b9c04'],
      admin: null,
      lastMessage: LastMessageEntity(
        messageId: '660f1a2b3c4d5e6f7a8b9c0f',
        text: 'Hẹn gặp lại bạn nhé!',
        senderId: '660f1a2b3c4d5e6f7a8b9c04',
        timestamp: DateTime(2023, 5, 5, 14, 10),
      ),
      timestamp: '2 ngày trước',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      isActive: true,
      pinnedMessages: [],
      settings: ConversationSettingsEntity(
        muteNotifications: false,
        customEmoji: null,
        theme: 'default',
        wallpaper: null,
      ),
      startedAt: DateTime(2023, 5, 5, 14, 10),
      readReceipts: [],
    ),
    ConversationEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0d',
      name: 'Thu Hà',
      isGroup: false,
      participants: ['660f1a2b3c4d5e6f7a8b9c01', '660f1a2b3c4d5e6f7a8b9c05'],
      admin: null,
      lastMessage: LastMessageEntity(
        messageId: '660f1a2b3c4d5e6f7a8b9c10',
        text: 'Bạn có rảnh không?',
        senderId: '660f1a2b3c4d5e6f7a8b9c05',
        timestamp: DateTime(2023, 4, 30, 9, 0),
      ),
      timestamp: 'Tuần trước',
      imageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      isActive: true,
      pinnedMessages: [],
      settings: ConversationSettingsEntity(
        muteNotifications: false,
        customEmoji: null,
        theme: 'default',
        wallpaper: null,
      ),
      startedAt: DateTime(2023, 4, 30, 9, 0),
      readReceipts: [],
    ),
    ConversationEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0e',
      name: 'Văn Đức',
      isGroup: false,
      participants: ['660f1a2b3c4d5e6f7a8b9c01', '660f1a2b3c4d5e6f7a8b9c06'],
      admin: null,
      lastMessage: LastMessageEntity(
        messageId: '660f1a2b3c4d5e6f7a8b9c11',
        text: 'Tôi sẽ liên lạc lại sau.',
        senderId: '660f1a2b3c4d5e6f7a8b9c06',
        timestamp: DateTime(2023, 4, 23, 16, 20),
      ),
      timestamp: '2 tuần trước',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      isActive: true,
      pinnedMessages: [],
      settings: ConversationSettingsEntity(
        muteNotifications: false,
        customEmoji: null,
        theme: 'default',
        wallpaper: null,
      ),
      startedAt: DateTime(2023, 4, 23, 16, 20),
      readReceipts: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Text('Tin nhắn', style: AppTypography.displaySmall),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.lg,
        ),
        child: ListView.separated(
          physics: const ScrollPhysics(),
          itemCount: _conversations.length,
          separatorBuilder:
              (context, index) => const SizedBox(height: AppDimensions.xxl),
          itemBuilder: (context, index) {
            final conversation = _conversations[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap:
                  () => AppNavigator.push(
                    context,
                    const ConversationDetailPage(),
                  ),
              child: ConverstationItem(data: conversation),
            );
          },
        ),
      ),
    );
  }
}
