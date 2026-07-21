// import 'package:flutter/material.dart';
// import '../models/session_timeline_models.dart';
//
// /// Controller for the "Session Timeline" screen.
// ///
// /// Owns:
// ///  - the swing video playback state (play/pause, scrub position)
// ///  - the "Journey" step list
// ///  - the coach feedback shown at the bottom
// ///
// /// Wire it up with `ChangeNotifierProvider` (or your DI of choice) and
// /// listen to it with `context.watch<SessionTimelineController>()`,
// /// or use it directly with an `AnimatedBuilder` / `ListenableBuilder`.
// class SessionTimelineController extends ChangeNotifier {
//   SessionTimelineController({
//     String? swingId,
//     String thumbnailUrl =
//         'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
//   }) : swingId = swingId ?? 'swing_001' {
//     _video = SwingVideoState(
//       thumbnailUrl: thumbnailUrl,
//       isPlaying: false,
//       position: const Duration(seconds: 2),
//       duration: const Duration(seconds: 8),
//     );
//
//     _journeySteps = const [
//       JourneyStep(
//         title: 'Swing Recorded',
//         subtitle: 'Driver · Face On · 0:12',
//         status: JourneyStepStatus.completed,
//         timestamp: 'Today, 9:14 AM',
//       ),
//       JourneyStep(
//         title: 'AI Analysis',
//         subtitle: '2 observations flagged',
//         status: JourneyStepStatus.completed,
//         timestamp: 'Today, 9:20 AM',
//         badgeText: 'BETA',
//       ),
//       JourneyStep(
//         title: 'Shared with Coach',
//         subtitle:
//             'James Keller notified — video, AI result, notes & question included',
//         status: JourneyStepStatus.completed,
//         timestamp: 'Today, 9:22 AM',
//       ),
//       JourneyStep(
//         title: 'Coach Reviewing',
//         subtitle: 'Usually responds within 2 hours',
//         status: JourneyStepStatus.inProgress,
//       ),
//       JourneyStep(
//         title: 'Coach Feedback',
//         subtitle: 'Awaiting response',
//         status: JourneyStepStatus.upcoming,
//         icon: Icons.chat_bubble_outline_rounded,
//       ),
//       JourneyStep(
//         title: 'Practice Session',
//         subtitle: 'Not started',
//         status: JourneyStepStatus.upcoming,
//         icon: Icons.golf_course_rounded,
//       ),
//     ];
//
//     _feedback = const CoachFeedback(
//       coachName: 'James Keller',
//       initials: 'JK',
//       receivedAtLabel: 'Feedback received · Today 11:30 AM',
//       quote:
//           'Great effort, Alex. I can see the transition issue clearly in '
//           'frame 0:04. Your upper body is firing before your hips have '
//           'cleared…',
//     );
//   }
//
//   final String swingId;
//
//   late SwingVideoState _video;
//   SwingVideoState get video => _video;
//
//   late final List<JourneyStep> _journeySteps;
//   List<JourneyStep> get journeySteps => List.unmodifiable(_journeySteps);
//
//   late final CoachFeedback _feedback;
//   CoachFeedback get feedback => _feedback;
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   /// Index of the step currently in progress, or -1 if none.
//   int get activeStepIndex =>
//       _journeySteps.indexWhere((s) => s.status == JourneyStepStatus.inProgress);
//
//   // ===== Video controls =====
//
//   void togglePlayback() {
//     _video = _video.copyWith(isPlaying: !_video.isPlaying);
//     notifyListeners();
//   }
//
//   void seekTo(Duration position) {
//     final clamped = position < Duration.zero
//         ? Duration.zero
//         : (position > _video.duration ? _video.duration : position);
//     _video = _video.copyWith(position: clamped);
//     notifyListeners();
//   }
//
//   void seekToFraction(double fraction) {
//     final ms = (_video.duration.inMilliseconds * fraction).round();
//     seekTo(Duration(milliseconds: ms));
//   }
//
//   void onExpandVideo() {
//     // Hook up navigation to a full-screen player here.
//   }
//
//   void onOpenAnalysisTool() {
//     // Hook up navigation to the drawing/annotation tool here.
//   }
//
//   // ===== Journey / feedback actions =====
//
//   Future<void> refresh() async {
//     _isLoading = true;
//     notifyListeners();
//     // Replace with a real repository/API call.
//     await Future.delayed(const Duration(milliseconds: 600));
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   void onReadFullFeedback() {
//     // Hook up navigation to the full feedback / thread screen here.
//   }
//
//   static String formatDuration(Duration d) {
//     final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
//     final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }
// }
