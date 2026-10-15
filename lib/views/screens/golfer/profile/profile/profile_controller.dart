import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/auth_service.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which subscription tier the golfer is on.
enum PlanType { free, pro }

/// Holds all state shown on the Profile / Settings screen.
/// Values come from GET /user/get-my-profile — no dummy defaults.
class GolferProfileController extends ChangeNotifier {
  GolferProfileController() {
    _bootstrap();
  }

  String _name = '';
  String _email = '';
  String? _ageRange;
  String _gender = '';
  int _practiceSessionsPerWeek = 0;
  double? _handicap;
  String? _avatarUrl;
  PlanType? _plan;
  bool _golfStandConnected = false;
  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  String? get ageRange => _ageRange;
  String get gender => _gender;
  int get practiceSessionsPerWeek => _practiceSessionsPerWeek;
  double get handicap => _handicap ?? 0;
  String? get avatarUrl => _avatarUrl;
  PlanType? get plan => _plan;
  bool get isFreePlan => _plan == PlanType.free;
  bool get golfStandConnected => _golfStandConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get handicapLabel =>
      _handicap == null ? '' : 'Handicap ${_handicap!.toStringAsFixed(1)}';

  Future<void> refresh() => _bootstrap();

  Future<void> _bootstrap() async {
    _isLoading = true;
    notifyListeners();

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final apiService = ApiService(sharedPreferences: sharedPreferences);
      final golferService = GolferService(apiService: apiService);
      final response = await golferService.getMyProfile();
      _applyProfile(response['data']);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyProfile(dynamic rawData) {
    if (rawData is! Map) return;
    final data = Map<String, dynamic>.from(rawData);

    _name = (data['name'] ?? '').toString();
    _email = (data['email'] ?? '').toString();
    final profileUrl = data['profileUrl']?.toString();
    _avatarUrl = (profileUrl != null && profileUrl.isNotEmpty) ? profileUrl : null;
    final handicapRaw = data['handicap_index'] ?? data['handicap'];
    _handicap = handicapRaw is num
        ? handicapRaw.toDouble()
        : double.tryParse('${handicapRaw ?? ''}');
    _ageRange = _ageRangeFromApi(data['age_range'] ?? data['age']);
    _gender = _genderLabelFromApi(data['gender']?.toString());
    _practiceSessionsPerWeek = _practiceFromApi(
      data['practice_sessions_per_week'] ?? data['practiceSessionPerWeek'],
    );
    _golfStandConnected = data['usesGolfImproveStand'] == true ||
        data['uses_golfimprove_stand'] == true ||
        '${data['usesGolfImproveStand'] ?? ''}'.toLowerCase() == 'true' ||
        '${data['uses_golfimprove_stand'] ?? ''}'.toLowerCase() == 'true';

    final paywall = data['paywall'];
    final premium = data['hasPremiumAccess'] == true ||
        (paywall is Map &&
            (paywall['hasPremiumAccess'] == true ||
                paywall['bypassActive'] == true));
    if (premium) {
      _plan = PlanType.pro;
    } else {
      final subscription = data['subscription'];
      if (subscription is Map) {
        final status = '${subscription['status'] ?? ''}'.toLowerCase();
        final planType = '${subscription['planType'] ?? ''}'.toLowerCase();
        final endRaw = subscription['endDate'] ?? subscription['periodEnd'];
        final end = DateTime.tryParse('${endRaw ?? ''}');
        final notExpired = end == null || end.isAfter(DateTime.now());
        final active = notExpired &&
            planType != 'free' &&
            (status == 'active' || status == 'trialing' || status == 'trial');
        _plan = active ? PlanType.pro : PlanType.free;
      } else {
        _plan = PlanType.free;
      }
    }
  }

  String _genderLabelFromApi(String? gender) {
    switch ((gender ?? '').toLowerCase()) {
      case 'male':
      case 'man':
        return 'Man';
      case 'female':
      case 'woman':
        return 'Woman';
      case 'non-binary':
      case 'nonbinary':
        return 'Non-binary';
      case 'other':
        return 'Prefer not to say';
      default:
        return '';
    }
  }

  String? _ageRangeFromApi(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    const options = [
      'Under 18',
      '18–24',
      '25–34',
      '35–44',
      '45–54',
      '55–64',
      '65+',
    ];
    final normalized = text.replaceAll('-', '–');
    if (options.contains(text) || options.contains(normalized)) {
      return options.contains(text) ? text : normalized;
    }
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

  Future<void> upgradePlan() async {
    _plan = PlanType.pro;
    notifyListeners();
  }

  void setGolfStandConnected(bool connected) {
    if (_golfStandConnected == connected) return;
    _golfStandConnected = connected;
    notifyListeners();
  }

  void applyPersonalInfo({
    required String name,
    required String email,
    required String? ageRange,
    required String gender,
    required int practiceSessionsPerWeek,
    required double handicap,
    String? avatarUrl,
  }) {
    _name = name;
    _email = email;
    _ageRange = ageRange;
    _gender = gender;
    _practiceSessionsPerWeek = practiceSessionsPerWeek;
    _handicap = handicap;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      _avatarUrl = avatarUrl;
    }
    notifyListeners();
  }

  Future<void> logOut() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    await AuthService(apiService: apiService).logout();
  }
}
