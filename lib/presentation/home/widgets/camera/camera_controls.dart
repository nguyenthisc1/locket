import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class CameraControls extends StatelessWidget {
  final bool isFlashOn;
  final double currentZoomLevel;
  final VoidCallback onFlashToggle;

  const CameraControls({
    super.key,
    required this.isFlashOn,
    required this.currentZoomLevel,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FLASH BUTTON
            _buildControlButton(
              onTap: onFlashToggle,
              icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
              iconColor: isFlashOn ? AppColors.primary : Colors.white70,
            ),

            // ZOOM CONTROLS
            _buildZoomDisplay(),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.xl,
        height: AppDimensions.xl,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.safeOpacity(0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }

  Widget _buildZoomDisplay() {
    return Container(
      width: AppDimensions.xl,
      height: AppDimensions.xl,
      decoration: BoxDecoration(
        color: Colors.white.safeOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: Center(
        child: Text(
          '${currentZoomLevel.toStringAsFixed(1)}x',
          style: AppTypography.bodySmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
