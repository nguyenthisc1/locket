import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/converstation_item.dart';
import 'package:provider/provider.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final conversationController = context.read<ConversationController>();
    final conversationState = context.read<ConversationControllerState>();

    if (!_scrollController.hasClients) return;

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentPosition = _scrollController.position.pixels;
    final triggerOffset = maxScrollExtent * 0.8;

    if (currentPosition >= triggerOffset &&
        conversationState.hasMoreData &&
        !conversationState.isLoadingMore) {
      conversationController.loadMoreConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationController = context.read<ConversationController>();
    final conversationState = context.watch<ConversationControllerState>();

    if (conversationState.isLoadingConversations &&
        !conversationState.hasInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversationState.errorMessage != null &&
        conversationState.listConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppDimensions.lg),
            Text(
              conversationState.errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton(
              onPressed: () => conversationController.refreshConversations(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Conversation list
        Positioned.fill(
          child: ListView.separated(
            controller: _scrollController,
            physics: const ScrollPhysics(),
            itemCount: conversationState.listConversations.length,
            separatorBuilder:
                (context, index) => const SizedBox(height: AppDimensions.xxl),
            itemBuilder: (context, index) {
              final conversation = conversationState.listConversations[index];
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap:
                    () => AppNavigator.push(
                      context,
                      '/converstion/:id',
                      extra: conversation.id,
                    ),
                child: ConversationItem(data: conversation),
              );
            },
          ),
        ),

        // if (conversationState.isLoadingConversations)
        // Positioned(
        //   top: 0,
        //   left: 0,
        //   right: 0,
        //   child: LoadingText(text: 'Đang tải tin nhắn'),
        // ),
      ],
    );
  }
}
