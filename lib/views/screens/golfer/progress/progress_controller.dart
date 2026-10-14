import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:golf_training_app/views/screens/golfer/library/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProgressChartMetric { swings, minutes, sessions }

/// One saved swing used on the six-week comparison card.
class ProgressCompareSwing {
  const ProgressCompareSwing({
    required this.id,
    required this.club,
    required this.angle,
    required this.thumbnailUrl,
    required this.recordedAt,
  });

  final String id;
  final String club;
  final String angle;
  final String thumbnailUrl;
  final DateTime? recordedAt;

  String get angleLabel => SwingVideo.displayAngle(angle);

  String get dateLabel {
    final stamp = recordedAt;
    if (stamp == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = stamp.toLocal();
    return '${local.day} ${months[local.month - 1]}';
  }
}

/// Holds all state for the "My Progress" screen.
/// Loads GET `/meta/my-progress` and updates handicap via PUT
/// `/user/handicap`, then refreshes the same GET so the chart
/// stays in sync with history. The last successful payload is kept
/// on device so the screen still opens offline.
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

  int thisWeekSwings = 0;
  int lastWeekSwings = 0;
  int sessionsThisWeek = 0;
  int sessionsLastWeek = 0;
  bool hasLastWeekSessions = false;
  int weeklyTargetSessions = 0;
  int minutesThisWeek = 0;
  int minutesLastWeek = 0;
  bool hasLastWeekMinutes = false;
  String thisWeekTrend = 'up';
  bool isBestWeek = false;

  double _startingHandicap = 0;
  double _handicapIndex = 0;
  String lastUpdatedLabel = '';
  bool isHandicapImproved = false;

  double get startingHandicap => _startingHandicap;
  double get handicapIndex => _handicapIndex;
  double improvement = 0;

  List<double> handicapTrend = const [];
  List<String> handicapTrendLabels = const [];

  ProgressChartMetric chartMetric = ProgressChartMetric.swings;
  List<double> weeklySwingSeries = const [];
  List<double> weeklyMinuteSeries = const [];
  List<double> weeklySessionSeries = const [];
  List<String> weeklySwingLabels = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  int totalSessions = 0;
  int totalSwings = 0;
  int totalPracticeMinutes = 0;

  ProgressCompareSwing? compareRecent;
  ProgressCompareSwing? compareEarlier;

  List<double> get activeWeeklySeries {
    switch (chartMetric) {
      case ProgressChartMetric.swings:
        return weeklySwingSeries;
      case ProgressChartMetric.minutes:
        return weeklyMinuteSeries;
      case ProgressChartMetric.sessions:
        return weeklySessionSeries;
    }
  }

  String get weeklyChartTitle {
    switch (chartMetric) {
      case ProgressChartMetric.swings:
        return 'Weekly Swings';
      case ProgressChartMetric.minutes:
        return 'Weekly Minutes';
      case ProgressChartMetric.sessions:
        return 'Weekly Sessions';
    }
  }

  String get consistencyLabel {
    final target = weeklyTargetSessions;
    if (target <= 0) {
      final noun = sessionsThisWeek == 1 ? 'Session' : 'Sessions';
      return '$sessionsThisWeek $noun Completed';
    }
    return '$sessionsThisWeek of $target Sessions Completed';
  }

  /// Plain-language summary of this week against last week.
  String get weekComparison {
    final sentences = <String>[
      _countChange(
        delta: thisWeekSwings - lastWeekSwings,
        noun: 'swing',
        verb: 'recorded',
      ),
    ];
    if (hasLastWeekMinutes) {
      sentences.add(
        _countChange(
          delta: minutesThisWeek - minutesLastWeek,
          noun: 'minute',
          verb: 'practised',
        ),
      );
    }
    if (hasLastWeekSessions) {
      sentences.add(
        _countChange(
          delta: sessionsThisWeek - sessionsLastWeek,
          noun: 'session',
          verb: 'completed',
        ),
      );
    }
    if (isBestWeek) {
      sentences.add('This is your best week so far.');
    }
    return sentences.join(' ');
  }

  String get handicapChangeLabel {
    final amount = improvement.abs().toStringAsFixed(1);
    if (improvement < 0) return 'Dropped $amount';
    if (improvement > 0) return 'Up $amount';
    return 'No change';
  }

