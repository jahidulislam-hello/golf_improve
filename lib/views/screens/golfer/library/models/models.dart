import 'package:flutter/material.dart';

/// A single swing recording shown in the Swing Library grid.
class SwingVideo {
  final String id;
  final String club; // Driver, Irons, Wedges, Putter
  final String angle; // Face On, Down the Line, Side On
  final String thumbnailAsset;
  final int? matchPercent; // null = no badge shown
  final String videoDuration;

  const SwingVideo({
    required this.id,
    required this.club,
    required this.angle,
    required this.thumbnailAsset,
    this.matchPercent,
    this.videoDuration = '0:08',
  });
}

/// A single AI-generated coaching observation on the Swing Analysis screen.
class SwingInsight {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const SwingInsight({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

/// One message bubble in the AI Golf Coach chat screen.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

/// One toggleable row on the "What to include" list of Share With Coach.
class ShareIncludeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool alwaysIncluded;
  bool isOn;
  final String? badge;

  ShareIncludeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.alwaysIncluded = false,
    this.isOn = true,
    this.badge,
  });
}
