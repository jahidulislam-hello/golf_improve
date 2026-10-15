import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final int? matchPercent;
  final bool isSharedWithCoach;
  final String videoDuration;
  final DateTime? recordedAt;
  final DateTime? createdAt;
  final String sessionId;
  final String localId;
  final bool isLocal;

  const SwingVideo({
    required this.id,
    required this.club,
    required this.angle,
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.matchPercent,
    this.isSharedWithCoach = false,
    this.videoDuration = '0:08',
    this.recordedAt,
    this.createdAt,
    this.sessionId = '',
    this.localId = '',
    this.isLocal = false,
  });

  /// Back-compat alias used by older mock widgets.
  String get thumbnailAsset => thumbnailUrl;

  DateTime? get recordedStamp => recordedAt ?? createdAt;

  String get angleLabel => displayAngle(angle);

  String get recordedDateLabel {
    final stamp = recordedStamp;
    if (stamp == null) return '';
    return DateFormat('d MMM yyyy').format(stamp.toLocal());
  }

  String get recordedTimeLabel {
    final stamp = recordedStamp;
    if (stamp == null) return '';
    return DateFormat('h:mm a').format(stamp.toLocal());
  }

  static String displayAngle(String raw) {
    switch (angleFamily(raw)) {
      case 'face':
        return 'Face-On';
      case 'dtl':
        return 'Down-the-Line';
      case 'side':
        return 'Face-On';
      default:
        return raw.trim().isEmpty ? 'Face-On' : raw.trim();
    }
  }

  static String clubFamily(String raw) {
    final n = raw.toLowerCase();
    if (n.contains('wedge')) return 'wedges';
    if (n.contains('iron')) return 'irons';
    if (n.contains('putt')) return 'putter';
    if (n.contains('driver')) return 'driver';
    return n.trim();
  }

  static String angleFamily(String raw) {
    final n = raw.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (n.contains('down') || n == 'dtl' || n.contains('downtheline')) {
      return 'dtl';
    }
    if (n.contains('face')) return 'face';
    if (n.contains('side')) return 'side';
    return n;
  }

  bool sameCompareGroup(SwingVideo other) {
    return clubFamily(club) == clubFamily(other.club) &&
        angleFamily(angle) == angleFamily(other.angle) &&
        angleFamily(angle) != 'side' &&
        clubFamily(club).isNotEmpty;
  }

  factory SwingVideo.fromJson(Map<String, dynamic> json) {
    final localPath = (json['videoPath'] ?? '').toString();
    final remoteVideo = (json['videoUrl'] ?? '').toString();
    final isLocal = json['isLocal'] == true ||
        (remoteVideo.isEmpty && localPath.isNotEmpty);
    return SwingVideo(
      id: (json['_id'] ?? json['id'] ?? json['local_id'] ?? '').toString(),
      club: (json['clubType'] ?? json['club'] ?? 'Driver').toString(),
      angle: (json['cameraAngle'] ?? json['angle'] ?? 'Face On').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      videoUrl: remoteVideo.isNotEmpty ? remoteVideo : localPath,
      isSharedWithCoach: json['isSharedWithCoach'] == true,
      recordedAt: DateTime.tryParse(
        (json['recorded_at'] ?? json['recordedAt'] ?? '').toString(),
      ),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      sessionId: (json['client_session_id'] ?? json['sessionId'] ?? '')
          .toString(),
      localId: (json['local_id'] ?? json['localId'] ?? '').toString(),
      isLocal: isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clubType': club,
      'cameraAngle': angle,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': isLocal ? '' : videoUrl,
      'videoPath': isLocal ? videoUrl : '',
      'isSharedWithCoach': isSharedWithCoach,
      'recorded_at': recordedAt?.toUtc().toIso8601String(),
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'client_session_id': sessionId,
      'local_id': localId,
      'isLocal': isLocal,
    };
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
