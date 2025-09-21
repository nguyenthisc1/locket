import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart' as utils;
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/services/conversation_detail_cache_service.dart';
import 'package:locket/core/services/message_cache_service.dart';
import 'package:locket/core/services/socket_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_messages_conversation_usecase.dart';
import 'package:locket/domain/conversation/usecases/mark_conversation_as_read_usecase.dart';
import 'package:locket/domain/conversation/usecases/send_message_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/conversation_detail_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/converstion_detail_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';
import 'package:locket/presentation/conversation/widgets/typing_indicator.dart';
import 'package:locket/core/services/user_service.dart';

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
    _state = ConversationDetailControllerState();
    _controller = ConversationDetailController(
      state: _state,
      cacheService: getIt<MessageCacheService>(),
      conversationDetailCacheService: getIt<ConversationDetailCacheService>(),
      getMessagesUsecase: getIt<GetMessagesConversationUsecase>(),
      sendMessageUsecase: getIt<SendMessageUsecase>(),
      getConversationDetailUsecase: getIt<GetConversationDetailUsecase>(),
      markConversationAsReadUsecase: getIt<MarkConversationAsReadUsecase>(),
      socketService: getIt<SocketService>(),
    );
    _controller.init(widget.conversationId);
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: _buildAppBar(),
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
                  if (_state.errorMessage != null &&
                      _state.listMessages.isEmpty)
                    _buildErrorState()
                  else
                    _buildMessageList(),
                  if (_state.typingUsers.isNotEmpty) _buildTypingIndicator(),
                  _buildMessageField(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return BasicAppbar(
      backgroundColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserImage(
            imageUrl:
                (_state.conversation?.participants.isNotEmpty ?? false)
                    ? _state.conversation!.participants.first.avatarUrl
                    : null,
            size: AppDimensions.avatarMd,
          ),
          const SizedBox(width: AppDimensions.md),
          Text(
            _state.conversation?.name ?? '',
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
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _state.errorMessage!,
            style: AppTypography.bodyLarge.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          ElevatedButton(
            onPressed: () => _controller.refreshMessages(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return RefreshIndicator(
      onRefresh: _controller.refreshMessages,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
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
              _state.listMessages.length + (_state.isLoadingMore ? 1 : 0),
          padding: const EdgeInsets.only(
            top: AppDimensions.lg,
            bottom: AppDimensions.xxl * 2,
          ),
          itemBuilder: (context, index) {
            if (index == _state.listMessages.length) {
              return const Padding(
                padding: EdgeInsets.all(AppDimensions.md),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            final messageData = _state.listMessages[index];
            final showTimestamp =
                _state.shouldShowTimestamp(index, _state.listMessages) ||
                _state.visibleTimestamps.contains(index);

            final currentUserId = getIt<UserService>().currentUser?.id;

            final isReader = _state.conversation?.participants.any(
              (p) =>
                  p.id != currentUserId &&
                  p.lastReadMessageId == messageData.id,
            ) ?? false;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _state.toggleTimestampVisibility(index),
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
                          style: AppTypography.bodyMedium.copyWith(
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
                      bottom: AppDimensions.md,
                      top: AppDimensions.sm,
                    ),
                    child: Message(
                      data: messageData,
                      lastMessage: _state.conversation?.lastMessage,
                      participants: _state.conversation?.participants,
                    ),
                  ),

                  if (messageData.isMe && isReader)
                    if (messageData.messageStatus == MessageStatus.read)
                      _buildIsReadReceipts(messageData),

                  if (messageData.isMe &&
                      messageData.id ==
                          _state.conversation?.lastMessage?.messageId &&
                      messageData.messageStatus != MessageStatus.read)
                    _buildMessageStatus(messageData.messageStatus),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: TypingIndicator(
        typingUsers: _state.typingUsers.toList(),
        currentUserId: getIt<UserService>().currentUser?.id ?? '',
      ),
    );
  }

  Widget _buildMessageField() {
    return Positioned.fill(
      left: 0,
      right: 0,
      bottom: 0,
      child: MessageField(
        onChanged: (text) {
          if (text.isNotEmpty) {
            _controller.sendTypingIndicator();
          } else {
            _controller.sendStopTypingIndicator();
          }
        },
        onSubmitted: (text) {
          if (text.trim().isNotEmpty) {
            _controller.sendMessage(text: text.trim());
          }
        },
      ),
    );
  }

  Widget _buildIsReadReceipts(MessageEntity messageData) {
    final currentUserId = getIt<UserService>().currentUser?.id;

    final conversation = _state.conversation;
    final participants = conversation?.participants ?? [];

    final readers =
        participants.where((participant) {
          return participant.id != currentUserId &&
              participant.lastReadMessageId == messageData.id;
        }).toList();

    if (readers.isEmpty) return const SizedBox.shrink();

    final int displayCount = readers.length > 3 ? 3 : readers.length;
    return Padding(
      padding: const EdgeInsets.only(
        right: AppDimensions.md,
        bottom: AppDimensions.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...List.generate(
            displayCount,
            (index) => UserImage(
              size: AppDimensions.avatarXs,
              imageUrl: readers[index].avatarUrl,
            ),
          ),
          if (readers.length > 3)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.sm),
              child: Text(
                '...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppDimensions.md,
        bottom: AppDimensions.md,
      ),
      child: Text(
        status == MessageStatus.sent
            ? 'Đang gửi'
            : status == MessageStatus.delivered
            ? 'Đã gửi'
            : '',
      ),
    );
  }
}
