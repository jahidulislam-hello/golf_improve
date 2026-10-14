import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds all profile data and business logic.
/// Create ONE instance and pass it down to both screens so edits
/// made on PersonalInfoScreen are reflected back on ProfileScreen.
class ProfileController extends ChangeNotifier {
  // ---- Profile summary (shown on ProfileScreen) ----
  String name;
  String title;
  String? avatarUrl;
  String planName;
  String planSubtitle;
  bool planActive;
  int studentsCount;
  int reviewsCount;

  // ---- Personal info form ----
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  String? profileImagePath; // local path/url picked from camera/gallery

  bool isSaving = false;

  ProfileController({
    this.name = 'Alex Thompson',
    this.title = 'PGA Certified Coach · 15 years exp.',
    this.avatarUrl,
    this.planName = 'Pro Coach Plan',
    this.planSubtitle = 'Unlimited students & reviews',
    this.planActive = true,
    this.studentsCount = 4,
    this.reviewsCount = 138,
    String email = '',
  })  : fullNameController = TextEditingController(text: name),
        emailController = TextEditingController(text: email);

  /// Call from the camera "+" button on PersonalInfoScreen.
  void setProfileImage(String path) {
    profileImagePath = path;
    notifyListeners();
  }

  /// Validates and "saves" the personal info form.
  /// Returns true on success so the UI can pop/show a message.
  Future<bool> saveChanges() async {
    if (fullNameController.text.trim().isEmpty) return false;
    if (!emailController.text.contains('@')) return false;

    isSaving = true;
    notifyListeners();

    // TODO: replace with your real API call.
    await Future.delayed(const Duration(milliseconds: 600));

    name = fullNameController.text.trim();
    isSaving = false;
    notifyListeners();
    return true;
  }

  Future<void> logOut() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    await AuthService(apiService: apiService).logout();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}