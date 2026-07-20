import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'models/swing_insight.dart';

/// Controls everything on the Swing Analysis screen:
///  - video playback position / play-pause state
///  - the freehand "draw a line on the video" annotation
///  - the list of AI Golf Coach insight cards
///
/// This is a plain [ChangeNotifier] so it works with the built-in
/// [AnimatedBuilder] / [ListenableBuilder] widgets with no extra
/// package dependency. If your app already uses `provider` or `riverpod`,
/// wrap this the same way you wrap your other controllers.
class SwingAnalysisController extends ChangeNotifier {
  SwingAnalysisController({
    required this.videoThumbnail,
    this.totalDuration = const Duration(seconds: 8),
    Duration? startPosition,
  }) : _currentPosition = startPosition ?? const Duration(seconds: 2) {
    _loadMockInsights();
  }

  /// Thumbnail / poster frame shown behind the video controls.
  /// Swap the `Image` usage in the screen for a real `video_player`
  /// controller when you wire up actual playback.
  final ImageProvider videoThumbnail;

  final Duration totalDuration;

  // ---- Playback state ----------------------------------------------

  bool _isPlaying = false;
  Duration _currentPosition;

  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0;
    return (_currentPosition.inMilliseconds / totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String get positionLabel => _formatDuration(_currentPosition);
  String get totalDurationLabel => _formatDuration(totalDuration);

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void seekTo(Duration position) {
    if (position < Duration.zero) {
      _currentPosition = Duration.zero;
    } else if (position > totalDuration) {
      _currentPosition = totalDuration;
    } else {
      _currentPosition = position;
    }
    notifyListeners();
  }

  /// Seek using a 0.0-1.0 fraction of the scrub bar's width.
  void seekToFraction(double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    seekTo(
      Duration(
        milliseconds: (totalDuration.inMilliseconds * clamped).round(),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ---- Draw-on-video annotation --------------------------------------

  Offset? _drawStart;
  Offset? _drawEnd;

  Offset? get drawStart => _drawStart;
  Offset? get drawEnd => _drawEnd;
  bool get hasDrawing => _drawStart != null && _drawEnd != null;

  /// Call from `onPanStart` on the video overlay.
  void startDrawing(Offset point) {
    _drawStart = point;
    _drawEnd = point;
    notifyListeners();
  }

  /// Call from `onPanUpdate` on the video overlay.
  void updateDrawing(Offset point) {
    if (_drawStart == null) return;
    _drawEnd = point;
    notifyListeners();
  }

  /// Call from `onPanEnd` on the video overlay.
  void endDrawing() {
    notifyListeners();
  }

  void clearDrawing() {
    _drawStart = null;
    _drawEnd = null;
    notifyListeners();
  }

  // ---- AI Golf Coach insights -----------------------------------------

  List<SwingInsight> _insights = const [];
  bool _isAnalysing = false;

  List<SwingInsight> get insights => List.unmodifiable(_insights);
  bool get isAnalysing => _isAnalysing;

  /// Simulates asking the AI coach to (re)analyse the drawn angle /
  /// current frame. Replace the body with a real API call and map the
  /// response into [SwingInsight] objects.
  Future<void> requestAiAnalysis() async {
    _isAnalysing = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    _loadMockInsights();
    _isAnalysing = false;
    notifyListeners();
  }

  void _loadMockInsights() {
    _insights = const [
      SwingInsight(
        icon: Icons.remove_red_eye_outlined,
        iconBackground: AppColors.insightNegativeIconBg,
        iconColor: AppColors.insightNegativeIcon,
        title: 'Head movement',
        description:
            'Your head drifts forward during the backswing, shifting your '
            'centre of gravity before the downswing starts. Try to keep it '
            'centred over the ball throughout.',
        status: InsightStatus.issue,
      ),
      SwingInsight(
        icon: Icons.monitor_heart_outlined,
        iconBackground: AppColors.insightNegativeIconBg,
        iconColor: AppColors.insightNegativeIcon,
        title: 'Lead leg at impact',
        description:
            'Your lead leg is still bent at impact. Drive your left heel '
            'into the ground earlier to straighten and firm up this '
            'position.',
        status: InsightStatus.issue,
      ),
      SwingInsight(
        icon: Icons.check,
        iconBackground: AppColors.insightPositiveIconBg,
        iconColor: AppColors.insightPositiveIcon,
        title: 'Takeaway path',
        description:
            'Takeaway is tracking on a neutral path in the first 18 inches '
            '— no issues detected.',
        status: InsightStatus.positive,
      ),
    ];
  }
}
