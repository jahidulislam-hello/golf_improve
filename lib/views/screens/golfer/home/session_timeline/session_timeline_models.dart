import 'package:flutter/material.dart';

/// Status of a single step in the "Journey" vertical timeline.
enum JourneyStepStatus {
  /// Step is done — filled navy circle with a white check.
  completed,

  /// Step is currently happening — outlined blue circle with an eye icon
  /// and a blue "In progress…" caption underneath.
  inProgress,

  /// Step hasn't happened yet — light gray circle, muted gray text.
  upcoming,
}

/// A single row in the "Journey" timeline card
/// (e.g. "Swing Recorded", "AI Analysis (Beta)", "Coach Reviewing"...).
class JourneyStep {
  const JourneyStep({
    required this.title,
    required this.subtitle,
    required this.status,
    this.timestamp,
    this.badgeText,
    this.icon,
  });

  /// Bold headline, e.g. "Swing Recorded".
  final String title;

  /// Gray description line under the title,
  /// e.g. "Driver · Face On · 0:12" or "Awaiting response".
  final String subtitle;

  final JourneyStepStatus status;

  /// Right-aligned-under-subtitle timestamp, e.g. "Today, 9:14 AM".
  /// Null for steps that haven't happened yet.
  final String? timestamp;

  /// Small pill badge next to the title, e.g. "BETA". Null if none.
  final String? badgeText;

  /// Icon used only when [status] is [JourneyStepStatus.upcoming]
  /// (completed/inProgress always render check / eye icons).
  final IconData? icon;
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

  /// e.g. "Feedback received · Today 11:30 AM"
  final String receivedAtLabel;

  final String quote;
}
