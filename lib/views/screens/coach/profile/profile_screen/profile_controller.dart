import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/auth_service.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coach profile summary + personal info form backed by
/// `GET/PATCH /user/get-my-profile` + `update-my-profile`.
class ProfileController extends ChangeNotifier {
  String name;
  String title;
  String? avatarUrl;
  String planName;
  String planSubtitle;
  bool planActive;
  int studentsCount;
  int reviewsCount;

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  String? profileImagePath;

  bool isSaving = false;
  bool isLoading = false;
  String? errorMessage;

  double _handicap = 0;
  String _ageRange = '25-34';
  String _practiceSessions = '3';

  ProfileController({
    this.name = '',
    this.title = 'Coach',
    this.avatarUrl,
    this.planName = '',
    this.planSubtitle = '',
    this.planActive = false,
    this.studentsCount = 0,
    this.reviewsCount = 0,
    String email = '',
  })  : fullNameController = TextEditingController(text: name),
        emailController = TextEditingController(text: email) {
    load();
  }

  Future<GolferService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return GolferService(
      apiService: ApiService(sharedPreferences: prefs),
    );
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final service = await _service();
      final response = await service.getMyProfile();
      final data = response['data'];
      if (data is Map) {
        _applyProfile(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyProfile(Map<String, dynamic> data) {
    name = '${data['name'] ?? data['fullName'] ?? name}'.trim();
    if (name.isEmpty) name = 'Coach';
    fullNameController.text = name;
    emailController.text = '${data['email'] ?? ''}'.trim();

    final image = data['profile'] ??
        data['profileImage'] ??
        data['avatar'] ??
        data['image'];
    if (image is String && image.trim().isNotEmpty) {
      avatarUrl = image.trim();
      profileImagePath = null;
    } else if (image is Map) {
      final url = '${image['url'] ?? image['secure_url'] ?? ''}'.trim();
      if (url.isNotEmpty) {
        avatarUrl = url;
        profileImagePath = null;
      }
    }

    final cert = '${data['certification'] ?? data['title'] ?? ''}'.trim();
    final years = data['experienceYears'] ?? data['yearsExperience'];
    if (cert.isNotEmpty && years != null) {
      title = '$cert · $years years exp.';
    } else if (cert.isNotEmpty) {
      title = cert;
    } else {
      title = 'Coach';
    }

    final stats = data['stats'] is Map
        ? Map<String, dynamic>.from(data['stats'] as Map)
        : data;
    studentsCount = _asInt(
      stats['studentsCount'] ?? stats['students'] ?? data['studentsCount'],
    );
    reviewsCount = _asInt(
      stats['reviewsCount'] ??
          stats['reviews'] ??
          data['reviewsCount'] ??
          data['completedReviews'],
    );

    final subscription = data['subscription'];
    if (subscription is Map) {
      planName = '${subscription['planName'] ?? subscription['planType'] ?? 'Coach'}'
          .trim();
      final status = '${subscription['status'] ?? ''}'.toLowerCase();
      planActive = status == 'active' || status == 'trialing';
      planSubtitle = planActive ? 'Active coaching plan' : 'No active plan';
    } else {
      planName = planName.isEmpty ? 'Coach' : planName;
      planSubtitle = planSubtitle.isEmpty ? 'Manage your students' : planSubtitle;
    }

    final handicapRaw = data['handicap'] ?? data['handicapIndex'];
    if (handicapRaw is num) _handicap = handicapRaw.toDouble();
    final age = '${data['age_range'] ?? data['ageRange'] ?? ''}'.trim();
    if (age.isNotEmpty) _ageRange = age;
    final practice =
        '${data['practiceSessionPerWeek'] ?? data['practice_sessions_per_week'] ?? ''}'
            .trim();
    if (practice.isNotEmpty) _practiceSessions = practice;
  }

  Future<void> pickProfileImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      profileImagePath = file.path;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Could not open gallery.';
      notifyListeners();
    }
  }

  void setProfileImage(String path) {
    profileImagePath = path;
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    if (fullNameController.text.trim().isEmpty) {
      errorMessage = 'Enter your full name.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final service = await _service();
      final response = await service.updateProfileBasics(
        name: fullNameController.text.trim(),
        profileImagePath: profileImagePath,
        ageRange: _ageRange,
        handicap: _handicap,
        practiceSessionPerWeek: _practiceSessions,
      );
      final data = response['data'];
      if (data is Map) {
        _applyProfile(Map<String, dynamic>.from(data));
      } else {
        name = fullNameController.text.trim();
        await load();
      }
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logOut() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    await AuthService(apiService: apiService).logout();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
