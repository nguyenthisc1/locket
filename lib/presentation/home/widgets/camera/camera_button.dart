import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/widgets/take_button.dart';

class CameraButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const CameraButton({
    super.key,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: TakeButton(size: AppDimensions.xxl * 2),
    );
  }
}
