import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class TrainerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  List<dynamic> _trainees = [];
  Map<String, dynamic>? _trainerProfile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<dynamic> get trainees => _trainees;
  Map<String, dynamic>? get trainerProfile => _trainerProfile;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrainerDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!_session.isLoaded) {
      await _session.initialize();
    }

    if (_session.trainerId == null) {
      _errorMessage = 'Trainer profile not found';
      _isLoading = false;
      notifyListeners();
      return;
    }

    await Future.wait([
      _loadTrainerProfile(),
      _loadTrainees(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTrainerProfile() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.trainers}/${_session.trainerId}');
      if (response.statusCode == 200 && response.data['success']) {
        _trainerProfile = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading trainer profile: $e');
    }
  }

  Future<void> _loadTrainees() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.customers}/trainer/${_session.trainerId}');
      if (response.statusCode == 200 && response.data['success']) {
        _trainees = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading trainees: $e');
    }
  }

  Future<bool> createWorkoutPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.workoutPlans,
        data: {
          ...planData,
          'trainerId': _session.trainerId,
        },
      );
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Error creating workout plan: $e');
      return false;
    }
  }

  Future<bool> createDietPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.dietPlans,
        data: {
          ...planData,
          'trainerId': _session.trainerId,
        },
      );
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Error creating diet plan: $e');
      return false;
    }
  }
}
