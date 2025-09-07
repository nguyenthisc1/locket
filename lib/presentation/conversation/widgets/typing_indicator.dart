import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';

class TypingIndicator extends StatefulWidget {
  final List<String> typingUsers;
  final String currentUserId;

  const TypingIndicator({
    super.key,
    required this.typingUsers,
    required this.currentUserId,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out current user from typing users
    final otherTypingUsers = widget.typingUsers
        .where((userId) => userId != widget.currentUserId)
        .toList();

    if (otherTypingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          // Animated dots
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
                  final opacity = (1.0 - animationValue).clamp(0.0, 1.0);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: AppDimensions.sm),
          // Typing text
          Text(
            otherTypingUsers.length == 1
                ? 'Someone is typing...'
                : '${otherTypingUsers.length} people are typing...',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
