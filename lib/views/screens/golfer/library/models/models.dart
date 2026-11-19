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
  /// Library/analysis document id for `/swing-library/find/:id`.
  final String analysisId;
  /// Underlying swing recording id when this row came from `/swing/my-swings`.
  final String swingId;
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
  final bool hasAnalysis;

  const SwingVideo({
    required this.id,
    this.analysisId = '',
    this.swingId = '',
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
    this.hasAnalysis = true,
  });

  /// Prefer library analysis id when opening Swing Analysis.
  String get openId =>
      analysisId.isNotEmpty ? analysisId : (id.isNotEmpty ? id : swingId);

  /// Seed Swing Analysis so the video/details show even before AI is ready.
  Map<String, dynamic> toAnalysisSeed() {
    final detailId = openId;
    return {
      if (detailId.isNotEmpty) '_id': detailId,
      if (analysisId.isNotEmpty) 'analysisId': analysisId,
      if (swingId.isNotEmpty) 'swingId': swingId,
      'clubType': club,
      'cameraAngle': angle,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'isSharedWithCoach': isSharedWithCoach,
      'isAnalysisReady': hasAnalysis && !isLocal,
      'analysisStatus': hasAnalysis && !isLocal ? 'ready' : 'processing',
      'analysisMessage': hasAnalysis && !isLocal
          ? ''
          : 'Analysis is still preparing. You can watch the video meanwhile.',
      if (recordedAt != null)
        'recordedAt': recordedAt!.toUtc().toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
    };
  }

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
    if (angleFamily(angle) == 'side' || angleFamily(other.angle) == 'side') {
      return false;
    }
    // Prefer same club + angle; allow same club with any face/dtl so a
    // second selection is still possible when the library is small.
    final sameClub = clubFamily(club) == clubFamily(other.club) &&
        clubFamily(club).isNotEmpty;
    if (!sameClub) return false;
    final a = angleFamily(angle);
    final b = angleFamily(other.angle);
    return a == b || a.isEmpty || b.isEmpty;
  }

  factory SwingVideo.fromJson(Map<String, dynamic> json) {
    final nestedSwing = json['swing'];
    final nested = nestedSwing is Map
        ? Map<String, dynamic>.from(nestedSwing)
        : const <String, dynamic>{};
    final nestedDetails = json['swingDetails'];
    final details = nestedDetails is Map
        ? Map<String, dynamic>.from(nestedDetails)
        : const <String, dynamic>{};

    String pickUrl(List<dynamic> candidates) {
      for (final raw in candidates) {
        final value = '${raw ?? ''}'.trim();
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    final localPath = pickUrl([
      json['videoPath'],
      nested['videoPath'],
      details['videoPath'],
    ]);
    final remoteVideo = pickUrl([
      json['videoUrl'],
      nested['videoUrl'],
      details['videoUrl'],
    ]);
    final rawThumb = pickUrl([
      json['thumbnailUrl'],
      nested['thumbnailUrl'],
      details['thumbnailUrl'],
      json['thumbnail'],
      nested['thumbnail'],
    ]);
    // Never treat an .mp4 as an image thumb — the grid will render a frame.
    final thumbLooksLikeVideo = rawThumb.toLowerCase().contains('.mp4');
    final thumbnailUrl = thumbLooksLikeVideo ? '' : rawThumb;

    final isLocal = json['isLocal'] == true ||
        (remoteVideo.isEmpty && localPath.isNotEmpty);
    final rootId =
        (json['_id'] ?? json['id'] ?? json['local_id'] ?? '').toString();
    final nestedSwingId =
        (nested['_id'] ?? nested['id'] ?? '').toString();
    // my-swings rows pass hasAnalysis:false; library rows keep the analysis id.
    final forcedNoAnalysis = json['hasAnalysis'] == false;
    final analysisId = forcedNoAnalysis
        ? ''
        : (json['analysisId'] ??
                json['swingLibraryId'] ??
                json['libraryId'] ??
                rootId)
            .toString();
    final swingId = (json['swingId'] ?? json['swing_id'] ?? nestedSwingId)
        .toString();
    final hasAnalysis = !forcedNoAnalysis;
    return SwingVideo(
      id: analysisId.isNotEmpty ? analysisId : rootId,
      analysisId: analysisId,
      swingId: swingId.isNotEmpty ? swingId : (hasAnalysis ? '' : rootId),
      club: (json['clubType'] ??
              json['club'] ??
              nested['clubType'] ??
              'Driver')
          .toString(),
      angle: (json['cameraAngle'] ??
              json['angle'] ??
              nested['cameraAngle'] ??
              'Face On')
          .toString(),
      thumbnailUrl: thumbnailUrl,
      videoUrl: remoteVideo.isNotEmpty ? remoteVideo : localPath,
      isSharedWithCoach: json['isSharedWithCoach'] == true,
      recordedAt: DateTime.tryParse(
        (json['recorded_at'] ??
                json['recordedAt'] ??
                nested['recorded_at'] ??
                nested['recordedAt'] ??
                '')
            .toString(),
      ),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? nested['createdAt'] ?? '').toString(),
      ),
      sessionId: (json['client_session_id'] ?? json['sessionId'] ?? '')
          .toString(),
      localId: (json['local_id'] ?? json['localId'] ?? '').toString(),
      isLocal: isLocal,
      // Local queued clips are not analyzed yet — open the local player.
      hasAnalysis: isLocal ? false : hasAnalysis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'analysisId': analysisId,
      'swingId': swingId,
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
      'hasAnalysis': hasAnalysis,
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

  /// Local welcome text — never sent to the server as history.
  final bool isGreeting;

  /// Local error reply — never sent to the server as history.
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isGreeting = false,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
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
