// import 'package:flutter/material.dart';
// import '../review_item.dart';

// /// Whether an [AiAnalysisPoint] is flagged as a potential issue or
// /// confirmed clean — drives the red vs. green icon tint on the card.
// enum AiAnalysisSeverity { warning, clean }

// class AiAnalysisPoint {
//   const AiAnalysisPoint({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.severity,
//   });

//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final AiAnalysisSeverity severity;
// }

// /// The coach's response to the AI's observations on the "Your Feedback" tab.
// enum AiAgreement { undecided, agreed, needsCorrection }

// /// One editable card in the "Practice Plan Builder" (e.g. "Days 1-3").
// class PracticePlanItem {
//   PracticePlanItem({
//     required this.id,
//     required this.dayRangeLabel,
//     this.description = '',
//   });

//   final String id;
//   String dayRangeLabel;
//   String description;
// }

// /// Everything the "Review Swing" screen needs: the submitted swing itself,
// /// the student's context, the AI's read on it, and the coach's in-progress
// /// feedback / practice plan.
// class SwingReview {
//   SwingReview({
//     required this.id,
//     required this.studentName,
//     required this.studentAvatarUrl,
//     required this.club,
//     required this.angle,
//     required this.duration,
//     required this.videoThumbnailUrl,
//     required this.currentPositionLabel,
//     required this.studentQuestion,
//     required this.studentSessionNotes,
//     required this.sessionTags,
//     required this.aiAnalysisPoints,
//     this.lastNoteOnStudent,
//     this.coachFeedback = '',
//     this.recommendedDrill = '',
//     List<PracticePlanItem>? practicePlan,
//     this.aiAgreement = AiAgreement.undecided,
//     this.aiExtraContext = '',
//   }) : practicePlan = practicePlan ?? [];

//   final String id;
//   final String studentName;
//   final String studentAvatarUrl;

//   final String club;
//   final String angle;
//   final Duration duration;

//   final String videoThumbnailUrl;

//   /// e.g. "0:02/0:08" — shown on the scrub bar.
//   final String currentPositionLabel;

//   final String studentQuestion;
//   final String studentSessionNotes;
//   final List<String> sessionTags;

//   final List<AiAnalysisPoint> aiAnalysisPoints;

//   /// The coach's most recent prior note on this student, if any.
//   final String? lastNoteOnStudent;

//   // ----- Editable on "Your Feedback" -----
//   String coachFeedback;
//   String recommendedDrill;
//   List<PracticePlanItem> practicePlan;
//   AiAgreement aiAgreement;
//   String aiExtraContext;

//   String get subtitleLine => '$studentName · $club · $angle';

//   String get durationLabel {
//     final minutes = duration.inMinutes;
//     final seconds = duration.inSeconds % 60;
//     return '$minutes:${seconds.toString().padLeft(2, '0')}';
//   }

//   /// Sample data matching the "Alex Thompson · Driver · Face On" mock —
//   /// handy for previews/demos. Swap for your real repository call.
//   factory SwingReview.mockAlexThompson() {
//     return SwingReview(
//       id: 'alex_thompson_driver_faceon',
//       studentName: 'Alex Thompson',
//       studentAvatarUrl: 'https://i.pravatar.cc/150?img=12',
//       club: 'Driver',
//       angle: 'Face On',
//       duration: const Duration(seconds: 12),
//       videoThumbnailUrl:
//           'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
//       currentPositionLabel: '0:02/0:08',
//       studentQuestion: 'My downswing path feels off — can you check my '
//           'transition? The ball keeps going right when I swing harder.',
//       studentSessionNotes: 'Felt like my swing was improving today, more '
//           'compact at the top. Still struggling with the transition though.',
//       sessionTags: const ['takeaway', 'downswing', 'tempo'],
//       aiAnalysisPoints: [
//         const AiAnalysisPoint(
//           icon: Icons.remove_red_eye_outlined,
//           title: 'Head movement',
//           subtitle: 'Head drifts forward during backswing',
//           severity: AiAnalysisSeverity.warning,
//         ),
//         const AiAnalysisPoint(
//           icon: Icons.monitor_heart_outlined,
//           title: 'Lead leg at impact',
//           subtitle: 'Lead leg slightly bent at impact',
//           severity: AiAnalysisSeverity.warning,
//         ),
//         const AiAnalysisPoint(
//           icon: Icons.check_circle_outline_rounded,
//           title: 'Takeaway path',
//           subtitle: 'Neutral path — no issues detected',
//           severity: AiAnalysisSeverity.clean,
//         ),
//       ],
//       lastNoteOnStudent: "Watch your transition — you're firing your "
//           "upper body before your hips have cleared.",
//       practicePlan: [
//         PracticePlanItem(
//           id: 'plan_1',
//           dayRangeLabel: 'Days 1-3',
//           description: 'Hip Lead Drill only — 50% speed, 3 sets of 10',
//         ),
//         PracticePlanItem(
//           id: 'plan_2',
//           dayRangeLabel: 'Days 4-7',
//           description: 'Hip Lead Drill only — 50% speed, 3 sets of 10',
//         ),
//       ],
//     );
//   }

