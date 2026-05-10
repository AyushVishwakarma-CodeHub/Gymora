import 'dart:html' as html;
import 'token_storage.dart';

/// Web implementation — uses browser localStorage.
/// This is fast and works reliably on all mobile browsers.
class TokenStorageImpl implements TokenStorage {
  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    html.window.localStorage['access_token'] = accessToken;
    html.window.localStorage['refresh_token'] = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    html.window.localStorage.remove('access_token');
    html.window.localStorage.remove('refresh_token');
  }

  @override
  Future<String?> getAccessToken() async {
    return html.window.localStorage['access_token'];
  }

  @override
  Future<String?> getRefreshToken() async {
    return html.window.localStorage['refresh_token'];
  }

  @override
  Future<bool> hasToken() async {
    return html.window.localStorage.containsKey('access_token');
  }
}
