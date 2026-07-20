import 'package:flutter/material.dart';

/// The three visual "flavors" of activity row on the dashboard —
/// each maps to a tinted icon circle (waveform / comment / star).
enum ActivityKind { upload, review, milestone }

class DashboardActivity {
  const DashboardActivity({
    required this.id,
    required this.message,
    required this.timeAgo,
    required this.kind,
  });

  final String id;
  final String message;
  final String timeAgo;
  final ActivityKind kind;

  IconData get icon {
    switch (kind) {
      case ActivityKind.upload:
        return Icons.show_chart_rounded;
      case ActivityKind.review:
        return Icons.chat_bubble_outline_rounded;
      case ActivityKind.milestone:
        return Icons.star_rounded;
    }
  }
}
