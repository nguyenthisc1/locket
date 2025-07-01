import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'camera_button.dart';

class CameraBottomControls extends StatelessWidget {
  final VoidCallback onLibraryTap;
  final VoidCallback onTakePicture;
  final VoidCallback onCancelPicture;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onSwitchCamera;
  final bool isPictureTaken;

  const CameraBottomControls({
    super.key,
    required this.onLibraryTap,
    required this.onTakePicture,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onSwitchCamera,
    required this.isPictureTaken,
    required this.onCancelPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isPictureTaken) ...[
          // LIBRARY BUTTON
          _buildIconButton(
            onPressed: onLibraryTap,
            icon: Icons.photo_library_outlined,
          ),
          // TAKE PICTURE BUTTON
          CameraButton(
            onTap: onTakePicture,
            onLongPressStart: onStartRecording,
            onLongPressEnd: onStopRecording,
          ),
          // CHANGE CAMERA
          _buildIconButton(onPressed: onSwitchCamera, icon: Icons.loop),
        ] else ...[
          _buildIconButton(onPressed: onCancelPicture, icon: Icons.close),

          SizedBox(
            width: AppDimensions.xxl * 2,
            height: AppDimensions.xxl * 2,
            child: Transform.rotate(
              angle: -0.785398,
              child: _buildIconButton(
                onPressed: onCancelPicture,
                icon: Icons.send,
                color: AppColors.dark,
              ),
            ),
          ),

          _buildIconButton(onPressed: onSwitchCamera, icon: Icons.edit_note),
        ],
      ],
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
  }) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: AppDimensions.xxl),
    );
  }
}
