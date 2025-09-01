import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/conversation/widgets/conversation_list.dart';
import 'package:provider/provider.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Consumer<ConversationControllerState>(
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
              child: ConversationList()
            ),
          );
        },
    );
  }
}
