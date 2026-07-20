import 'package:flutter/material.dart';

class PersonalInfoController extends ChangeNotifier {
  PersonalInfoController({
    String name = 'Alex Thompson',
    String email = '',
    String? ageRange,
    String gender = 'Man',
    double handicapIndex = 12.4,
    int sessionsPerWeek = 2,
  })  : nameController = TextEditingController(text: name),
        emailController = TextEditingController(text: email),
        _ageRange = ageRange,
        _gender = gender,
        _handicapIndex = handicapIndex,
        _sessionsPerWeek = sessionsPerWeek;

  // ----- Static option lists -----
  static const double minHandicap = -9.9;
  static const double maxHandicap = 54.0;
  static const double handicapStep = 0.1;

  static const List<String> genderOptions = [
    'Man',
    'Woman',
    'Non-binary',
    'Prefer not to say',
  ];

  static const List<int> sessionOptions = [1, 2, 3]; // 3 renders as "3+"

  static const List<String> ageRanges = [
    'Under 18',
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55–64',
    '65+',
  ];

  // ----- Text fields -----
  final TextEditingController nameController;
  final TextEditingController emailController;

  // ----- Avatar -----
  String? avatarPath;
  void setAvatar(String path) {
    avatarPath = path;
    notifyListeners();
  }

  // ----- Age range -----
  String? _ageRange;
  String? get ageRange => _ageRange;
  void setAgeRange(String value) {
    _ageRange = value;
    notifyListeners();
  }

  // ----- Gender -----
  String _gender;
  String get gender => _gender;
  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  // ----- Handicap index -----
  double _handicapIndex;
  double get handicapIndex => _handicapIndex;
  String get handicapLabel => _handicapIndex.toStringAsFixed(1);

  void incrementHandicap() {
    _handicapIndex =
        (_handicapIndex + handicapStep).clamp(minHandicap, maxHandicap);
    notifyListeners();
  }

  void decrementHandicap() {
    _handicapIndex =
        (_handicapIndex - handicapStep).clamp(minHandicap, maxHandicap);
    notifyListeners();
  }

  // ----- Practice sessions per week -----
  int _sessionsPerWeek;
  int get sessionsPerWeek => _sessionsPerWeek;
  void setSessionsPerWeek(int value) {
    _sessionsPerWeek = value;
    notifyListeners();
  }

  // ----- Save -----
  bool get isValid =>
      nameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty;

  /// Returns the payload to persist / hand back to the caller.
  Map<String, dynamic> save() {
    return {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'ageRange': _ageRange,
      'gender': _gender,
      'handicapIndex': _handicapIndex,
      'sessionsPerWeek': _sessionsPerWeek,
      'avatarPath': avatarPath,
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
