import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart' as utils;
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail_controller.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';

import '../../../core/configs/theme/index.dart';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;
  const ConversationDetailPage({super.key, required this.conversationId});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late final ConversationDetailControllerState _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConversationDetailControllerState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.scrollController.jumpTo(
        _controller.scrollController.position.minScrollExtent,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: BasicAppbar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
                  size: AppDimensions.avatarMd,
                ),
                const SizedBox(width: AppDimensions.md),
                Text(
                  'Name 1123',
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
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListView.builder(
                        reverse: true,
                        controller: _controller.scrollController,
                        itemCount: _controller.conversationData.length,
                        padding: const EdgeInsets.only(
                          top: AppDimensions.lg,
                          bottom: AppDimensions.xxl * 2,
                        ),
                        itemBuilder: (context, index) {
                          final messageData =
                              _controller.conversationData[index];
                          final showTimestamp =
                              _controller.shouldShowTimestamp(
                                index,
                                _controller.conversationData,
                              ) ||
                              _controller.visibleTimestamps.contains(index);

                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                _controller.toggleTimestampVisibility(index);
                              });
                            },
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
                      );
                      ;
                    },
                  ),

                  Positioned.fill(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MessageField(),
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
