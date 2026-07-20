/// A review that a coach still needs to give feedback on.
class PendingReview {
  final String id;
  final String golferName;
  final String club; // e.g. "Driver"
  final String angle; // e.g. "Face On"
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final String quote;
  final bool aiIncluded;

  const PendingReview({
    required this.id,
    required this.golferName,
    required this.club,
    required this.angle,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.quote,
    this.aiIncluded = false,
  });

  /// "0:12" style formatted duration.
  String get durationLabel {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// "Driver · Face On" style subtitle.
  String get subtitle => '$club · $angle';

  PendingReview copyWith({
    String? id,
    String? golferName,
    String? club,
    String? angle,
    String? thumbnailUrl,
    String? videoUrl,
    Duration? duration,
    String? quote,
    bool? aiIncluded,
  }) {
    return PendingReview(
      id: id ?? this.id,
      golferName: golferName ?? this.golferName,
      club: club ?? this.club,
      angle: angle ?? this.angle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      quote: quote ?? this.quote,
      aiIncluded: aiIncluded ?? this.aiIncluded,
    );
  }
}

/// A review the coach has already completed.
class CompletedReview {
  final String id;
  final String golferName;
  final String club;
  final String angle;
  final DateTime completedAt;

  const CompletedReview({
    required this.id,
    required this.golferName,
    required this.club,
    required this.angle,
    required this.completedAt,
  });

  String get subtitle {
    final days = DateTime.now().difference(completedAt).inDays;
    final agoLabel = days <= 0 ? 'Today' : (days == 1 ? '1 day ago' : '$days days ago');
    return '$club · $angle · $agoLabel';
  }
}
