import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds all state for the "My Progress" screen.
/// Loads GET `/meta/my-progress` and updates handicap via PATCH
/// `/meta/update-handicap`, then refreshes the same GET so the chart
/// stays in sync with history.
class ProgressController extends ChangeNotifier {
  ProgressController() {
    loadProgress();
  }

  static const _monthLabels = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  bool isLoading = true;
  bool isUpdatingHandicap = false;
  bool hasLoaded = false;
  String? errorMessage;

  // ----- This week / streak -----
  int thisWeekSwings = 0;
  int lastWeekSwings = 0;
  String thisWeekTrend = 'up';
  String thisWeekMessage = '';
  bool isBestWeek = false;
  int streakDays = 0;
  bool isPersonalBestStreak = false;

  // ----- Handicap -----
  double _startingHandicap = 0;
  double _handicapIndex = 0;
  String lastUpdatedLabel = '';

  double get startingHandicap => _startingHandicap;
  double get handicapIndex => _handicapIndex;
  double improvement = 0;

  List<double> handicapTrend = const [];
  List<String> handicapTrendLabels = const [];

  // ----- Weekly swings -----
  List<double> weeklySwingSeries = const [];
  List<String> weeklySwingLabels = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  // ----- Footer stats -----
  int totalSessions = 0;
  int totalSwings = 0;

  Future<void> loadProgress({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final service = await _service();
      final response = await service.getMyProgress();
      final data = _asMap(response['data']);
      if (data != null) {
        _applyProgress(data);
      }
      hasLoaded = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      if (!showLoader) rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Called when the user taps "Update" inside the Handicap Index modal.
  /// PATCHes the new value, then re-fetches progress so the history chart
  /// includes the new point.
  Future<bool> updateHandicapIndex(double newValue) async {
    isUpdatingHandicap = true;
    errorMessage = null;
    notifyListeners();

    try {
      final rounded = double.parse(newValue.toStringAsFixed(1));
      final handicap = rounded == rounded.roundToDouble()
          ? rounded.round()
          : rounded;

      final service = await _service();
      final patchResponse = await service.updateHandicap(handicap);

      try {
        await loadProgress(showLoader: false);
      } catch (_) {
        _applyPatchFallback(patchResponse);
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isUpdatingHandicap = false;
      notifyListeners();
    }
  }

  void _applyProgress(Map<String, dynamic> data) {
    final thisWeek = _asMap(data['thisWeek']);
    if (thisWeek != null) {
      thisWeekSwings = _asInt(thisWeek['swings']);
      lastWeekSwings = _asInt(thisWeek['lastWeekSwings']);
      thisWeekTrend = (thisWeek['trend'] ?? 'up').toString();
      thisWeekMessage = (thisWeek['message'] ?? '').toString();
      isBestWeek = thisWeek['isBestWeek'] == true;
    }

    final streak = _asMap(data['practiceStreak']);
    if (streak != null) {
      streakDays = _asInt(streak['days']);
      isPersonalBestStreak = streak['isPersonalBest'] == true;
    }

    final handicap = _asMap(data['handicap']);
    if (handicap != null) {
      _handicapIndex = _asDouble(handicap['current']);
      _startingHandicap = _asDouble(handicap['starting']);
      improvement = handicap['improvement'] is num
          ? (handicap['improvement'] as num).toDouble()
          : _handicapIndex - _startingHandicap;
      lastUpdatedLabel = _friendlyDate(_readString(handicap, 'lastUpdatedAt'));
      _applyHandicapHistory(handicap['history']);
    }

    final weekly = data['weeklySwingsChart'];
    if (weekly is List) {
      final points = weekly
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .toList();
      weeklySwingLabels = points
          .map((e) => (e['day'] ?? '').toString())
          .toList();
      weeklySwingSeries = points.map((e) => _asDouble(e['count'])).toList();
    }

    final totals = _asMap(data['totals']);
    if (totals != null) {
      totalSessions = _asInt(totals['totalSessions']);
      totalSwings = _asInt(totals['totalSwings']);
    }
  }

  void _applyHandicapHistory(dynamic rawHistory) {
    final entries = <Map<String, dynamic>>[];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        final map = _asMap(item);
        if (map != null) entries.add(map);
      }
    }

    entries.sort((a, b) {
      final aDate = DateTime.tryParse('${a['createdAt'] ?? ''}') ?? DateTime(0);
      final bDate = DateTime.tryParse('${b['createdAt'] ?? ''}') ?? DateTime(0);
      return aDate.compareTo(bDate);
    });

    var sliced = entries;
    if (sliced.length > 6) {
      sliced = sliced.sublist(sliced.length - 6);
    }

    if (sliced.isEmpty) {
      handicapTrend = [_startingHandicap, _handicapIndex];
      handicapTrendLabels = const ['START', 'NOW'];
      return;
    }

    handicapTrend = sliced.map((e) => _asDouble(e['handicap'])).toList();
    handicapTrendLabels = sliced.map((e) {
      final parsed = DateTime.tryParse('${e['createdAt'] ?? ''}');
      if (parsed == null) return '';
      return _monthLabels[parsed.toLocal().month - 1];
    }).toList();

    if (handicapTrend.length == 1) {
      handicapTrend = [handicapTrend.first, handicapTrend.first];
      handicapTrendLabels = [
        handicapTrendLabels.first,
        handicapTrendLabels.first,
      ];
    }
  }

  void _applyPatchFallback(Map<String, dynamic> response) {
    final data = _asMap(response['data']);
    if (data == null) return;
    final handicap = _asMap(data['handicap']);
    if (handicap != null) {
      _handicapIndex = _asDouble(handicap['current']);
      _startingHandicap = _asDouble(handicap['starting']);
      improvement = handicap['improvement'] is num
          ? (handicap['improvement'] as num).toDouble()
          : _handicapIndex - _startingHandicap;
      lastUpdatedLabel = _friendlyDate(_readString(handicap, 'lastUpdatedAt'));
    }

    final historyEntry = _asMap(data['historyEntry']);
    if (historyEntry != null) {
      final nextValues = [...handicapTrend, _asDouble(historyEntry['handicap'])];
      final parsed = DateTime.tryParse('${historyEntry['createdAt'] ?? ''}');
      final nextLabels = [
        ...handicapTrendLabels,
        parsed == null ? 'NOW' : _monthLabels[parsed.toLocal().month - 1],
      ];
      if (nextValues.length > 6) {
        handicapTrend = nextValues.sublist(nextValues.length - 6);
        handicapTrendLabels = nextLabels.sublist(nextLabels.length - 6);
      } else {
        handicapTrend = nextValues;
        handicapTrendLabels = nextLabels;
      }
    } else if (handicapTrend.isNotEmpty) {
      handicapTrend = [...handicapTrend.sublist(0, handicapTrend.length - 1), _handicapIndex];
    }
  }

  Future<GolferService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return GolferService(apiService: apiService);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int _asInt(dynamic raw) => _asDouble(raw).round();

  double _asDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse('${raw ?? ''}') ?? 0;
  }

  String _friendlyDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final now = DateTime.now();
    final local = parsed.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${local.day}/${local.month}/${local.year}';
  }
}
