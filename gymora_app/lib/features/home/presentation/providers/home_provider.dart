import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _todayWorkout;
  Map<String, dynamic>? _todayStats;
  List<Map<String, dynamic>> _recentActivities = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get todayWorkout => _todayWorkout;
  Map<String, dynamic>? get todayStats => _todayStats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    // Simulated data for demo - replace with API calls
    await Future.delayed(const Duration(seconds: 1));

    _todayWorkout = {
      'title': 'Upper Body Strength',
      'exercises': 8,
      'duration': '45 min',
      'calories': 320,
    };

    _todayStats = {
      'caloriesBurned': 420,
      'caloriesGoal': 600,
      'stepsWalked': 5230,
      'stepsGoal': 10000,
      'waterMl': 1500,
      'waterGoal': 3000,
      'workoutsCompleted': 3,
      'weeklyGoal': 5,
    };

    _recentActivities = [
      {'type': 'workout', 'title': 'Chest & Triceps', 'time': '2h ago', 'calories': 280},
      {'type': 'meal', 'title': 'Protein Shake', 'time': '3h ago', 'calories': 150},
      {'type': 'workout', 'title': 'Morning Run', 'time': '6h ago', 'calories': 310},
    ];

    _isLoading = false;
    notifyListeners();
  }
}
