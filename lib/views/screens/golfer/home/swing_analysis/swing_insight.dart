import 'package:flutter/material.dart';

/// Whether an insight is flagged as something to fix, something that's
/// already good, or purely informational.
enum InsightStatus { issue, positive, neutral }

/// A single row on the Swing Analysis screen, e.g. "Head movement".
class SwingInsight {
  const SwingInsight({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.status,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;
  final InsightStatus status;
}
