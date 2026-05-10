/// Abstract token storage — provides a platform-agnostic interface.
/// On web: uses localStorage (fast, no async overhead)
/// On mobile: uses FlutterSecureStorage (encrypted)

abstract class TokenStorage {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> hasToken();
}
