import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class MessageField extends StatefulWidget {
  final EdgeInsetsGeometry? padding;

  const MessageField({
    super.key,
    this.padding = const EdgeInsets.only(
      left: AppDimensions.md,
      right: AppDimensions.md,
      top: AppDimensions.lg,
      bottom: AppDimensions.lg,
    ),
  });

  @override
  State<MessageField> createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool isKeyboardVisible = false;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  void _handleFocusChange() {
    setState(() {
      isKeyboardVisible = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _unfocus() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  void initState() {
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding =
        widget.padding ??
        const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.lg,
          bottom: AppDimensions.lg,
        );

    return Stack(
      children: [
        // Fullscreen GestureDetector to close keyboard when tapping outside
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isKeyboardVisible,
            child: GestureDetector(
              onTap: _unfocus,
              behavior: HitTestBehavior.translucent,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(color: Colors.black.safeOpacity(0.8)),
              ),
            ),
          ),
        ),
        // The message field with backdrop blur
        Padding(
          padding: effectivePadding,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: TextField(
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Gửi tin nhắn...',
                    filled: true,
                    fillColor: Colors.white.safeOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXxl,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
