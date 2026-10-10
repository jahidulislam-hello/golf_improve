import 'package:flutter/material.dart';

/// Label/value pair from GET `/meta/filter-categories`.
class LibraryFilterOption {
  final String label;
  final String value;

  const LibraryFilterOption({required this.label, required this.value});

  factory LibraryFilterOption.fromJson(Map<String, dynamic> json) {
    return LibraryFilterOption(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}

/// A single swing recording shown in the Swing Library grid.
class SwingVideo {
  final String id;
  final String club;
  final String angle;
  final String thumbnailUrl;
  final String videoUrl;
  final int? matchPercent; // null = no badge shown
  final bool isSharedWithCoach;
  final String videoDuration;

  const SwingVideo({
    required this.id,
    required this.club,
    required this.angle,
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.matchPercent,
    this.isSharedWithCoach = false,
    this.videoDuration = '0:08',
  });

  /// Back-compat alias used by older mock widgets.
  String get thumbnailAsset => thumbnailUrl;

  factory SwingVideo.fromJson(Map<String, dynamic> json) {
    final score = json['overallScore'];
    final int? match = score is num
        ? score.round()
        : int.tryParse('${score ?? ''}');

    return SwingVideo(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      club: (json['clubType'] ?? 'All Clubs').toString(),
      angle: (json['cameraAngle'] ?? 'All Angles').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      videoUrl: (json['videoUrl'] ?? '').toString(),
      matchPercent: (match != null && match > 0) ? match : null,
      isSharedWithCoach: json['isSharedWithCoach'] == true,
    );
  }
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

/// Prior AI Q&A pair from `aiConversation` on swing-library find.
class AiConversationEntry {
  final String question;
  final String answer;
  final DateTime? createdAt;

  const AiConversationEntry({
    required this.question,
    required this.answer,
    this.createdAt,
  });

  factory AiConversationEntry.fromJson(Map<String, dynamic> json) {
    return AiConversationEntry(
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
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
