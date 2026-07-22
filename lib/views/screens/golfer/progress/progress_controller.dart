import 'package:flutter/foundation.dart';

/// Holds all state for the "My Progress" screen and notifies listeners
/// whenever something changes (new swings logged, streak updates, or the
/// handicap index being edited from the Update HCP modal).
class ProgressController extends ChangeNotifier {
  ProgressController({
    this.thisWeekSwings = 23,
    this.lastWeekSwings = 9,
    this.streakDays = 12,
    this.isPersonalBestStreak = true,
    double startingHandicap = 12.4,
    double handicapIndex = 12.4,
    List<double>? handicapTrend,
    List<double>? weeklySwingSeries,
    this.totalSessions = 47,
    this.totalSwings = 847,
  })  : _startingHandicap = startingHandicap,
        _handicapIndex = handicapIndex,
        handicapTrend = handicapTrend ??
            const [12.4, 11.6, 10.8, 9.9, 9.0, 8.2], // Mar -> Aug
        weeklySwingSeries = weeklySwingSeries ??
            const [12, 8, 17, 13, 21, 16];

  // ----- This week / streak -----
  int thisWeekSwings;
  int lastWeekSwings;
  int streakDays;
  bool isPersonalBestStreak;

  // ----- Handicap -----
  double _startingHandicap;
  double _handicapIndex;

  /// Value shown in the "Starting" box (first point of the trend chart).
  double get startingHandicap => _startingHandicap;

  /// The current, editable handicap index (changed via the Update HCP modal).
  double get handicapIndex => _handicapIndex;

  /// Improvement = current - starting. Negative means the handicap dropped
  /// (improved), which is why it renders in red/orange on the card.
  double get improvement => _handicapIndex - _startingHandicap;

  /// Mar -> Aug trend line shown on the Handicap Progress card.
  final List<double> handicapTrend;

  // ----- Weekly swings -----
  /// Tue -> Sun swing counts shown on the Weekly Swings card.
  final List<double> weeklySwingSeries;
  static const weeklySwingLabels = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // ----- Footer stats -----
  int totalSessions;
  int totalSwings;

  /// Percentage change used for the "Up from X last week" copy.
  bool get isBestWeek => thisWeekSwings > lastWeekSwings;

  /// Called when the user taps "Update" inside the Handicap Index modal.
  void updateHandicapIndex(double newValue) {
    _handicapIndex = double.parse(newValue.toStringAsFixed(1));
    // Reflect the edit as the newest point on the trend line so the chart
    // stays in sync with what the user just set.
    if (handicapTrend.isNotEmpty) {
      handicapTrend[handicapTrend.length - 1] = _handicapIndex;
    }
    notifyListeners();
  }

  /// Log a completed practice session — bumps weekly/total counters and the
  /// streak. Hook this up to your real swing-tracking flow.
  void logSession({required int swingsInSession}) {
    thisWeekSwings += swingsInSession;
    totalSwings += swingsInSession;
    totalSessions += 1;
    streakDays += 1;
    notifyListeners();
  }
}
