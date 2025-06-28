import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/auth/usecase/auth_usecases.dart';
import 'package:locket/presentation/auth/pages/email_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserEntity? _currentUser;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  late final AuthRepository _authRepository;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl();
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    if (_authRepository is AuthRepositoryImpl) {
      (_authRepository).dispose();
    }
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final result = await _getCurrentUserUseCase();
      result.fold(
        (failure) {
          DisplayMessage.error(context, failure.message);
          setState(() {
            _isLoading = false;
          });
        },
        (user) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    }
  }

  Future<void> _signOut() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final result = await _logoutUseCase();
      result.fold(
        (failure) {
          DisplayMessage.error(context, failure.message);
        },
        (_) {
          DisplayMessage.success(context, 'Đăng xuất thành công!');
          // Navigate to login page
          AppNavigator.pushReplacement(context, const EmailLoginPage());
        },
      );
    } catch (e) {
      if (!mounted) return;

      DisplayMessage.error(context, 'Có lỗi xảy ra: ${e.toString()}');
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _refreshUser() async {
    setState(() {
      _isLoading = true;
    });
    await _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locket'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshUser,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _signOut,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _refreshUser,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        _buildUserInfoCard(),
                        const SizedBox(height: AppDimensions.xl),
                      ],
                      Text(
                        'Bạn đã đăng nhập thành công!',
                        style: AppTypography.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.xxl),
                      ElevatedButton(
                        onPressed: _isLoggingOut ? null : _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child:
                            _isLoggingOut
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Đăng xuất',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _currentUser!.username.isNotEmpty
                        ? _currentUser!.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser!.username,
                        style: AppTypography.titleLarge,
                      ),
                      if (_currentUser!.isVerified)
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đã xác thực',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            _buildInfoRow('ID', _currentUser!.id),
            if (_currentUser!.email != null)
              _buildInfoRow('Email', _currentUser!.email!),
            if (_currentUser!.phoneNumber != null)
              _buildInfoRow('Số điện thoại', _currentUser!.phoneNumber!),
            _buildInfoRow('Ngày tạo', _formatDate(_currentUser!.createdAt)),
            if (_currentUser!.lastActiveAt != null)
              _buildInfoRow(
                'Hoạt động cuối',
                _formatDate(_currentUser!.lastActiveAt!),
              ),
            _buildInfoRow('Bạn bè', '${_currentUser!.friends.length} người'),
            _buildInfoRow(
              'Phòng chat',
              '${_currentUser!.chatRooms.length} phòng',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
