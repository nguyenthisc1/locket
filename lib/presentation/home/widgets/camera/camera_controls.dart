import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:provider/provider.dart';

class CameraControls extends StatelessWidget {
  const CameraControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Access both state and controller via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();
    final cameraController = context.read<CameraController>();
    
    return Column(
      children: [
        // Top controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FLASH BUTTON
            _buildControlButton(
              onTap: cameraController.toggleFlash,
              icon: cameraState.isFlashOn ? Icons.flash_on : Icons.flash_off,
              iconColor: cameraState.isFlashOn ? AppColors.primary : Colors.white70,
            ),

            // ZOOM CONTROLS
            _buildZoomDisplay(cameraState.currentZoomLevel),
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
          color: backgroundColor ?? Colors.white.safeOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }

  Widget _buildZoomDisplay(double currentZoomLevel) {
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
