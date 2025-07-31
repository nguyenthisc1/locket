import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/services/auth_middleware_service.dart';

class AuthRouteGuard extends StatefulWidget {
  final Widget child;
  final String route;

  const AuthRouteGuard({
    super.key,
    required this.child,
    required this.route,
  });

  @override
  State<AuthRouteGuard> createState() => _AuthRouteGuardState();
}

class _AuthRouteGuardState extends State<AuthRouteGuard> {
  final AuthMiddlewareService _authMiddleware = AuthMiddlewareService();
  bool _isLoading = true;
  String? _redirectRoute;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    final redirectRoute = await _authMiddleware.getRedirectRoute(widget.route);
    
    if (mounted) {
      setState(() {
        _redirectRoute = redirectRoute;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_redirectRoute != null) {
      // Use a post-frame callback to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(_redirectRoute!);
      });
      return _buildLoadingScreen();
    }

    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang kiểm tra quyền truy cập...',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}