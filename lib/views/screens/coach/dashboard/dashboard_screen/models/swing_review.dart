import 'package:flutter/material.dart';

/// Whether an [AiAnalysisPoint] is flagged as a potential issue or
/// confirmed clean — drives the red vs. green icon tint on the card.
enum AiAnalysisSeverity { warning, clean }

class AiAnalysisPoint {
  const AiAnalysisPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.severity,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AiAnalysisSeverity severity;
}

/// The coach's response to the AI's observations on the "Your Feedback" tab.
enum AiAgreement { undecided, agreed, needsCorrection }

/// One editable card in the "Practice Plan Builder" (e.g. "Days 1-3").
class PracticePlanItem {
  PracticePlanItem({
    required this.id,
    required this.dayRangeLabel,
    this.description = '',
  });

  final String id;
  String dayRangeLabel;
  String description;

  Map<String, dynamic> toJson() => {
        'dayRange': dayRangeLabel,
        'description': description,
      };

  factory PracticePlanItem.fromJson(Map<String, dynamic> json) {
    return PracticePlanItem(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      dayRangeLabel: '${json['dayRange'] ?? json['dayRangeLabel'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }
}

/// Everything the "Review Swing" screen needs: the submitted swing itself,
/// the student's context, the AI's read on it, and the coach's in-progress
/// feedback / practice plan.
class SwingReview {
  SwingReview({
    required this.id,
    required this.studentName,
    required this.studentAvatarUrl,
    required this.club,
    required this.angle,
    required this.duration,
    required this.videoThumbnailUrl,
    required this.currentPositionLabel,
    required this.studentQuestion,
    required this.studentSessionNotes,
    required this.sessionTags,
    required this.aiAnalysisPoints,
    this.lastNoteOnStudent,
    this.coachFeedback = '',
    this.recommendedDrill = '',
    List<PracticePlanItem>? practicePlan,
    this.aiAgreement = AiAgreement.undecided,
    this.aiExtraContext = '',
  }) : practicePlan = practicePlan ?? [];

  final String id;
  final String studentName;
  final String studentAvatarUrl;

  final String club;
  final String angle;
  final Duration duration;

  final String videoThumbnailUrl;

  /// e.g. "0:02/0:08" — shown on the scrub bar.
  final String currentPositionLabel;

  final String studentQuestion;
  final String studentSessionNotes;
  final List<String> sessionTags;

  final List<AiAnalysisPoint> aiAnalysisPoints;

  /// The coach's most recent prior note on this student, if any.
  final String? lastNoteOnStudent;

  // ----- Editable on "Your Feedback" -----
  String coachFeedback;
  String recommendedDrill;
  List<PracticePlanItem> practicePlan;
  AiAgreement aiAgreement;
  String aiExtraContext;

  String get subtitleLine => '$studentName · $club · $angle';

  String get durationLabel {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory SwingReview.fromShareApi(Map<String, dynamic> data) {
    final user = _asMap(data['user']);
    final swing = _asMap(data['swingLibrary']) ?? {};
    final seconds = _asInt(swing['duration']);
    final duration = Duration(seconds: seconds);
    final durationLabel =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return SwingReview(
      id: '${data['_id'] ?? ''}',
      studentName: '${user?['name'] ?? ''}',
      studentAvatarUrl: '${user?['profileUrl'] ?? ''}',
      club: '${swing['clubType'] ?? ''}',
      angle: '${swing['cameraAngle'] ?? ''}',
      duration: duration,
      videoThumbnailUrl:
          '${swing['thumbnailUrl'] ?? swing['videoUrl'] ?? ''}',
      currentPositionLabel: seconds > 0 ? '0:00/$durationLabel' : '',
      studentQuestion: '${data['message'] ?? ''}',
      studentSessionNotes: '${swing['sessionNotes'] ?? ''}',
      sessionTags: _stringList(swing['sessionTags'] ?? data['sessionTags']),
      aiAnalysisPoints: _aiPoints(swing['aiAnalysis'] ?? data['aiAnalysis']),
      lastNoteOnStudent: _nullableString(
        data['lastNote'] ?? swing['lastNoteOnStudent'] ?? data['lastNoteOnStudent'],
      ),
      practicePlan: _practicePlan(data['practicePlan']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static int _asInt(dynamic raw) {
    if (raw is num) return raw.round();
    return int.tryParse('${raw ?? ''}') ?? 0;
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString();
    return text.isEmpty ? null : text;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static List<PracticePlanItem> _practicePlan(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => _asMap(e))
        .whereType<Map<String, dynamic>>()
        .map(PracticePlanItem.fromJson)
        .toList();
  }

  static List<AiAnalysisPoint> _aiPoints(dynamic raw) {
    final map = _asMap(raw);
    if (map == null || map.isEmpty) return const [];
    return map.entries.map((entry) {
      final subtitle = '${entry.value ?? ''}';
      final lower = subtitle.toLowerCase();
      final isClean = lower.contains('no issue') ||
          lower.contains('neutral') ||
          lower.contains('clean');
      return AiAnalysisPoint(
        icon: _iconForAiKey(entry.key),
        title: _titleForAiKey(entry.key),
        subtitle: subtitle,
        severity:
            isClean ? AiAnalysisSeverity.clean : AiAnalysisSeverity.warning,
      );
    }).toList();
  }

  static IconData _iconForAiKey(String key) {
    switch (key) {
      case 'headMovement':
        return Icons.remove_red_eye_outlined;
      case 'leadLegAtImpact':
        return Icons.monitor_heart_outlined;
      case 'takeawayPath':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }

  static String _titleForAiKey(String key) {
    final spaced = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
