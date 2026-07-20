import 'package:flutter/material.dart';

/// Controller for Screen 5 — Review Swing (dark, annotated preview).
class ReviewSwingController extends ChangeNotifier {
  bool isPlaying = false;
  Duration position = const Duration(seconds: 2);
  final Duration total = const Duration(seconds: 8);
  bool showDrawing = true;
  bool isExpanded = false;

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void toggleDrawing() {
    showDrawing = !showDrawing;
    notifyListeners();
  }

  void seek(Duration newPosition) {
    position = newPosition;
    notifyListeners();
  }
}
