import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/auth_service.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';

enum OtpFlow { signUp, forgotPassword }

/// One controller class for the whole auth + onboarding flow.
class AuthController extends ChangeNotifier {
  AuthController({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  // ---------------------------------------------------------------------
  // Selected role (golfer / coach) — set on role selection screen
  // ---------------------------------------------------------------------
  UserRole? selectedRole;

  bool get isCoach => selectedRole == UserRole.coach;
  bool get isGolfer => selectedRole == UserRole.golfer;

  void setSelectedRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }

  /// Restores session from SharedPreferences after splash.
  /// Returns the saved role when token + user are present, otherwise null.
  UserRole? restoreSession() {
    if (!_authService.hasActiveSession) return null;

    final role = _authService.getSavedUserRole();
    if (role == null) return null;

    selectedRole = role;
    notifyListeners();
    return role;
  }

  /// Clears persisted auth and in-memory auth state (logout).
  Future<void> logout() async {
    await _authService.logout();
    selectedRole = null;
    clearError();
    notifyListeners();
  }

  /// Opens the app with an anonymous golfer token so swings can be recorded
  /// before sign-up. Register and login merge that data into the real account.
  Future<bool> continueAsGuest() async {
    return _runAuthCall(() async {
      final response = await _authService.createGuestSession();
      await _authService.persistAuthResponse(response);
      await _authService.rememberGuest(response);
      selectedRole = UserRole.golfer;
      await _authService.ensureRestorableSession(role: UserRole.golfer);
    });
  }

  // ---------------------------------------------------------------------
  // Shared loading / error state
  // ---------------------------------------------------------------------
  bool isLoading = false;
  String? errorMessage;

  /// Which OTP screen flow is active (sign-up vs forgot password).
  OtpFlow otpFlow = OtpFlow.signUp;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<bool> _runAuthCall(Future<void> Function() action) async {
    clearError();
    _setLoading(true);
    try {
      await action();
      _setLoading(false);
      return true;
    } on ApiError catch (e) {
      _setLoading(false);
      _setError(e.message);
      return false;
    } catch (_) {
      _setLoading(false);
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------
  String signInEmail = '';
  String signInPassword = '';
  bool obscureSignInPassword = true;

  void updateSignInEmail(String value) {
    signInEmail = value;
    notifyListeners();
  }

  void updateSignInPassword(String value) {
    signInPassword = value;
    notifyListeners();
  }

  void toggleSignInPasswordVisibility() {
    obscureSignInPassword = !obscureSignInPassword;
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (signInEmail.trim().isEmpty || signInPassword.isEmpty) {
      _setError('Please enter your email and password.');
      return false;
    }

    return _runAuthCall(() async {
      final response = await _authService.login(
        email: signInEmail.trim(),
        password: signInPassword,
      );
      await _authService.persistAuthResponse(response);
      try {
        await _authService.mergeStoredGuestAfterLogin(response);
      } catch (_) {}

      final apiRole = _authService.roleFromResponse(response);
      if (apiRole != null) {
        selectedRole = apiRole;
      }
      await _authService.ensureRestorableSession(role: apiRole);
    });
  }

  // ---------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------
  String fullName = '';
  String signUpEmail = '';
  String signUpPassword = '';
  bool obscureSignUpPassword = true;

  void updateFullName(String value) {
    fullName = value;
    notifyListeners();
  }

  void updateSignUpEmail(String value) {
    signUpEmail = value;
    notifyListeners();
  }

  void updateSignUpPassword(String value) {
    signUpPassword = value;
    notifyListeners();
  }

  void toggleSignUpPasswordVisibility() {
    obscureSignUpPassword = !obscureSignUpPassword;
    notifyListeners();
  }

  Future<bool> signUp() async {
    if (selectedRole == null) {
      _setError('Please choose your role first.');
      return false;
    }
    if (signUpEmail.trim().isEmpty || signUpPassword.isEmpty) {
      _setError('Please enter your email and password.');
      return false;
    }

    return _runAuthCall(() async {
      otpFlow = OtpFlow.signUp;
      final response = await _authService.register(
        name: fullName.trim(),
        email: signUpEmail.trim(),
        password: signUpPassword,
        role: selectedRole!,
      );
      // Some backends issue temporary/regular token at register; persist it
      // so verify-otp and profile update can be authorized.
      await _authService.persistAuthResponse(response);
    });
  }

  // ---------------------------------------------------------------------
  // Forgot Password — Enter Email
  // ---------------------------------------------------------------------
  String resetEmail = '';

  void updateResetEmail(String value) {
    resetEmail = value;
    notifyListeners();
  }

  Future<bool> sendResetCode() async {
    if (resetEmail.trim().isEmpty) {
      _setError('Please enter your email.');
      return false;
    }

    return _runAuthCall(() async {
      otpFlow = OtpFlow.forgotPassword;
      final response =
          await _authService.forgotPassword(email: resetEmail.trim());
      // Backend returns `data.token` from forgot-password. Persist it so
      // verify-otp / reset-password can work via Authorization header.
      await _authService.persistAuthResponse(response);
    });
  }

  // ---------------------------------------------------------------------
  // OTP Verification
  // ---------------------------------------------------------------------
  List<String> otpDigits = List.filled(6, '');

  void updateOtpDigit(int index, String value) {
    otpDigits[index] = value;
    notifyListeners();
  }

  void clearOtpDigits() {
    otpDigits = List.filled(6, '');
    notifyListeners();
  }

  String get otpCode => otpDigits.join();

  Future<bool> verifyOtp() async {
    if (!otpDigits.every((d) => d.isNotEmpty)) {
      _setError('Please enter the full OTP code.');
      return false;
    }

    return _runAuthCall(() async {
      if (otpFlow == OtpFlow.forgotPassword) {
        await _authService.verifyForgotPasswordOtp(otp: otpCode);
        return;
      }

      final response = await _authService.verifySignUpOtp(otp: otpCode);
      await _authService.persistAuthResponse(response);
      await _authService.clearStoredGuest();

      final apiRole = _authService.roleFromResponse(response);
      if (apiRole != null) {
        selectedRole = apiRole;
      }
      await _authService.ensureRestorableSession(role: apiRole);
    });
  }

  Future<bool> resendOtp() async {
    final email = otpFlow == OtpFlow.forgotPassword
        ? resetEmail.trim()
        : signUpEmail.trim();

    if (email.isEmpty) {
      _setError('Email is missing. Please go back and try again.');
      return false;
    }

    final success = await _runAuthCall(() async {
      final response = await _authService.resendOtp(email: email);
      await _authService.persistAuthResponse(response);
    });

    if (success) {
      clearOtpDigits();
    }
    return success;
  }

  // ---------------------------------------------------------------------
  // Reset Password
  // ---------------------------------------------------------------------
  String newPassword = '';
  String confirmPassword = '';
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  void updateNewPassword(String value) {
    newPassword = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> resetPassword() async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _setError('Please enter and confirm your new password.');
      return false;
    }
    if (newPassword != confirmPassword) {
      _setError('Passwords do not match.');
      return false;
    }

    return _runAuthCall(() async {
      await _authService.resetPassword(newPassword: newPassword);
    });
  }

  // ---------------------------------------------------------------------
  // Onboarding — "Tell us about yourself"
  // ---------------------------------------------------------------------
  String? ageRange;
  String gender = 'Man';
  double handicapIndex = 12.4;
  String practiceSessionsPerWeek = '2';
  String certificateName = '';
  String experienceYear = '';

  void setAgeRange(String value) {
    ageRange = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setCertificateName(String value) {
    certificateName = value;
    notifyListeners();
  }

  void setExperienceYear(String value) {
    experienceYear = value;
    notifyListeners();
  }

  void setPracticeSessions(String value) {
    practiceSessionsPerWeek = value;
    notifyListeners();
  }

  void incrementHandicap() {
    handicapIndex =
        double.parse((handicapIndex + 0.1).clamp(0, 40).toStringAsFixed(1));
    notifyListeners();
  }

  void decrementHandicap() {
    handicapIndex =
        double.parse((handicapIndex - 0.1).clamp(0, 40).toStringAsFixed(1));
    notifyListeners();
  }

  void setHandicapIndex(double value) {
    handicapIndex = double.parse(value.clamp(0, 40).toStringAsFixed(1));
    notifyListeners();
  }

  Future<bool> completeOnboarding() async {
    if (ageRange == null) {
      _setError('Please select your age range.');
      return false;
    }

    return _runAuthCall(() async {
      await _authService.updateRegisterProfile(
        age: ageRange!,
        gender: gender,
        handicap: handicapIndex,
        practiceSessionPerWeek: practiceSessionsPerWeek,
      );
    });
  }

  Future<bool> completeCoachOnboarding() async {
    if (ageRange == null) {
      _setError('Please select your age range.');
      return false;
    }
    if (certificateName.trim().isEmpty) {
      _setError('Please enter your certificate name.');
      return false;
    }
    if (experienceYear.trim().isEmpty) {
      _setError('Please enter your experience.');
      return false;
    }

    return _runAuthCall(() async {
      await _authService.updateRegisterProfile(
        age: ageRange!,
        gender: gender,
        certificateName: certificateName,
        experienceYear: experienceYear,
      );
    });
  }
}
