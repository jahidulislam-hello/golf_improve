/// A single "Pending Review" entry — one swing a student has submitted
/// that is waiting on the coach's feedback.
class PendingReview {
  PendingReview({
    required this.id,
    required this.studentName,
    required this.club,
    required this.angle,
    required this.timeAgo,
    required this.scorePercent,
    required this.avatarUrl,
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.isUnread = true,
  });

  final String id;
  final String studentName;

  /// e.g. "Driver", "7 Iron", "Wedge"
  final String club;

  /// e.g. "Face On", "Down the Line"
  final String angle;

  /// e.g. "2h ago", "Yesterday"
  final String timeAgo;

  /// 0-100 consistency / analysis score shown on the right of the card.
  final int scorePercent;

  final String avatarUrl;
  final String thumbnailUrl;
  final String videoUrl;

  /// Controls the small blue unread dot next to the student's name.
  final bool isUnread;

  String get subtitle => '$club · $angle';

  PendingReview copyWith({bool? isUnread}) {
    return PendingReview(
      id: id,
      studentName: studentName,
      club: club,
      angle: angle,
      timeAgo: timeAgo,
      scorePercent: scorePercent,
      avatarUrl: avatarUrl,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