  bool get handicapChangeIsPositive =>
      improvement < 0 || (isHandicapImproved && improvement <= 0);

  void selectChart(ProgressChartMetric metric) {
    if (chartMetric == metric) return;
    chartMetric = metric;
    notifyListeners();
  }

  Future<void> loadProgress({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    try {
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getMyProgress();
      final data = _asMap(response['data']);
      if (data != null) {
        _applyProgress(data);
        await prefs.setString(ApiConstants.keyProgressCache, jsonEncode(data));
      }
      hasLoaded = true;
      errorMessage = null;
    } catch (e) {
      final restored = _restoreProgress(prefs);
      if (restored) {
        hasLoaded = true;
        errorMessage = null;
      } else {
        errorMessage = e.toString();
        if (!showLoader) rethrow;
      }
    } finally {
      compareRecent = null;
      compareEarlier = null;
      final pair = await _loadComparePair(prefs);
      if (pair != null) {
        compareRecent = pair.$1;
        compareEarlier = pair.$2;
      }
      isLoading = false;
      notifyListeners();
    }
  }

  /// Called when the user taps "Update" inside the Handicap Index modal.
  Future<bool> updateHandicapIndex(double newValue) async {
    isUpdatingHandicap = true;
    errorMessage = null;
    notifyListeners();

    try {
      final rounded = double.parse(newValue.toStringAsFixed(1));
      final bounded = rounded.clamp(-9.9, 54.0).toDouble();
      final handicap = bounded == bounded.roundToDouble()
          ? bounded.round()
          : bounded;

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
      isBestWeek = thisWeek['isBestWeek'] == true;
      sessionsThisWeek = _asInt(
        thisWeek['sessionsCompleted'] ?? thisWeek['sessions'],
      );
      if (thisWeek.containsKey('lastWeekSessions') ||
          thisWeek.containsKey('sessionsLastWeek')) {
        hasLastWeekSessions = true;
        sessionsLastWeek = _asInt(
          thisWeek['lastWeekSessions'] ?? thisWeek['sessionsLastWeek'],
        );
      }
      final weekMinutes = _asInt(thisWeek['minutesPracticed']);
      if (weekMinutes > 0) minutesThisWeek = weekMinutes;
      final weekTarget = _asInt(thisWeek['targetSessions']);
      if (weekTarget > 0) weeklyTargetSessions = weekTarget;
    }

    final consistency = _asMap(data['consistency']);
    if (consistency != null) {
      sessionsThisWeek = _asInt(consistency['completedSessions']);
      weeklyTargetSessions = _asInt(consistency['weeklyTargetSessions']);
    }

    final minutes = _asMap(data['minutesPracticed']);
    if (minutes != null) {
      minutesThisWeek = _asInt(minutes['thisWeek']);
      if (minutes.containsKey('lastWeek')) {
        hasLastWeekMinutes = true;
        minutesLastWeek = _asInt(minutes['lastWeek']);
      }
    }

    final handicap = _asMap(data['handicap']);
    if (handicap != null) {
      _handicapIndex = _asDouble(handicap['current']);
      _startingHandicap = _asDouble(handicap['starting']);
      improvement = handicap['improvement'] is num
          ? (handicap['improvement'] as num).toDouble()
          : _handicapIndex - _startingHandicap;
      isHandicapImproved = handicap['isImproved'] == true || improvement < 0;
      lastUpdatedLabel = _friendlyDate(_readString(handicap, 'lastUpdatedAt'));
      _applyHandicapHistory(handicap['history']);
    }

    _applyWeeklyCharts(data);

    final totals = _asMap(data['totals']);
    if (totals != null) {
      totalSessions = _asInt(totals['totalSessions']);
      totalSwings = _asInt(totals['totalSwings']);
      totalPracticeMinutes = _asInt(totals['totalPracticeMinutes']);
    }
  }

  void _applyWeeklyCharts(Map<String, dynamic> data) {
    final activity = data['weeklyActivityChart'];
    if (activity is List && activity.isNotEmpty) {
      final points = activity
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .toList();
      weeklySwingLabels =
          points.map((e) => (e['day'] ?? '').toString()).toList();
      weeklySwingSeries = points
          .map((e) => _asDouble(e['swings'] ?? e['count']))
          .toList();
      weeklyMinuteSeries =
          points.map((e) => _asDouble(e['minutes'])).toList();
      weeklySessionSeries = points.map((e) {
        if (e.containsKey('sessions')) return _asDouble(e['sessions']);
        return _asDouble(e['swings'] ?? e['count']) > 0 ? 1.0 : 0.0;
      }).toList();
      return;
    }

    final weekly = data['weeklySwingsChart'];
    if (weekly is List) {
      final points = weekly
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .toList();
      weeklySwingLabels =
          points.map((e) => (e['day'] ?? '').toString()).toList();
      weeklySwingSeries = points.map((e) => _asDouble(e['count'])).toList();
      weeklyMinuteSeries = List<double>.filled(points.length, 0);
      weeklySessionSeries = weeklySwingSeries
          .map((count) => count > 0 ? 1.0 : 0.0)
          .toList();
    }
  }

  bool _restoreProgress(SharedPreferences prefs) {
    final raw = prefs.getString(ApiConstants.keyProgressCache);
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw);
      final data = _asMap(decoded);
      if (data == null) return false;
      _applyProgress(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<(ProgressCompareSwing, ProgressCompareSwing)?> _loadComparePair(
    SharedPreferences prefs,
  ) async {
    final swings = <SwingVideo>[];
    try {
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getMySwings(limit: 100, sort: '-createdAt');
      swings.addAll(_swingsFrom(response['data']));
    } catch (_) {}

    if (swings.length < 2) {
      swings.addAll(_swingsFromCache(prefs));
    }
    return _pickSixWeekPair(swings);
  }

  List<SwingVideo> _swingsFrom(dynamic data) {
    final list = data is List
        ? data
        : (data is Map
            ? (data['results'] ??
                data['swings'] ??
                data['items'] ??
                data['docs'] ??
                data['data'])
            : null);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => SwingVideo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<SwingVideo> _swingsFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(ApiConstants.keyLibraryCache);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['swings'] is List) {
        return _swingsFrom(decoded['swings']);
      }
      return _swingsFrom(decoded);
    } catch (_) {
      return const [];
    }
  }

