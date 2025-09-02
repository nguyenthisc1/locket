import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/converstation_item.dart';
import 'package:provider/provider.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {

  // void _onScroll() {
  //   final conversationController = context.read<ConversationController>()
  //   final conversationState = context.read<ConversationControllerState>()


  // }

  @override
  Widget build(BuildContext context) {
    final conversationController = context.read<ConversationController>();
    final conversationState = context.watch<ConversationControllerState>();

    if (conversationState.isLoadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversationState.errorMessage != null &&
        conversationState.listConversation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              conversationState.errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => conversationController.refreshConversations(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Show cached data indicator
        if (conversationState.isShowingCachedData)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.safeOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.cached, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Showing cached data',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        // Conversation list
        Expanded(
          child: ListView.separated(
            physics: const ScrollPhysics(),
            itemCount: conversationState.listConversation.length,
            separatorBuilder:
                (context, index) => const SizedBox(height: AppDimensions.xxl),
            itemBuilder: (context, index) {
              final conversation = conversationState.listConversation[index];
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => AppNavigator.push(context, '/converstion/:id'),
                child: ConversationItem(data: conversation),
              );
            },
          ),
        ),
      ],
    );
  }
}
