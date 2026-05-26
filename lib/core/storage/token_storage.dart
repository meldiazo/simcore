import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredTokens {
  const StoredTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

abstract interface class TokenStorage {
  Future<void> saveTokens(StoredTokens tokens);

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<StoredTokens?> getTokens();

  Future<bool> hasTokens();

  Future<void> clearTokens();
}

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'simcore_access_token';
  static const String _refreshTokenKey = 'simcore_refresh_token';

  @override
  Future<void> saveTokens(StoredTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<StoredTokens?> getTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null) return null;

    return StoredTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<bool> hasTokens() async {
    final tokens = await getTokens();
    return tokens != null;
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
