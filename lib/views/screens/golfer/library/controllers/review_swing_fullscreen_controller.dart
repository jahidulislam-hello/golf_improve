import 'package:flutter/material.dart';

/// Controller for Screen 6 — Review Swing fullscreen scrub/edit view.
class ReviewSwingFullscreenController extends ChangeNotifier {
  bool isPlaying = false;
  double scrubValue = 0.0;
  double playbackSpeed = 1.0;
  bool isEditing = false;
  bool isSaved = false;

  static const List<double> speedSteps = [0.25, 0.5, 1.0, 1.5, 2.0];

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setScrub(double value, {bool notify = true}) {
    final next = value.clamp(0.0, 1.0);
    if ((scrubValue - next).abs() < 0.0001) return;
    scrubValue = next;
    if (notify) notifyListeners();
  }

  void cycleSpeed() {
    final i = speedSteps.indexOf(playbackSpeed);
    playbackSpeed = speedSteps[(i + 1) % speedSteps.length];
    notifyListeners();
  }

  void resetSpeed() {
    playbackSpeed = 1.0;
    notifyListeners();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  void save() {
    isSaved = true;
    notifyListeners();
  }
}
