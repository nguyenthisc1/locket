import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/data/auth/models/token_model.dart';

/// Implementation of TokenStorage for securely storing authentication tokens
class TokenStorageImpl implements TokenStorage<AuthTokenPair> {
  final FlutterSecureStorage _secureStorage;

  /// Creates a new TokenStorageImpl with the given secure storage
  const TokenStorageImpl(this._secureStorage);
  @override
  Future<AuthTokenPair?> read() async {
    final tokenJson = await _secureStorage.read(
      key: TokensStorageKeys.authToken.keyName,
    );
    if (tokenJson == null || tokenJson.isEmpty) return null;
    return AuthTokenPair.fromJson(jsonDecode(tokenJson));
  }

  @override
  Future<void> write(AuthTokenPair token) {
    return _secureStorage.write(
      key: TokensStorageKeys.authToken.keyName,
      value: jsonEncode(token.toJson()),
    );
  }

  @override
  Future<void> delete() async {
    for (final key in TokensStorageKeys.values) {
      await _secureStorage.delete(key: key.keyName);
    }
  }
}

/// Keys for TokenStorageImpl
enum TokensStorageKeys {
  /// Key for storing authentication tokens
  authToken('app_auth_token');

  /// Key name
  final String keyName;
  const TokensStorageKeys(this.keyName);
}
