import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/widgets/camera/camera.dart';
import 'package:locket/presentation/home/widgets/history_feed.dart';
import 'package:provider/provider.dart';

class CameraSection extends StatelessWidget {
  final VoidCallback onHistoryFeedTap;

  const CameraSection({required this.onHistoryFeedTap});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraControllerState>.value(
          value: getIt<CameraControllerState>(),
        ),
        Provider<CameraController>.value(value: getIt<CameraController>()),
      ],
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.md,
              right: AppDimensions.md,
              top: AppDimensions.appBarHeight + AppDimensions.xl,
            ),
            child: const Camera(),
          ),
          Positioned(
            bottom: AppDimensions.xl,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onHistoryFeedTap,
              child: const Center(child: HistoryFeed()),
            ),
          ),
        ],
      ),
    );
  }
}