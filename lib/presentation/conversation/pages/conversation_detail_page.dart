import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart' as utils;
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/loading_text.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/services/conversation_detail_cache_service.dart';
import 'package:locket/core/services/message_cache_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_messages_conversation_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/conversation_detail_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/converstion_detail_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;
  const ConversationDetailPage({super.key, required this.conversationId});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late final ConversationDetailControllerState _state;
  late final ConversationDetailController _controller;

  @override
  void initState() {
    super.initState();

    // Create local instances to avoid shared state between conversations
    _state = ConversationDetailControllerState();
    _controller = ConversationDetailController(
      state: _state,
      cacheService: getIt<MessageCacheService>(),
      conversationDetailCacheService: getIt<ConversationDetailCacheService>(),
      getMessagesUsecase: getIt<GetMessagesConversationUsecase>(),
      getConversationDetailUsecase: getIt<GetConversationDetailUsecase>(),
    );

    _controller.init(widget.conversationId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initBefore(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          appBar: BasicAppbar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserImage(
                  imageUrl: _state.conversation?.participants[0].avatarUrl,
                  size: AppDimensions.avatarMd,
                ),
                const SizedBox(width: AppDimensions.md),
                Text(
                  _state.conversation?.name ?? 'Tên',
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            action: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Icon(Icons.more_horiz, size: AppDimensions.iconLg),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: _controller.currentBackgroundGradient,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: _controller.currentBackgroundGradient,
              ),
              child: Stack(
                children: [
                  // Error state
                  if (_state.errorMessage != null &&
                      _state.listMessages.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _state.errorMessage!,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          ElevatedButton(
                            onPressed: () => _controller.refreshMessages(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  // Loading state (only when no messages and loading)
                  // else if (_state.isLoadingMessages &&
                  //     _state.listMessages.isEmpty)
                  //   const Center(
                  //     child: CircularProgressIndicator(color: Colors.white),
                  //   )
                  // Messages list
                  else
                    RefreshIndicator(
                      onRefresh: _controller.refreshMessages,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          // Load more messages when reaching the top (since we use reverse: true)
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 100) {
                            if (_state.hasMoreData && !_state.isLoadingMore) {
                              _controller.loadMoreMessages();
                            }
                          }
                          return false;
                        },
                        child: ListView.builder(
                          reverse: true,
                          controller: _state.scrollController,
                          itemCount:
                              _state.listMessages.length +
                              (_state.isLoadingMore ? 1 : 0),
                          padding: const EdgeInsets.only(
                            top: AppDimensions.lg,
                            bottom: AppDimensions.xxl * 2,
                          ),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the top when loading more
                            if (index == _state.listMessages.length) {
                              return const Padding(
                                padding: EdgeInsets.all(AppDimensions.md),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            final messageData = _state.listMessages[index];
                            final showTimestamp =
                                _state.shouldShowTimestamp(
                                  index,
                                  _state.listMessages,
                                ) ||
                                _state.visibleTimestamps.contains(index);

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap:
                                  () => _state.toggleTimestampVisibility(index),
                              child: Column(
                                crossAxisAlignment:
                                    messageData.isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (showTimestamp)
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppDimensions.sm,
                                        ),
                                        child: Text(
                                          utils.formatVietnameseTimestamp(
                                            messageData.createdAt,
                                          ),
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: Colors.grey[400],
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: AppDimensions.md,
                                      right: AppDimensions.md,
                                      bottom: AppDimensions.xl,
                                    ),
                                    child: Message(data: messageData),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Message input field
                  Positioned.fill(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MessageField(),
                  ),

                  if (_state.isLoadingMessages)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LoadingText(text: 'Đang tải tin nhắn'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
