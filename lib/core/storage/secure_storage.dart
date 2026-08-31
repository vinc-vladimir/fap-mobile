import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_constants.dart';

class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() =>
      _storage.read(key: ApiConstants.accessTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: ApiConstants.refreshTokenKey);

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: ApiConstants.accessTokenKey, value: token);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: ApiConstants.refreshTokenKey, value: token);

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
  }

  /// Whether a passkey is registered for the current account. Local flag only
  /// — the source of truth is the server once backend G2 ships (decision D5).
  Future<bool> readPasskeyEnabled() async {
    final value = await _storage.read(key: ApiConstants.passkeyEnabledKey);
    return value == 'true';
  }

  Future<void> writePasskeyEnabled(bool enabled) =>
      _storage.write(key: ApiConstants.passkeyEnabledKey, value: '$enabled');

  Future<void> clearPasskeyEnabled() =>
      _storage.delete(key: ApiConstants.passkeyEnabledKey);
}

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
