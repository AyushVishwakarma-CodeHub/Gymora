import 'package:flutter/material.dart';

class PlansProvider extends ChangeNotifier {
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

    await Future.delayed(const Duration(seconds: 1));

    _workoutPlans = [
      {
        'title': 'Chest & Triceps',
        'exercises': [
          {'name': 'Bench Press', 'sets': '4x12', 'rest': '90s'},
          {'name': 'Incline Dumbbell Press', 'sets': '3x12', 'rest': '60s'},
          {'name': 'Cable Flyes', 'sets': '3x15', 'rest': '60s'},
          {'name': 'Tricep Pushdowns', 'sets': '3x12', 'rest': '60s'},
          {'name': 'Overhead Tricep Extension', 'sets': '3x12', 'rest': '60s'},
        ],
        'duration': '55 min',
        'difficulty': 'Intermediate',
      },
      {
        'title': 'Core Workout',
        'exercises': [
          {'name': 'Plank Hold', 'sets': '3x60s', 'rest': '30s'},
          {'name': 'Russian Twists', 'sets': '3x20', 'rest': '30s'},
          {'name': 'Leg Raises', 'sets': '3x15', 'rest': '30s'},
        ],
        'duration': '25 min',
        'difficulty': 'Beginner',
      },
    ];

    _dietPlans = [
      {
        'meal': 'Breakfast',
        'time': '8:00 AM',
        'items': ['Oatmeal with berries', 'Protein shake', '2 boiled eggs'],
        'calories': 450,
      },
      {
        'meal': 'Lunch',
        'time': '1:00 PM',
        'items': ['Grilled chicken breast', 'Brown rice', 'Mixed vegetables'],
        'calories': 650,
      },
      {
        'meal': 'Snack',
        'time': '4:00 PM',
        'items': ['Greek yogurt', 'Almonds', 'Apple'],
        'calories': 250,
      },
      {
        'meal': 'Dinner',
        'time': '7:30 PM',
        'items': ['Salmon fillet', 'Quinoa', 'Steamed broccoli'],
        'calories': 550,
      },
    ];

    _isLoading = false;
    notifyListeners();
  }
}
