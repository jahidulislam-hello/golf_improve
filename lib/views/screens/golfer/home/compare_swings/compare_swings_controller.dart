import 'package:flutter/material.dart';

/// Playback speed options shown as pills on each clip row.
enum PlaybackSpeed {
  quarter(0.25),
  half(0.5),
  normal(1.0);

  const PlaybackSpeed(this.multiplier);
  final double multiplier;

  String get label => multiplier == 1.0
      ? '1×'
      : '${multiplier.toString().replaceAll(RegExp(r'\.0$'), '')}×';
}

/// State for a single swing clip (the "A" or "B" side).
class SwingClip {
  SwingClip({
    required this.badgeLetter,
    required this.badgeColor,
    required this.label,
    this.thumbnailImage,
    PlaybackSpeed speed = PlaybackSpeed.normal,
    double progress = 0,
    bool isPlaying = false,
  })  : _speed = speed,
        _progress = progress,
        _isPlaying = isPlaying;

  /// "A" or "B" — shown inside the small circular badge.
  final String badgeLetter;

  /// Badge / active-speed-pill tint (navy for A, bright blue for B in the
  /// reference design — but pass whatever fits your palette).
  final Color badgeColor;

  /// e.g. "Driver · Face On · Today"
  final String label;

  /// Optional thumbnail; swap for your actual video-thumbnail provider.
  final ImageProvider? thumbnailImage;

  PlaybackSpeed _speed;
  PlaybackSpeed get speed => _speed;

  /// 0.0–1.0 scrub position.
  double _progress;
  double get progress => _progress;

  bool _isPlaying;
  bool get isPlaying => _isPlaying;
}

/// Controller for the "Compare Swings" screen — holds the two clips being
/// compared side by side and the shared "Play Both" action.
class CompareSwingsController extends ChangeNotifier {
  CompareSwingsController({required this.clipA, required this.clipB});

  final SwingClip clipA;
  final SwingClip clipB;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  void setSpeed(SwingClip clip, PlaybackSpeed speed) {
    if (clip._speed == speed) return;
    clip._speed = speed;
    notifyListeners();
  }

  void setProgress(SwingClip clip, double progress) {
    clip._progress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void togglePlay(SwingClip clip) {
    clip._isPlaying = !clip._isPlaying;
    notifyListeners();
  }

  void pauseAll() {
    clipA._isPlaying = false;
    clipB._isPlaying = false;
    notifyListeners();
  }

  /// Starts both clips together (e.g. side-by-side sync playback).
  void playBoth() {
    clipA._isPlaying = true;
    clipB._isPlaying = true;
    notifyListeners();
    // TODO: hook up to your video-player sync logic here.
  }

  /// Pulls fresh clips (e.g. re-checks for a newer "Last Week" reference).
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      // TODO: reload clip references from your data layer.
      await Future<void>.delayed(const Duration(milliseconds: 400));
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
