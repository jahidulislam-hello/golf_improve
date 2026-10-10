import 'package:flutter/material.dart';

/// ===== Hero carousel (top banner that auto-swipes) =====
class HeroBannerModel {
  final String imageAsset;
  final String eyebrow; // e.g. "READY TO IMPROVE"
  final String title; // e.g. "Train smarter.\nPlay better."
  final String ctaLabel; // e.g. "Start Recording"

  const HeroBannerModel({
    required this.imageAsset,
    required this.eyebrow,
    required this.title,
    required this.ctaLabel,
  });
}

/// ===== Top stat chips (Handicap / Swings / This Week) =====
class StatModel {
  final String value;
  final String label;

  const StatModel({required this.value, required this.label});
}

/// ===== Active session card =====
class ActiveSessionModel {
  final String thumbnailUrl;
  final String title; // "Driver · Face On"
  final String statusLabel; // "Coach Reviewing"
  final Map<String, dynamic>? payload;

  const ActiveSessionModel({
    required this.thumbnailUrl,
    required this.title,
    required this.statusLabel,
    this.payload,
  });
}

/// ===== Coach feedback banner =====
class CoachFeedbackModel {
  final String title; // "New Coach Feedback"
  final String subtitle; // "James Keller reviewed your 7 Iron session"
  final bool isUnread;

  const CoachFeedbackModel({
    required this.title,
    required this.subtitle,
    this.isUnread = true,
  });
}

/// ===== Quick action grid =====
enum QuickActionType { aiAnalysis, logbook, shareWithCoach, library }

class QuickActionModel {
  final QuickActionType type;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final Map<String, dynamic>? payload;

  const QuickActionModel({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    this.payload,
  });
}

/// ===== Recent activity list item =====
class RecentActivityModel {
  final String thumbnailUrl;
  final String title; // "Driver · Face On"
  final String subtitle; // "Today, 9:14 AM"
  final int scorePercent; // 84
  final Map<String, dynamic>? payload;

  const RecentActivityModel({
    required this.thumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.scorePercent,
    this.payload,
  });
}