import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart' as utils;
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/conversation_detail_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/converstion_detail_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';
import 'package:locket/presentation/conversation/widgets/typing_indicator.dart';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;
  const ConversationDetailPage({super.key, required this.conversationId});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late final ConversationDetailControllerState _state;
  late final ConversationDetailController _controller;
  bool isShowGallery = false;

  @override
  void initState() {
    super.initState();
    _state = getIt<ConversationDetailControllerState>();
    _controller = getIt<ConversationDetailController>(param1: _state);
    _controller.init(widget.conversationId);
    _state.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_state.scrollController.hasClients) return;

    final maxScrollExtent = _state.scrollController.position.maxScrollExtent;
    final currentPosition = _state.scrollController.position.pixels;
    final triggerOffset = maxScrollExtent * 1;

    if (currentPosition >= triggerOffset &&
        _state.hasMoreData &&
        !_state.isLoadingMore) {
      _controller.loadMoreMessages();
    }
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
          resizeToAvoidBottomInset: true,
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

                  // if (_state.pickImagesGallery != null)
                  // Positioned(
                  //   right: AppDimensions.md,
                  //   bottom: 100,
                  //   width: 200,
                  //   child: Stack(
                  //     alignment: AlignmentDirectional.centerEnd,
                  //     children: [
                  //       if (_state.pickImagesGallery!.length > 1)
                  //         Positioned.fill(
                  //           left: AppDimensions.xl,
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(
                  //               AppDimensions.radiusLg,
                  //             ),
                  //             child: Image.file(
                  //               _state.pickImagesGallery![1],
                  //               width: 150,
                  //               height: 200,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //       ClipRRect(
                  //         borderRadius: BorderRadius.circular(
                  //           AppDimensions.radiusLg,
                  //         ),
                  //         child: Image.file(
                  //           _state.pickImagesGallery!.first,
                  //           width: 150,
                  //           height: 200,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
    return ListView.builder(
      reverse: true,
      controller: _state.scrollController,
      itemCount: _state.listMessages.length + (_state.isLoadingMore ? 1 : 0),
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

        final isReader =
            _state.conversation?.participants.any(
              (p) =>
                  p.id != currentUserId &&
                  p.lastReadMessageId == messageData.id,
            ) ??
            false;

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
                      utils.formatVietnameseTimestamp(messageData.createdAt),
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
        isShowPickImagesGalleryIcon: true,

        // onPickimagesGallery: _controller.pickImage,
        // photos: _state.photos,
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
