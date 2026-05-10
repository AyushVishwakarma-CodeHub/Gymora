import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  int _selectedTab = 0;
  List<Map<String, dynamic>> _weightHistory = [];
  List<Map<String, dynamic>> _calorieHistory = [];

  bool get isLoading => _isLoading;
  int get selectedTab => _selectedTab;
  List<Map<String, dynamic>> get weightHistory => _weightHistory;
  List<Map<String, dynamic>> get calorieHistory => _calorieHistory;

  void setSelectedTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadActivityData() async {
    _isLoading = true;
    notifyListeners();

    if (!_session.isLoaded) {
      await _session.initialize();
    }

    await Future.wait([
      _loadWeightHistory(),
      _loadCalorieHistory(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWeightHistory() async {
    final cId = _session.customerId;
    if (cId == null) { _weightHistory = []; return; }

    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final response = await _apiClient.dio.get(
        '${ApiConstants.activityLogs}/customer/$cId/range',
        queryParameters: {
          'startDate': _formatDateParam(startDate),
          'endDate': _formatDateParam(now),
        },
      );
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          _weightHistory = data
              .where((log) => log['weightKg'] != null)
              .map<Map<String, dynamic>>((log) => {
                'date': log['logDate'] ?? '',
                'weight': (log['weightKg'] as num).toDouble(),
              })
              .toList();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading weight history: $e');
    }
    _weightHistory = [];
  }

  Future<void> _loadCalorieHistory() async {
    final cId = _session.customerId;
    if (cId == null) { _calorieHistory = []; return; }

    try {
      final now = DateTime.now();
      // Last 7 days for weekly view
      final startDate = now.subtract(const Duration(days: 6));
      final response = await _apiClient.dio.get(
        '${ApiConstants.activityLogs}/customer/$cId/range',
        queryParameters: {
          'startDate': _formatDateParam(startDate),
          'endDate': _formatDateParam(now),
        },
      );
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          _calorieHistory = data.map<Map<String, dynamic>>((log) {
            final date = DateTime.tryParse(log['logDate'] ?? '');
            final dayName = date != null ? days[date.weekday - 1] : '';
            return {
              'day': dayName,
              'consumed': log['caloriesConsumed'] ?? 0,
              'burned': log['caloriesBurned'] ?? 0,
            };
          }).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading calorie history: $e');
    }
    _calorieHistory = [];
  }

  String _formatDateParam(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
