import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:logger/logger.dart';

/// Service for validating and managing JWT tokens
class TokenValidationService {
  final TokenStorage<AuthTokenPair> _tokenStorage;
  final Logger _logger;

  TokenValidationService({
    required TokenStorage<AuthTokenPair> tokenStorage,
    Logger? logger,
  }) : _tokenStorage = tokenStorage,
       _logger = logger ?? Logger(
         printer: PrettyPrinter(colors: true, printEmojis: true),
       );

  /// Check if stored tokens are valid and not expired
  /// Returns null if tokens are invalid or expired
  Future<AuthTokenPair?> getValidTokens() async {
    try {
      final tokenPair = await _tokenStorage.read();
      
      if (tokenPair == null) {
        _logger.d('🔍 No tokens found in storage');
        return null;
      }

      // Check if tokens are valid
      if (!tokenPair.areTokensValid) {
        _logger.w('⚠️ Tokens are expired or invalid, clearing storage');
        await _tokenStorage.delete();
        return null;
      }

      // Log token status
      final accessTokenRemaining = tokenPair.accessTokenRemainingTime;
      if (accessTokenRemaining != null) {
        _logger.d('✅ Access token valid for: ${_formatDuration(accessTokenRemaining)}');
      }

      return tokenPair;
    } catch (e) {
      _logger.e('❌ Error validating tokens: $e');
      // Clear potentially corrupted tokens
      await _tokenStorage.delete();
      return null;
    }
  }

  /// Check if access token will expire soon (within 5 minutes)
  Future<bool> shouldRefreshToken() async {
    try {
      final tokenPair = await _tokenStorage.read();
      
      if (tokenPair == null) {
        return false; // No token to refresh
      }

      // Check if access token will expire within 5 minutes
      const refreshThreshold = Duration(minutes: 5);
      final shouldRefresh = tokenPair.willAccessTokenExpireWithin(refreshThreshold);
      
      if (shouldRefresh) {
        _logger.d('🔄 Access token will expire soon, should refresh');
      }
      
      return shouldRefresh;
    } catch (e) {
      _logger.e('❌ Error checking token refresh need: $e');
      return false;
    }
  }

  /// Validate tokens and clear if expired
  /// Returns true if tokens are valid, false if they were cleared
  Future<bool> validateAndCleanupTokens() async {
    final validTokens = await getValidTokens();
    return validTokens != null;
  }

  /// Get token information for debugging
  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final tokenPair = await _tokenStorage.read();
      
      if (tokenPair == null) {
        return {'status': 'no_tokens'};
      }

      return {
        'status': 'tokens_found',
        'access_token_expired': tokenPair.isAccessTokenExpired,
        'refresh_token_expired': tokenPair.isRefreshTokenExpired,
        'access_token_expiration': tokenPair.accessTokenExpirationDate?.toIso8601String(),
        'refresh_token_expiration': tokenPair.refreshTokenExpirationDate?.toIso8601String(),
        'access_token_remaining': tokenPair.accessTokenRemainingTime?.inMinutes,
        'tokens_valid': tokenPair.areTokensValid,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Format duration for logging
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
