import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/widgets/icon_button.dart';
import 'camera_button.dart';

class CameraBottomControls extends StatelessWidget {
  final VoidCallback onLibraryTap;
  final VoidCallback onTakePicture;
  final VoidCallback onResetPicture;
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
    required this.onResetPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isPictureTaken) ...[
          // LIBRARY BUTTON
          BuildIconButton(
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
          BuildIconButton(onPressed: onSwitchCamera, icon: Icons.loop),
        ] else ...[
          BuildIconButton(onPressed: onResetPicture, icon: Icons.close),

          SizedBox(
            width: AppDimensions.xxl * 2,
            height: AppDimensions.xxl * 2,
            child: Transform.rotate(
              angle: -0.785398,
              child: BuildIconButton(
                onPressed: () {},
                icon: Icons.send,
                color: AppColors.dark,
              ),
            ),
          ),

          BuildIconButton(onPressed: onSwitchCamera, icon: Icons.edit_note),
        ],
      ],
    );
  }
}
