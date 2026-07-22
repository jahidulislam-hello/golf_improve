import 'package:flutter/material.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';

/// One controller class for the whole auth + onboarding flow, as requested.
/// Wire it up with `provider`:
///
///   ChangeNotifierProvider(create: (_) => AuthController(), child: MyApp())
///
/// and read it in a screen with:
///
///   final auth = context.watch<AuthController>();
class AuthController extends ChangeNotifier {
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

  // ---------------------------------------------------------------------
  // Shared loading / error state
  // ---------------------------------------------------------------------
  bool isLoading = false;
  String? errorMessage;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
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
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return signInEmail.isNotEmpty && signInPassword.isNotEmpty;
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
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return fullName.isNotEmpty &&
        signUpEmail.isNotEmpty &&
        signUpPassword.isNotEmpty;
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
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return resetEmail.isNotEmpty;
  }

  // ---------------------------------------------------------------------
  // OTP Verification
  // ---------------------------------------------------------------------
  List<String> otpDigits = List.filled(6, '');

  void updateOtpDigit(int index, String value) {
    otpDigits[index] = value;
    notifyListeners();
  }

  String get otpCode => otpDigits.join();

  Future<bool> verifyOtp() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return otpDigits.every((d) => d.isNotEmpty);
  }

  Future<void> resendOtp() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 500));
    otpDigits = List.filled(6, '');
    _setLoading(false);
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
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return newPassword.isNotEmpty && newPassword == confirmPassword;
  }

  // ---------------------------------------------------------------------
  // Onboarding — "Tell us about yourself"
  // ---------------------------------------------------------------------
  String? ageRange; // e.g. "24"
  String gender = 'Man'; // Man / Woman / Non-binary / Prefer not to say
  double handicapIndex = 12.4;
  String practiceSessionsPerWeek = '2'; // '1' / '2' / '3+'

  void setAgeRange(String value) {
    ageRange = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setPracticeSessions(String value) {
    practiceSessionsPerWeek = value;
    notifyListeners();
  }

  void incrementHandicap() {
    handicapIndex = double.parse((handicapIndex + 0.1).clamp(0, 40).toStringAsFixed(1));
    notifyListeners();
  }

  void decrementHandicap() {
    handicapIndex = double.parse((handicapIndex - 0.1).clamp(0, 40).toStringAsFixed(1));
    notifyListeners();
  }

  Future<bool> completeOnboarding() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 700));
    _setLoading(false);
    return ageRange != null;
  }
}
