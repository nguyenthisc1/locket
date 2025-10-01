import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/conversation_list.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';

import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController _conversationController;

  @override
  void initState() {
    super.initState();
    _conversationController = getIt<ConversationController>();

    Future.microtask(() {
      _conversationController.init();
    });
  }

  @override
  void dispose() {
    _conversationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationControllerState>(
      builder: (context, conversationState, _) {
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
            child: ConversationList(),
          ),
        );
      },
    );
  }
}
