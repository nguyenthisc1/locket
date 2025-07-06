import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/conversation/pages/conversation_detail_page.dart';
import 'package:locket/presentation/conversation/widgets/converstation_item.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  // Example conversation data
  final List<Map<String, dynamic>> _conversations = const [
    {
      'name': 'Yến Vy',
      'lastMessage': 'Chào bạn! Bạn có khỏe không?',
      'timestamp': 'Ngày 6 thg 5, 2023',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Minh Anh',
      'lastMessage': 'Cảm ơn bạn đã giúp đỡ!',
      'timestamp': 'Hôm qua',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Hoàng Nam',
      'lastMessage': 'Hẹn gặp lại bạn nhé!',
      'timestamp': '2 ngày trước',
      'imageUrl':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Thu Hà',
      'lastMessage': 'Bạn có rảnh không?',
      'timestamp': 'Tuần trước',
      'imageUrl':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Văn Đức',
      'lastMessage': 'Tôi sẽ liên lạc lại sau.',
      'timestamp': '2 tuần trước',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    },
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
              onTap:
                  () => AppNavigator.push(
                    context,
                    const ConversationDetailPage(),
                  ),
              child: ConverstationItem(
                name: conversation['name'],
                lastMessage: conversation['lastMessage'],
                timestamp: conversation['timestamp'],
                imageUrl: conversation['imageUrl'],
              ),
            );
          },
        ),
      ),
    );
  }
}
