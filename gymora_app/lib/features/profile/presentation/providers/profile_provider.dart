import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/user_session.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final UserSession _session = UserSession();

  bool _isLoading = false;
  Map<String, dynamic> _profileData = {};
  Map<String, dynamic> _membershipData = {};
  Map<String, dynamic> _gymData = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get profileData => _profileData;
  Map<String, dynamic> get membershipData => _membershipData;
  Map<String, dynamic> get gymData => _gymData;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    if (!_session.isLoaded) {
      await _session.initialize();
    }

    await _loadUserProfile();
    if (_session.isCustomer) {
      await _loadMembership();
    } else if (_session.isGymAdmin) {
      if (_session.gymId == null) {
        await _session.initialize();
      }
      await _loadGymData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = _session.userProfile;
      _profileData = {
        'fullName': userProfile?['fullName'] ?? 'User',
        'email': userProfile?['email'] ?? '',
        'phone': userProfile?['phone'] ?? '',
        'role': userProfile?['role'] ?? 'CUSTOMER',
        'joinDate': userProfile?['createdAt'] ?? '',
      };

      if (_session.isCustomer) {
        final customerProfile = _session.customerProfile;
        _profileData.addAll({
          'height': customerProfile?['heightCm'] ?? 0.0,
          'weight': customerProfile?['weightKg'] ?? 0.0,
          'bmi': _calculateBMI(customerProfile?['heightCm'], customerProfile?['weightKg']),
          'goal': customerProfile?['goal'] ?? '',
          'gymName': customerProfile?['gymName'] ?? 'Not assigned',
          'trainerName': customerProfile?['trainerName'] ?? 'Not assigned',
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _loadGymData() async {
    if (_session.gymId == null) return;
    try {
      final response = await _apiClient.dio.get('${ApiConstants.gyms}/${_session.gymId}');
      if (response.statusCode == 200 && response.data['success']) {
        _gymData = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error loading gym data for profile: $e');
    }
  }

  Future<void> _loadMembership() async {
    final cId = _session.customerId;
    if (cId == null) {
      _membershipData = _defaultMembership();
      return;
    }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.memberships}/customer/$cId',
      );
      if (response.statusCode == 200 && response.data['success']) {
        final memberships = response.data['data'] as List?;
        if (memberships != null && memberships.isNotEmpty) {
          // Get the most recent/active membership
          final data = memberships.first;
          final endDate = DateTime.tryParse(data['endDate'] ?? '');
          final startDate = DateTime.tryParse(data['startDate'] ?? '');
          final now = DateTime.now();
          int daysRemaining = 0;
          double progress = 0;
          if (endDate != null) {
            daysRemaining = endDate.difference(now).inDays;
            if (daysRemaining < 0) daysRemaining = 0;
            if (startDate != null) {
              final totalDays = endDate.difference(startDate).inDays;
              final elapsed = now.difference(startDate).inDays;
              progress = totalDays > 0 ? (elapsed / totalDays).clamp(0.0, 1.0) : 0.0;
            }
          }
          _membershipData = {
            'planName': data['planName'] ?? data['membershipType'] ?? 'Plan',
            'status': data['status'] ?? 'ACTIVE',
            'startDate': data['startDate'] ?? '',
            'endDate': data['endDate'] ?? '',
            'daysRemaining': daysRemaining,
            'progress': progress,
          };
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading membership: $e');
    }
    _membershipData = _defaultMembership();
  }

  double _calculateBMI(dynamic heightCm, dynamic weightKg) {
    if (heightCm == null || weightKg == null) return 0.0;
    final h = (heightCm is num) ? heightCm.toDouble() : 0.0;
    final w = (weightKg is num) ? weightKg.toDouble() : 0.0;
    if (h <= 0) return 0.0;
    final heightM = h / 100;
    return double.parse((w / (heightM * heightM)).toStringAsFixed(1));
  }

  Map<String, dynamic> _defaultMembership() {
    return {
      'planName': 'No Active Plan',
      'status': 'INACTIVE',
      'startDate': '',
      'endDate': '',
      'daysRemaining': 0,
      'progress': 0.0,
    };
  }
}
