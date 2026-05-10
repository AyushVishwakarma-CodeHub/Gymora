import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_mobile.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorageImpl();

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final data = response.data['data'];
                await _tokenStorage.saveTokens(
                  data['accessToken'],
                  data['refreshToken'],
                );

                error.requestOptions.headers['Authorization'] =
                    'Bearer ${data['accessToken']}';
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              await _tokenStorage.clearTokens();
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _tokenStorage.saveTokens(accessToken, refreshToken);
  }

  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  Future<bool> hasToken() async {
    return await _tokenStorage.hasToken();
  }
}
