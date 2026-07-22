import 'package:flutter/material.dart';

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

/// Holds all editable state for the "Personal Info" screen:
/// name, email, age range, gender, handicap index and weekly practice
/// sessions. Exposes [TextEditingController]s for the text fields so the
/// screen can stay a thin, mostly-stateless layout.
class GolferPersonalInfoController extends ChangeNotifier {
  GolferPersonalInfoController({
    String name = 'Alex Thompson',
    String email = '',
    this.ageRange,
    Gender gender = Gender.man,
    double handicapIndex = 12.4,
    int practiceSessionsPerWeek = 2,
  })  : nameController = TextEditingController(text: name),
        emailController = TextEditingController(text: email),
        _gender = gender,
        _handicapIndex = handicapIndex,
        _practiceSessionsPerWeek = practiceSessionsPerWeek;

  static const double minHandicap = -9.9;
  static const double maxHandicap = 54.0;
  static const List<int> practiceOptions = [1, 2]; // "3+" handled separately

  final TextEditingController nameController;
  final TextEditingController emailController;

  String? ageRange;
  Gender _gender;
  double _handicapIndex;
  int _practiceSessionsPerWeek;

  Gender get gender => _gender;
  double get handicapIndex => _handicapIndex;
  int get practiceSessionsPerWeek => _practiceSessionsPerWeek;

  /// 0.0–1.0 fill amount for the handicap progress bar
  /// ("PRO LEVEL" ... "BEGINNER").
  double get handicapProgress =>
      (_handicapIndex - minHandicap) / (maxHandicap - minHandicap);

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

  /// Pass 1, 2, or 3 to mean "3+".
  void setPracticeSessionsPerWeek(int sessions) {
    if (_practiceSessionsPerWeek == sessions) return;
    _practiceSessionsPerWeek = sessions;
    notifyListeners();
  }

  bool get isDirty =>
      nameController.text.isNotEmpty || emailController.text.isNotEmpty;

  /// Persists the edits. Replace with a real repository/API call and
  /// surface success/failure to the caller as needed.
  Future<void> saveChanges() async {
    // TODO: send nameController.text, emailController.text, ageRange,
    // gender, handicapIndex and practiceSessionsPerWeek to your backend.
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
