import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

enum GymManagementState { initial, loading, loaded, error }

class GymProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  GymManagementState _state = GymManagementState.initial;
  List<dynamic> _pendingGyms = [];
  String? _errorMessage;

  GymManagementState get state => _state;
  List<dynamic> get pendingGyms => _pendingGyms;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPendingGyms() async {
    _state = GymManagementState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/gyms/pending');
      if (response.statusCode == 200 && response.data['success']) {
        _pendingGyms = response.data['data'];
        _state = GymManagementState.loaded;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to fetch gyms';
        _state = GymManagementState.error;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please try again.';
      _state = GymManagementState.error;
    }
    notifyListeners();
  }

  Future<bool> updateGymStatus(String id, String status) async {
    try {
      final response = await _apiClient.dio.patch(
        '/gyms/$id/status',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200 && response.data['success']) {
        await fetchPendingGyms();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating gym status: $e');
    }
    return false;
  }
}
