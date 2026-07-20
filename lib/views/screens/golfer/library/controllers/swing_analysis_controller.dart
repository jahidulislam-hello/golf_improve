import 'package:flutter/material.dart';
import '../models/models.dart';

/// Controller for Screen 2 — Swing Analysis (AI Golf Coach summary).
class SwingAnalysisController extends ChangeNotifier {
  bool isPlaying = false;
  Duration position = const Duration(seconds: 2);
  final Duration total = const Duration(seconds: 8);

  final List<SwingInsight> insights = [
    SwingInsight(
      icon: Icons.remove_red_eye_outlined,
      iconColor: const Color(0xFFE0575B),
      iconBg: const Color(0xFFFBE7E7),
      title: 'Head movement',
      description:
          'Your head drifts forward during the backswing, shifting your centre of gravity before the downswing starts. Try to keep it centred over the ball throughout.',
    ),
    SwingInsight(
      icon: Icons.favorite_border,
      iconColor: const Color(0xFFE0575B),
      iconBg: const Color(0xFFFBE7E7),
      title: 'Lead leg at impact',
      description:
          'Your lead leg is still bent at impact. Drive your left heel into the ground earlier to straighten and firm up this position.',
    ),
    SwingInsight(
      icon: Icons.check,
      iconColor: const Color(0xFF2E9E5B),
      iconBg: const Color(0xFFE1F5E8),
      title: 'Takeaway path',
      description:
          'Takeaway is tracking on a neutral path in the first 18 inches — no issues detected here.',
    ),
  ];

  final String proInitials = 'JK';
  final String proQuote =
      "Keep your left arm straighter through the downswing — you're losing extension too early.";
  final String proImprovement =
      'Improved — left arm holding straighter through impact this session.';

  final List<String> thingsToTry = [
    'Keep your eyes fixed on a dimple at the back of the ball throughout your entire backswing.',
    'Drill: place a headcover under your chin and hold it there as you coil to the top.',
    'Record 5 slow-motion reps and watch your right ear position from address to the top.',
  ];

  final String coachName = 'James Keller';

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void seek(Duration newPosition) {
    position = newPosition;
    notifyListeners();
  }
}
