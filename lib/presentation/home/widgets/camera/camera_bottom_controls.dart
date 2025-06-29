import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'camera_button.dart';

class CameraBottomControls extends StatelessWidget {
  final VoidCallback onLibraryTap;
  final VoidCallback onTakePicture;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onSwitchCamera;

  const CameraBottomControls({
    super.key,
    required this.onLibraryTap,
    required this.onTakePicture,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
      ],
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: AppDimensions.xxl),
    );
  }
}
