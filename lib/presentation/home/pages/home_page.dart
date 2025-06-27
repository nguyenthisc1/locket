import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserEntity? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    // try {
    //   // final result = await _authFirebaseRepository.getCurrentUser();
    //   result.fold(
    //     (failure) {
    //       DisplayMessage.error(context, failure.message);
    //     },
    //     (user) {
    //       setState(() {
    //         _currentUser = user;
    //         _isLoading = false;
    //       });
    //     },
    //   );
    // } catch (e) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    // }
  }

  Future<void> _signOut() async {
    // try {
    //   final result = await _authFirebaseRepository.signOut();
    //   result.fold(
    //     (failure) {
    //       DisplayMessage.error(context, failure.message);
    //     },
    //     (_) {
    //       DisplayMessage.success(context, 'Đăng xuất thành công!');
    //     },
    //   );
    // } catch (e) {
    //   DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 80, color: AppColors.primary),
                    const SizedBox(height: AppDimensions.xl),
                    Text(
                      'Chào mừng bạn!',
                      style: AppTypography.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    if (_currentUser != null) ...[
                      Text(
                        'Email: ${_currentUser!.email ?? 'N/A'}',
                        style: AppTypography.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        'ID: ${_currentUser!.id}',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.xl),
                    ],
                    Text(
                      'Bạn đã đăng nhập thành công!',
                      style: AppTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.xxl),
                    ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
