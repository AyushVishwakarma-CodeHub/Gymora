import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class GymOwnerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  Map<String, dynamic>? _gymProfile;
  List<dynamic> _members = [];
  List<dynamic> _trainers = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get gymProfile => _gymProfile;
  List<dynamic> get members => _members;
  List<dynamic> get trainers => _trainers;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!_session.isLoaded) {
      await _session.initialize();
    }

    if (_session.gymId == null) {
      _errorMessage = 'Gym not found for this owner';
      _isLoading = false;
      notifyListeners();
      return;
    }

    await Future.wait([
      _loadGymProfile(),
      _loadMembers(),
      _loadTrainers(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadGymProfile() async {
    // Start with session cached data if available
    if (_session.gymProfile != null) {
      _gymProfile = _session.gymProfile;
    }

    try {
      final response = await _apiClient.dio.get('${ApiConstants.gyms}/${_session.gymId}');
      if (response.statusCode == 200 && response.data['success']) {
        _gymProfile = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading gym profile: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.customers}/gym/${_session.gymId}');
      if (response.statusCode == 200 && response.data['success']) {
        _members = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
    }
  }

  Future<void> _loadTrainers() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.trainers}/gym/${_session.gymId}');
      if (response.statusCode == 200 && response.data['success']) {
        _trainers = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading trainers: $e');
    }
  }

  Future<bool> addMember(String fullName, String email, String phone, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiClient.dio.post(
        '/gym-owner/${_session.gymId}/members',
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'CUSTOMER',
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        await _loadMembers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding member: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrainer(String fullName, String email, String phone, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiClient.dio.post(
        '/gym-owner/${_session.gymId}/trainers',
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'TRAINER',
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        await _loadTrainers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding trainer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveTrainer(Long trainerId) async {
    try {
      final response = await _apiClient.dio.patch('/gym-owner/trainers/$trainerId/approve');
      if (response.statusCode == 200 && response.data['success']) {
        await _loadTrainers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error approving trainer: $e');
      return false;
    }
  }
}
