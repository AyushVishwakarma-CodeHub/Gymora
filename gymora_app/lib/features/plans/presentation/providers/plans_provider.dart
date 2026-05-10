import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class PlansProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  int _selectedDay = DateTime.now().weekday - 1;
  List<Map<String, dynamic>> _workoutPlans = [];
  List<Map<String, dynamic>> _dietPlans = [];

  bool get isLoading => _isLoading;
  int get selectedDay => _selectedDay;
  List<Map<String, dynamic>> get workoutPlans => _workoutPlans;
  List<Map<String, dynamic>> get dietPlans => _dietPlans;

  void setSelectedDay(int day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    if (!_session.isLoaded) {
      await _session.initialize();
    }

    await Future.wait([
      _loadWorkoutPlans(),
      _loadDietPlans(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWorkoutPlans() async {
    final cId = _session.customerId;
    if (cId == null) { _workoutPlans = []; return; }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.workoutPlans}/customer/$cId/active',
      );
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          _workoutPlans = data.map<Map<String, dynamic>>((plan) {
            List<Map<String, dynamic>> exercises = [];
            final exercisesRaw = plan['exercises'];
            if (exercisesRaw is String && exercisesRaw.isNotEmpty) {
              try {
                final parsed = jsonDecode(exercisesRaw) as List;
                exercises = parsed.map<Map<String, dynamic>>((e) => {
                  'name': e['name'] ?? '',
                  'sets': e['sets'] ?? '',
                  'rest': e['rest'] ?? '60s',
                }).toList();
              } catch (_) {}
            }

            return {
              'title': plan['title'] ?? 'Workout Plan',
              'exercises': exercises,
              'duration': plan['description'] ?? '',
              'difficulty': (plan['planType'] ?? 'WEEKLY').toString(),
              'trainerName': plan['trainerName'] ?? 'Your Trainer',
            };
          }).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading workout plans: $e');
    }
    _workoutPlans = [];
  }

  Future<void> _loadDietPlans() async {
    final cId = _session.customerId;
    if (cId == null) { _dietPlans = []; return; }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.dietPlans}/customer/$cId/active',
      );
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final List<Map<String, dynamic>> allMeals = [];
          for (final plan in data) {
            final mealsRaw = plan['meals'];
            if (mealsRaw is String && mealsRaw.isNotEmpty) {
              try {
                final parsed = jsonDecode(mealsRaw) as List;
                for (final m in parsed) {
                  allMeals.add({
                    'meal': m['meal'] ?? 'Meal',
                    'time': m['time'] ?? '',
                    'items': (m['items'] as List?)?.cast<String>() ?? <String>[],
                    'calories': m['cal'] ?? 0,
                  });
                }
              } catch (_) {}
            } else {
              allMeals.add({
                'meal': plan['title'] ?? 'Diet Plan',
                'time': plan['description'] ?? '',
                'items': <String>[],
                'calories': plan['targetCalories'] ?? 0,
              });
            }
          }
          _dietPlans = allMeals;
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading diet plans: $e');
    }
    _dietPlans = [];
  }
}