//   /// Builds a placeholder [SwingReview] for a student's recent-upload
//   /// row so tapping it can open the Review Swing screen immediately.
//   /// Swap this for a real fetch (by upload id) once your backend is wired
//   /// up — the student's question/session-notes/AI fields are generic
//   /// filler here since a RecentUpload only carries club/angle/score.
//   factory SwingReview.fromUpload({
//     required String studentName,
//     required String studentAvatarUrl,
//     required String club,
//     required String angle,
//     required int scorePercent,
//     required String thumbnailUrl,
//   }) {
//     return SwingReview(
//       id: '${studentName}_${club}_$angle',
//       studentName: studentName,
//       studentAvatarUrl: studentAvatarUrl,
//       club: club,
//       angle: angle,
//       duration: const Duration(seconds: 10),
//       videoThumbnailUrl: thumbnailUrl,
//       currentPositionLabel: '0:00/0:10',
//       studentQuestion:
//           'Can you take a look at this one when you get a chance?',
//       studentSessionNotes: 'Uploaded from the range — no extra notes added.',
//       sessionTags: const [],
//       aiAnalysisPoints: [
//         AiAnalysisPoint(
//           icon: Icons.check_circle_outline_rounded,
//           title: 'Overall consistency',
//           subtitle: '$scorePercent% match to target form',
//           severity: scorePercent >= 80
//               ? AiAnalysisSeverity.clean
//               : AiAnalysisSeverity.warning,
//         ),
//       ],
//     );
//   }

//   /// Builds a [SwingReview] straight from a Reviews-screen
//   /// [PendingReviewItem] — this is what opens when a pending review card
//   /// (or its "Review Now" button) is tapped.
//   factory SwingReview.fromPendingReviewItem(PendingReviewItem item) {
//     return SwingReview(
//       id: item.id,
//       studentName: item.studentName,
//       studentAvatarUrl: item.studentAvatarUrl,
//       club: item.club,
//       angle: item.angle,
//       duration: _parseDurationLabel(item.durationLabel),
//       videoThumbnailUrl: item.videoThumbnailUrl,
//       currentPositionLabel: '0:00/${item.durationLabel}',
//       studentQuestion: item.quote,
//       studentSessionNotes:
//           'Uploaded from the range — no extra notes added.',
//       sessionTags: const [],
//       aiAnalysisPoints: item.hasAiIncluded
//           ? [
//               const AiAnalysisPoint(
//                 icon: Icons.remove_red_eye_outlined,
//                 title: 'Head movement',
//                 subtitle: 'Head drifts forward during backswing',
//                 severity: AiAnalysisSeverity.warning,
//               ),
//               const AiAnalysisPoint(
//                 icon: Icons.check_circle_outline_rounded,
//                 title: 'Takeaway path',
//                 subtitle: 'Neutral path — no issues detected',
//                 severity: AiAnalysisSeverity.clean,
//               ),
//             ]
//           : const [],
//     );
//   }

//   static Duration _parseDurationLabel(String label) {
//     final parts = label.split(':');
//     if (parts.length != 2) return Duration.zero;
//     final minutes = int.tryParse(parts[0]) ?? 0;
//     final seconds = int.tryParse(parts[1]) ?? 0;
//     return Duration(minutes: minutes, seconds: seconds);
//   }
// }
