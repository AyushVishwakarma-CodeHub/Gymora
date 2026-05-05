import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'models/dashboard_overview.dart';

class AdminRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardOverview?> getSystemOverview() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.analytics}/overview');
      if (response.statusCode == 200 && response.data['success']) {
        return DashboardOverview.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load analytics');
    }
  }

  Future<DashboardOverview?> getGymAnalytics(int gymId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.analytics}/gyms/$gymId');
      if (response.statusCode == 200 && response.data['success']) {
        return DashboardOverview.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load gym analytics');
    }
  }
}
