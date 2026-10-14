/// Status of a single step in the "Journey" vertical timeline.
enum JourneyStepStatus {
  /// Step is done — filled navy circle with a white check.
  completed,

  /// Step is currently happening — outlined blue circle with an eye icon.
  inProgress,

  /// Share is waiting for a connection and will send later.
  queued,

  /// Step hasn't happened yet — light gray circle, muted gray text.
  upcoming,
}

/// A single row in the "Journey" timeline card
/// (e.g. "Swing Recorded", "AI Analysis (Beta)", "Coach Reviewing"...).
class JourneyStep {
  const JourneyStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    this.dateLabel,
  });

  final int step;

  /// Bold headline, e.g. "Swing Recorded".
  final String title;

  /// Gray description line under the title,
  /// e.g. "Driver · Face On · 0:12" or "Awaiting coach response".
  final String subtitle;

  final JourneyStepStatus status;

  /// Right-aligned status, e.g. "Completed", "In progress", "Pending", "Queued".
  final String statusLabel;

  /// Right-aligned date, e.g. "Oct 14, 2026". Null when the step has no time.
  final String? dateLabel;
}

/// State describing the video preview at the top of the screen.
class SwingVideoState {
  const SwingVideoState({
    required this.thumbnailUrl,
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.caption = 'Scrub to the moment you want to analyse. Then draw.',
  });

  final String thumbnailUrl;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String caption;

  double get progress =>
      duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds;

  SwingVideoState copyWith({
    String? thumbnailUrl,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? caption,
  }) {
    return SwingVideoState(
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      caption: caption ?? this.caption,
    );
  }
}

/// Coach feedback shown in the dark card at the bottom of the screen.
class CoachFeedback {
  const CoachFeedback({
    required this.coachName,
    required this.initials,
    required this.receivedAtLabel,
    required this.quote,
  });

  final String coachName;
  final String initials;

  /// e.g. "Feedback received · Oct 14, 2026"
  final String receivedAtLabel;

  final String quote;
}

/// Main action returned once the coach has replied.
class TimelinePrimaryAction {
  const TimelinePrimaryAction({
    required this.label,
    required this.action,
    required this.isAvailable,
    this.shareId,
  });

  final String label;
  final String action;
  final bool isAvailable;
  final String? shareId;
}
