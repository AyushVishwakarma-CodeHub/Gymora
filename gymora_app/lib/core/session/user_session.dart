import '../network/api_client.dart';
import '../constants/api_constants.dart';

/// Caches the logged-in user's customerId / trainerId / gymId
/// so every provider doesn't need to re-fetch from the backend.
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  final ApiClient _apiClient = ApiClient();

  Long? _userId;
  Long? _customerId;
  Long? _trainerId;
  Long? _gymId;
  Map<String, dynamic>? _gymProfile;
  String? _role;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _customerProfile;

  Long? get userId => _userId;
  Long? get customerId => _customerId;
  Long? get trainerId => _trainerId;
  Long? get gymId => _gymId;
  Map<String, dynamic>? get gymProfile => _gymProfile;
  String? get role => _role;
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get customerProfile => _customerProfile;

  bool get isLoaded => _userId != null && (_role == 'CUSTOMER' ? _customerId != null : (_role == 'TRAINER' ? _trainerId != null : (_role == 'GYM_ADMIN' ? _gymId != null : true)));
  bool get isCustomer => _role == 'CUSTOMER';
  bool get isTrainer => _role == 'TRAINER';
  bool get isGymAdmin => _role == 'GYM_ADMIN';
  bool get isSuperAdmin => _role == 'SUPER_ADMIN';

  bool _isInitializing = false;
  Future<void>? _initFuture;

  /// Call this once after login or on app start if token exists.
  /// Fetches the user profile and resolves specific IDs based on role.
  Future<bool> initialize() async {
    if (_isInitializing) {
      await _initFuture;
      return true;
    }
    if (isLoaded) return true;

    _isInitializing = true;
    _initFuture = _performInitialization();
    try {
      await _initFuture;
      return true;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _performInitialization() async {
    try {
      // 1. Get the basic user profile
      final userResponse = await _apiClient.dio.get(ApiConstants.currentUser);
      if (userResponse.statusCode == 200 && userResponse.data['success']) {
        _userProfile = userResponse.data['data'];
        _userId = _userProfile!['id'];
        _role = _userProfile!['role'];
      } else {
        throw Exception('User profile fetch failed');
      }

      // 2. Resolve IDs based on role
      if (_role == 'CUSTOMER') {
        await _resolveCustomerId();
      } else if (_role == 'TRAINER') {
        await _resolveTrainerId();
      } else if (_role == 'GYM_ADMIN') {
        await _resolveGymId();
      }
    } catch (e) {
      print('UserSession init error: $e');
      rethrow;
    }
  }

  Future<void> _resolveCustomerId() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.customers}/user/$_userId');
      if (response.statusCode == 200 && response.data['success']) {
        _customerProfile = response.data['data'];
        _customerId = _customerProfile!['id'];
      }
    } catch (e) {
      print('Customer profile not found: $e');
    }
  }

  Future<void> _resolveTrainerId() async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.trainers}/user/$_userId');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        _trainerId = data['id'];
      }
    } catch (e) {
      print('Trainer profile not found: $e');
    }
  }

  Future<void> _resolveGymId() async {
    try {
      print('Resolving gym for admin: $_userId');
      final response = await _apiClient.dio.get('${ApiConstants.gyms}/admin/$_userId');
      if (response.statusCode == 200 && response.data['success']) {
        final List gyms = response.data['data'];
        print('Found ${gyms.length} gyms for admin');
        if (gyms.isNotEmpty) {
          _gymProfile = gyms.first;
          _gymId = _gymProfile!['id'];
          print('Assigned gymId: $_gymId');
        }
      }
    } catch (e) {
      print('Gym resolution error for owner: $e');
    }
  }

  /// Call on logout
  void clear() {
    _userId = null;
    _customerId = null;
    _trainerId = null;
    _gymId = null;
    _role = null;
    _userProfile = null;
    _customerProfile = null;
  }
}

/// Type alias — Dart doesn't have Java's Long, just int
typedef Long = int;
