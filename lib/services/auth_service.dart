import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';

/// Maps UI gender labels to API values.
String mapGenderToApi(String uiGender) {
  switch (uiGender) {
    case 'Man':
      return 'male';
    case 'Woman':
      return 'female';
    case 'Non-binary':
    case 'Prefer not to say':
      return 'other';
    default:
      return 'other';
  }
}

class AuthService {
  final ApiService _api;

  AuthService({required ApiService apiService}) : _api = apiService;

  Future<void> clearSession() => _api.clearUserData();

  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _api.post(
      ApiConstants.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.apiValue,
      },
    );
  }

  Future<dynamic> verifySignUpOtp({
    required String otp,
    required String email,
  }) {
    return _api.post(
      ApiConstants.verifyOtp,
      body: {
        'otp': otp,
        'email': email,
      },
    );
  }

  Future<dynamic> resendOtp({required String email}) {
    return _api.post(
      ApiConstants.resendOTP,
      body: {'email': email},
    );
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) {
    return _api.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<dynamic> forgotPassword({required String email}) {
    return _api.post(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );
  }

  Future<dynamic> verifyForgotPasswordOtp({
    required String otp,
  }) {
    return _api.post(
      ApiConstants.forgotPasswordOTPVerify,
      body: {
        'otp': otp,
      },
    );
  }

  Future<dynamic> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    return _api.post(
      ApiConstants.resetPassword,
      body: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<dynamic> updateRegisterProfile({
    required String age,
    required String gender,
    double? handicap,
    String? practiceSessionPerWeek,
    String? certificateName,
    String? experienceYear,
  }) {
    final fields = <String, String>{
      'age': age,
      'gender': mapGenderToApi(gender),
    };
    if (handicap != null) {
      fields['handicap'] = handicap.toStringAsFixed(1);
    }
    if (practiceSessionPerWeek != null && practiceSessionPerWeek.isNotEmpty) {
      fields['practiceSessionPerWeek'] = practiceSessionPerWeek;
    }
    if (certificateName != null && certificateName.trim().isNotEmpty) {
      fields['certificateName'] = certificateName.trim();
    }
    if (experienceYear != null && experienceYear.trim().isNotEmpty) {
      fields['experience'] = experienceYear.trim();
    }

    return _api.multipartRequest(
      ApiConstants.updateRegisterProfile,
      method: 'PATCH',
      fields: fields,
    );
  }

  /// Extracts and persists tokens + user from common API response shapes.
  Future<void> persistAuthResponse(dynamic response) async {
    final root = _asMap(response);
    if (root == null) return;

    final data = _asMap(root['data']) ?? root;
    final tokens = _asMap(data['tokens']) ?? data;

    final accessToken = _readString(tokens, [
      'accessToken',
      'access_token',
      'token',
    ]);
    final refreshToken = _readString(tokens, [
      'refreshToken',
      'refresh_token',
    ]);
    final accessExpires = _readString(tokens, [
      'accessTokenExpiresAt',
      'access_token_expires_at',
      'accessExpiresAt',
    ]);
    final refreshExpires = _readString(tokens, [
      'refreshTokenExpiresAt',
      'refresh_token_expires_at',
      'refreshExpiresAt',
    ]);

    if (accessToken != null && refreshToken != null) {
      await _api.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: accessExpires ?? '',
        refreshTokenExpiresAt: refreshExpires ?? '',
      );
    } else if (accessToken != null) {
      await _api.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
        accessTokenExpiresAt: accessExpires ?? '',
        refreshTokenExpiresAt: refreshExpires ?? '',
      );
    }

    // Backend responses we saw:
    // - register: { data: { token: ... } } (no user yet)
    // - verify-otp: { data: { results: { ...user... }, token: ... } }
    // - some profile calls: { data: { ...profile... } }
    final user = _asMap(data['user']) ??
        _asMap(data['results']) ??
        _asMap(root['user']) ??
        _asMap(root['results']) ??
        // Fallback: some APIs return the user object directly under `data`.
        (data.isNotEmpty && data.containsKey('email') ? data : null);
    if (user != null) {
      await _api.saveUserData(user);
    }
  }

  /// True when a saved access token exists and the user is marked logged in.
  bool get hasActiveSession {
    final token = _api.getAccessToken();
    if (token == null || token.isEmpty) return false;
    return _api.isLoggedIn;
  }

  /// Reads role from persisted user data after login / OTP verify.
  UserRole? getSavedUserRole() {
    final user = _api.getUserData();
    if (user == null) return null;
    return UserRoleApi.fromApiValue(
      _readString(user, ['role', 'userType']),
    );
  }

  /// Ensures splash can restore session after login (token + role + logged-in flag).
  Future<void> ensureRestorableSession({UserRole? role}) async {
    final token = _api.getAccessToken();
    if (token == null || token.isEmpty) return;

    final existing = _api.getUserData();
    if (existing != null) {
      if (!_api.isLoggedIn) {
        await _api.saveUserData(existing);
      }
      return;
    }

    if (role != null) {
      await _api.saveUserData({'role': role.apiValue});
    }
  }

  UserRole? roleFromResponse(dynamic response) {
    final root = _asMap(response);
    if (root == null) return null;

    final data = _asMap(root['data']) ?? root;
    // Role is typically inside `data.results.role` for verify-otp.
    final userCandidate = _asMap(data['user']) ??
        _asMap(data['results']) ??
        data;
    return UserRoleApi.fromApiValue(
      _readString(userCandidate, ['role', 'userType']),
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _readString(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
