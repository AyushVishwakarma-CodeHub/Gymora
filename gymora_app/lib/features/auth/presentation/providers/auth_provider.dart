import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  AuthState _state = AuthState.initial;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  AuthState get state => _state;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String get userRole => _user?['role'] ?? 'CUSTOMER';
  bool get isCustomer => userRole == 'CUSTOMER';
  bool get isTrainer => userRole == 'TRAINER';
  bool get isGymAdmin => userRole == 'GYM_ADMIN';
  bool get isSuperAdmin => userRole == 'SUPER_ADMIN';

  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await _apiClient.hasToken();
      if (!hasToken) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return;
      }

      // Restore session from token
      final response = await _apiClient.dio.get(ApiConstants.currentUser);
      if (response.statusCode == 200 && response.data['success']) {
        _user = response.data['data'];
        _state = AuthState.authenticated;

        // Initialize session in background
        await _session.initialize();
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        await _apiClient.saveTokens(data['accessToken'], data['refreshToken']);
        _user = data['user'];
        _state = AuthState.authenticated;
        notifyListeners();

        // Initialize UserSession (resolves customerId/trainerId)
        await _session.initialize();

        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Login failed';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Connection error. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required String role,
    int? gymId,
    String? specialization,
    int? experienceYears,
    String? bio,
    String? address,
    String? certifications,
    String? socialLinks,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          'gymId': gymId,
          'specialization': specialization,
          'experienceYears': experienceYears,
          'bio': bio,
          'address': address,
          'certifications': certifications,
          'socialLinks': socialLinks,
        },
      );

      if (response.statusCode == 201 && response.data['success']) {
        final data = response.data['data'];
        await _apiClient.saveTokens(data['accessToken'], data['refreshToken']);
        _user = data['user'];
        _state = AuthState.authenticated;
        notifyListeners();

        // Initialize session
        await _session.initialize();

        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Registration failed';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Connection error. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearTokens();
    _session.clear();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