  (ProgressCompareSwing, ProgressCompareSwing)? _pickSixWeekPair(
    List<SwingVideo> swings,
  ) {
    final groups = <String, List<SwingVideo>>{};
    for (final swing in swings) {
      if (swing.isLocal || swing.id.isEmpty || swing.recordedStamp == null) {
        continue;
      }
      if (SwingVideo.angleFamily(swing.angle) == 'side') continue;
      final key =
          '${SwingVideo.clubFamily(swing.club)}|${SwingVideo.angleFamily(swing.angle)}';
      groups.putIfAbsent(key, () => []).add(swing);
    }

    (ProgressCompareSwing, ProgressCompareSwing)? best;
    var bestGap = 1 << 30;
    for (final list in groups.values) {
      if (list.length < 2) continue;
      list.sort(
        (a, b) => b.recordedStamp!.compareTo(a.recordedStamp!),
      );
      final recent = list.first;
      SwingVideo? earlier;
      var closest = 1 << 30;
      for (final other in list.skip(1)) {
        final days = recent.recordedStamp!.difference(other.recordedStamp!).inDays;
        if (days < 7) continue;
        final gap = (days - 42).abs();
        if (gap < closest) {
          closest = gap;
          earlier = other;
        }
      }
      if (earlier != null && closest < bestGap) {
        bestGap = closest;
        best = (_snapshot(recent), _snapshot(earlier));
      }
    }
    return best;
  }

  ProgressCompareSwing _snapshot(SwingVideo swing) {
    return ProgressCompareSwing(
      id: swing.id,
      club: swing.club,
      angle: swing.angle,
      thumbnailUrl: swing.thumbnailUrl,
      recordedAt: swing.recordedStamp,
    );
  }

  String _countChange({
    required int delta,
    required String noun,
    required String verb,
  }) {
    final plural = delta.abs() == 1 ? noun : '${noun}s';
    if (delta > 0) {
      return 'You $verb $delta more $plural than last week.';
    }
    if (delta < 0) {
      return 'You $verb ${-delta} fewer $plural than last week.';
    }
    return 'You $verb the same number of $plural as last week.';
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
      isHandicapImproved = handicap['isImproved'] == true ||
          handicap['isImprovement'] == true ||
          improvement < 0;
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
      handicapTrend = [
        ...handicapTrend.sublist(0, handicapTrend.length - 1),
        _handicapIndex,
      ];
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
