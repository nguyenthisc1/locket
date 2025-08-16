import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:provider/provider.dart';
import 'camera_preview.dart';
import 'camera_bottom_controls.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  late final CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Get controller from GetIt - following feed pattern
    _cameraController = getIt<CameraController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cameraController.initialize();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_cameraController.state.controller == null ||
        !_cameraController.state.controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // App is in background - let the controller manage disposal properly
      // Don't dispose directly as it causes issues with the widget tree
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground - reinitialize if needed
      if (!_cameraController.state.isInitialized) {
        _cameraController.initialize();
      }
    }
  }

  @override
  void dispose() {
    // Don't dispose the controller since it's a singleton managed by DI
    // The camera controller will be disposed when the app closes
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch to get state - following feed pattern
    final cameraState = context.watch<CameraControllerState>();
    
    if (!cameraState.isInitialized) {
      return _buildLoadingState();
    }

    return const Column(
      children: [
        CameraPreviewWrapper(),

        SizedBox(height: AppDimensions.xxl),

        CameraBottomControls(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
