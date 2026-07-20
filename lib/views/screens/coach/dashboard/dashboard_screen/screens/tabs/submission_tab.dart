import 'package:flutter/material.dart';
import '../../controllers/review_swing_controller.dart';
import '../../widgets/review/ai_analysis_card.dart';
import '../../widgets/review/session_notes_card.dart';
import '../../widgets/review/stat_row_card.dart';
import '../../widgets/review/tinted_info_card.dart';
import '../../widgets/review/video_analysis_card.dart';

/// "Submission" tab: the raw swing video + the student's own context
/// (question, session notes, AI analysis, the coach's last note on them).
class SubmissionTab extends StatelessWidget {
  const SubmissionTab({super.key, required this.controller});

  final ReviewSwingController controller;

  @override
  Widget build(BuildContext context) {
    final review = controller.review;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        VideoAnalysisCard(
          thumbnailUrl: review.videoThumbnailUrl,
          positionLabel: review.currentPositionLabel,
          isPlaying: controller.isPlaying,
          onPlayPause: controller.togglePlay,
        ),
        const SizedBox(height: 14),
        SwingStatRow(
          club: review.club,
          angle: review.angle,
          durationLabel: review.durationLabel,
        ),
        const SizedBox(height: 14),
        TintedInfoCard.question(
          avatarUrl: review.studentAvatarUrl,
          question: review.studentQuestion,
        ),
        const SizedBox(height: 14),
        SessionNotesCard(
          notes: review.studentSessionNotes,
          tags: review.sessionTags,
        ),
        const SizedBox(height: 14),
        AiAnalysisCard(points: review.aiAnalysisPoints),
        if (review.lastNoteOnStudent != null) ...[
          const SizedBox(height: 14),
          TintedInfoCard.note(
            studentFirstName: review.studentName.split(' ').first,
            note: review.lastNoteOnStudent!,
          ),
        ],
      ],
    );
  }
}
