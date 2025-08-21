import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/widgets/build_icon_button.dart';
import 'package:provider/provider.dart';

import 'camera_button.dart';

class CameraBottomControls extends StatelessWidget {
  const CameraBottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Access state via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: !cameraState.isPictureTaken
          ? _buildDefaultControlsWidgets(context)
          : _buildAfterControlsTakePictureWidgets(context),
    );
  }

  Widget _buildDefaultControlsWidgets(BuildContext context) {
    // Access controller via provider - no props needed!
    final cameraController = context.read<CameraController>();
    
    return Row(
      key: const ValueKey('before'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LIBRARY BUTTON
        BuildIconButton(
          onPressed: _onLibraryTap,
          icon: Icons.photo_library_outlined,
        ),

        // TAKE PICTURE BUTTON - No props needed!
        const CameraButton(),

        // CHANGE CAMERA
        BuildIconButton(
          onPressed: cameraController.switchCamera,
          icon: Icons.loop,
        ),
      ],
    );
  }

  Widget _buildAfterControlsTakePictureWidgets(BuildContext context) {
    // Access feed state and camera controller via provider
    final feedState = context.watch<FeedControllerState>();
    final cameraController = context.read<CameraController>();
    
    return Row(
      key: const ValueKey('after'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BuildIconButton(
          onPressed: cameraController.cancelDraft,
          icon: Icons.close,
        ),

        // Upload button with loading state
        SizedBox(
          width: AppDimensions.xxl * 2,
          height: AppDimensions.xxl * 2,
          child: feedState.isUploading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                )
              : feedState.isUploadSuccess 
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    )
                  : Transform.rotate(
                      angle: -0.785398,
                      child: BuildIconButton(
                        onPressed: feedState.isUploading ? () {} : cameraController.uploadMedia,
                        icon: Icons.send,
                        color: feedState.isUploading ? Colors.grey : AppColors.primary,
                      ),
                    ),
        ),

        BuildIconButton(
          onPressed: cameraController.switchCamera,
          icon: Icons.edit_note,
        ),
      ],
    );
  }

  void _onLibraryTap() {
    // TODO: Implement gallery access
  }
}
