import 'package:flutter/material.dart';

class ActivityProvider extends ChangeNotifier {
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

    await Future.delayed(const Duration(seconds: 1));

    _weightHistory = List.generate(30, (i) => {
      'date': DateTime.now().subtract(Duration(days: 30 - i)).toIso8601String(),
      'weight': 75.0 - (i * 0.15) + (i % 3 == 0 ? 0.2 : -0.1),
    });

    _calorieHistory = List.generate(7, (i) => {
      'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
      'consumed': [2100, 1950, 2300, 2050, 1800, 2400, 2000][i],
      'burned': [350, 420, 280, 500, 380, 200, 450][i],
    });

    _isLoading = false;
    notifyListeners();
  }
}
