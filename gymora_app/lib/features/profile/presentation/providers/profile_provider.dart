import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _profileData = {};
  Map<String, dynamic> _membershipData = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get profileData => _profileData;
  Map<String, dynamic> get membershipData => _membershipData;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _profileData = {
      'fullName': 'Ayush Kumar',
      'email': 'ayush@example.com',
      'phone': '+91 9876543210',
      'height': 175.0,
      'weight': 72.5,
      'bmi': 23.7,
      'goal': 'MUSCLE_GAIN',
      'joinDate': '2025-01-15',
    };

    _membershipData = {
      'planName': 'Premium Monthly',
      'status': 'ACTIVE',
      'startDate': '2026-03-01',
      'endDate': '2026-04-01',
      'daysRemaining': 2,
      'progress': 0.93,
    };

    _isLoading = false;
    notifyListeners();
  }
}
