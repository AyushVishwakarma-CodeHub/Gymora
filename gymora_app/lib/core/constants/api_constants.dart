class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  // Users
  static const String users = '/users';

  // Gyms
  static const String gyms = '/gyms';
  static const String activeGyms = '/gyms/active';

  // Trainers
  static const String trainers = '/trainers';

  // Customers
  static const String customers = '/customers';

  // Memberships
  static const String memberships = '/memberships';

  // Payments
  static const String payments = '/payments';

  // Workout Plans
  static const String workoutPlans = '/workout-plans';

  // Diet Plans
  static const String dietPlans = '/diet-plans';

  // Activity Logs
  static const String activityLogs = '/activity-logs';

  // Notifications
  static const String notifications = '/notifications';

  // Analytics
  static const String analytics = '/analytics';
}
