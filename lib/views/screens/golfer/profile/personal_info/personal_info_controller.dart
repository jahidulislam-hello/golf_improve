import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { man, woman, nonBinary, preferNotToSay }

extension GenderLabel on Gender {
  String get label {
    switch (this) {
      case Gender.man:
        return 'Man';
      case Gender.woman:
        return 'Woman';
      case Gender.nonBinary:
        return 'Non-binary';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

/// Editable personal info, loaded from GET /user/get-my-profile.
class GolferPersonalInfoController extends ChangeNotifier {
  GolferPersonalInfoController()
      : nameController = TextEditingController(),
        emailController = TextEditingController() {
    loadProfile();
  }

  static const double minHandicap = -9.9;
  static const double maxHandicap = 54.0;
  static const List<String> ageRangeOptions = [
    'Under 18',
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55–64',
    '65+',
  ];

  final TextEditingController nameController;
  final TextEditingController emailController;

  String? ageRange;
  Gender? _gender;
  double _handicapIndex = 0;
  int _practiceSessionsPerWeek = 0;
  String? avatarUrl;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Gender? get gender => _gender;
  double get handicapIndex => _handicapIndex;
  int get practiceSessionsPerWeek => _practiceSessionsPerWeek;

  double get handicapProgress =>
      (_handicapIndex - minHandicap) / (maxHandicap - minHandicap);

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final golferService = await _service();
      final response = await golferService.getMyProfile();
      _applyProfile(response['data']);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyProfile(dynamic rawData) {
    if (rawData is! Map) return;
    final data = Map<String, dynamic>.from(rawData);

    nameController.text = (data['name'] ?? '').toString();
    emailController.text = (data['email'] ?? '').toString();
    final profileUrl = data['profileUrl']?.toString();
    avatarUrl = (profileUrl != null && profileUrl.isNotEmpty) ? profileUrl : null;
    ageRange = _ageRangeFromApi(data['age']);
    _gender = GenderApi.fromApi(data['gender']?.toString());
    _handicapIndex = data['handicap'] is num
        ? (data['handicap'] as num).toDouble()
        : double.tryParse('${data['handicap'] ?? ''}') ?? 0;
    _practiceSessionsPerWeek = _practiceFromApi(data['practiceSessionPerWeek']);
  }

  String? _ageRangeFromApi(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    final normalized = text.replaceAll('-', '–');
    if (ageRangeOptions.contains(text)) return text;
    if (ageRangeOptions.contains(normalized)) return normalized;
    final n = int.tryParse(text);
    if (n == null) return null;
    if (n < 18) return 'Under 18';
    if (n <= 24) return '18–24';
    if (n <= 34) return '25–34';
    if (n <= 44) return '35–44';
    if (n <= 54) return '45–54';
    if (n <= 64) return '55–64';
    return '65+';
  }

  int _practiceFromApi(dynamic raw) {
    final text = '${raw ?? ''}'.trim();
    if (text.isEmpty) return 0;
    if (text.startsWith('3')) return 3;
    return int.tryParse(text) ?? 0;
  }

  void setAgeRange(String? value) {
    ageRange = value;
    notifyListeners();
  }

  void setGender(Gender value) {
    if (_gender == value) return;
    _gender = value;
    notifyListeners();
  }

  void incrementHandicap({double step = 0.1}) {
    _handicapIndex = (_handicapIndex + step).clamp(minHandicap, maxHandicap);
    notifyListeners();
  }

  void decrementHandicap({double step = 0.1}) {
    _handicapIndex = (_handicapIndex - step).clamp(minHandicap, maxHandicap);
    notifyListeners();
  }

  void setPracticeSessionsPerWeek(int sessions) {
    if (_practiceSessionsPerWeek == sessions) return;
    _practiceSessionsPerWeek = sessions;
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final golferService = await _service();
      await golferService.updateMyProfile(
        name: nameController.text.trim(),
        age: ageRange ?? '',
        gender: _gender?.apiValue ?? 'other',
        handicap: _handicapIndex,
        practiceSessionPerWeek: _practiceSessionsPerWeek == 3
            ? '3+'
            : _practiceSessionsPerWeek.toString(),
      );
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

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

extension GenderApi on Gender {
  String get apiValue {
    switch (this) {
      case Gender.man:
        return 'male';
      case Gender.woman:
        return 'female';
      case Gender.nonBinary:
      case Gender.preferNotToSay:
        return 'other';
    }
  }

  static Gender? fromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'male':
      case 'man':
        return Gender.man;
      case 'female':
      case 'woman':
        return Gender.woman;
      case 'non-binary':
      case 'nonbinary':
      case 'non_binary':
        return Gender.nonBinary;
      case 'other':
        return Gender.preferNotToSay;
      default:
        return null;
    }
  }

  static Gender? fromLabel(String label) {
    switch (label) {
      case 'Man':
        return Gender.man;
      case 'Woman':
        return Gender.woman;
      case 'Non-binary':
        return Gender.nonBinary;
      case 'Prefer not to say':
        return Gender.preferNotToSay;
      default:
        return fromApi(label);
    }
  }
}
