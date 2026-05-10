import 'token_storage.dart';

/// Stub — this file is never actually used at runtime.
/// Dart's conditional import system picks the correct implementation.
class TokenStorageImpl implements TokenStorage {
  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
  @override
  Future<void> clearTokens() async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<bool> hasToken() async => false;
}
