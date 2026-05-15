import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  Map<String, dynamic>? _todayWorkout;
  Map<String, dynamic>? _fullWorkoutPlan;
  Map<String, dynamic>? _todayStats;
  List<Map<String, dynamic>> _recentActivities = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get todayWorkout => _todayWorkout;
  Map<String, dynamic>? get fullWorkoutPlan => _fullWorkoutPlan;
  Map<String, dynamic>? get todayStats => _todayStats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    // Ensure session is loaded
    if (!_session.isLoaded) {
      await _session.initialize();
    }

    await Future.wait([
      _loadTodayWorkout(),
      _loadTodayStats(),
      _loadRecentActivities(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTodayWorkout() async {
    final cId = _session.customerId;
    if (cId == null) {
      _todayWorkout = _emptyWorkout();
      return;
    }

    try {
      // Get active workout plans for this customer
      final response = await _apiClient.dio.get(
        '${ApiConstants.workoutPlans}/customer/$cId/active',
      );
      if (response.statusCode == 200 && response.data['success']) {
        final plans = response.data['data'] as List?;
        if (plans != null && plans.isNotEmpty) {
          final plan = plans.first;
          _fullWorkoutPlan = plan;
          
          final exercisesRaw = plan['exercises'];
          List parsedExercises = [];
          
          if (exercisesRaw is String && exercisesRaw.isNotEmpty) {
            try {
              parsedExercises = jsonDecode(exercisesRaw);
            } catch (_) {
              parsedExercises = [];
            }
          } else if (exercisesRaw is List) {
            parsedExercises = exercisesRaw;
          }

          _todayWorkout = {
            'title': plan['title'] ?? 'Workout',
            'exercises': parsedExercises.length,
            'duration': plan['description'] ?? '45 min',
            'calories': parsedExercises.length * 40, // estimate
          };
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading workout: $e');
    }
    _todayWorkout = _emptyWorkout();
  }

  Future<void> _loadTodayStats() async {
    final cId = _session.customerId;
    if (cId == null) {
      _todayStats = _emptyStats();
      return;
    }

    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final response = await _apiClient.dio.get(
        '${ApiConstants.activityLogs}/customer/$cId/range',
        queryParameters: {'startDate': dateStr, 'endDate': dateStr},
      );
      if (response.statusCode == 200 && response.data['success']) {
        final logs = response.data['data'] as List?;
        if (logs != null && logs.isNotEmpty) {
          final log = logs.first;
          _todayStats = {
            'caloriesBurned': log['caloriesBurned'] ?? 0,
            'caloriesGoal': 600,
            'stepsWalked': log['steps'] ?? 0,
            'stepsGoal': 10000,
            'waterMl': log['waterMl'] ?? 0,
            'waterGoal': 3000,
          };
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading today stats: $e');
    }
    _todayStats = _emptyStats();
  }

  Future<void> _loadRecentActivities() async {
    final cId = _session.customerId;
    if (cId == null) {
      _recentActivities = [];
      return;
    }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.activityLogs}/customer/$cId/recent',
      );
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as List?;
        if (data != null) {
          _recentActivities = data.take(5).map<Map<String, dynamic>>((log) {
            final date = log['logDate'] ?? '';
            return {
              'type': 'workout',
              'title': log['notes'] ?? 'Activity on $date',
              'time': _formatDate(date),
              'calories': log['caloriesBurned'] ?? 0,
            };
          }).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
    }
    _recentActivities = [];
  }

  Map<String, dynamic> _emptyWorkout() => {
    'title': 'No workout planned',
    'exercises': 0,
    'duration': '0 min',
    'calories': 0,
  };

  Map<String, dynamic> _emptyStats() => {
    'caloriesBurned': 0,
    'caloriesGoal': 600,
    'stepsWalked': 0,
    'stepsGoal': 10000,
    'waterMl': 0,
    'waterGoal': 3000,
  };

  List<dynamic> _parseExercises(String json) {
    // Simple JSON array parse
    try {
      return List.from(
        (json.startsWith('[')) 
          ? (throw UnimplementedError()) // handled by Dart's json decode
          : [],
      );
    } catch (_) {
      return [];
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return dateStr;
    }
  }
}
