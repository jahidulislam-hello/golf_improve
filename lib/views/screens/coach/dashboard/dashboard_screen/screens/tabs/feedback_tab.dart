import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../../controllers/review_swing_controller.dart';

import '../../widgets/review/ai_agreement_card.dart';
import '../../widgets/review/labeled_text_area_card.dart';
import '../../widgets/review/practice_plan_day_card.dart';
import '../../widgets/review/stat_row_card.dart';
import '../../widgets/review/video_analysis_card.dart';

/// "Your Feedback" tab: the coach's written observations, recommended
/// drill, the Practice Plan Builder, and the AI-agreement responder.
class YourFeedbackTab extends StatelessWidget {
  const YourFeedbackTab({super.key, required this.controller});

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
          showScrubHint: false,
        ),
        const SizedBox(height: 14),
        SwingStatRow(
          club: review.club,
          angle: review.angle,
          durationLabel: review.durationLabel,
        ),
        const SizedBox(height: 18),
        LabeledTextAreaCard(
          label: 'Your Coaching Feedback',
          controller: controller.coachFeedbackController,
          hintText: 'Write your coaching observations here...',
        ),
        const SizedBox(height: 18),
        LabeledTextAreaCard(
          label: 'Recommended Drill',
          controller: controller.recommendedDrillController,
          hintText: 'Describe a specific drill for the student...',
          icon: Icons.change_history_rounded,
          minLines: 2,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Practice Plan Builder',
              style: AppTextStyles.sectionHeader.copyWith(fontSize: 16),
            ),
            _AddDayButton(onTap: controller.addPracticePlanDay),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in controller.practicePlan)
          PracticePlanDayCard(
            key: ValueKey(item.id),
            dayRangeLabel: item.dayRangeLabel,
            initialDescription: item.description,
            onDescriptionChanged: (text) =>
                controller.updatePracticePlanDescription(item.id, text),
            onDelete: () => controller.removePracticePlanDay(item.id),
          ),
        const SizedBox(height: 6),
        AiAgreementCard(
          agreement: controller.aiAgreement,
          onChanged: controller.setAiAgreement,
          extraContextController: controller.aiExtraContextController,
        ),
      ],
    );
  }
}

class _AddDayButton extends StatelessWidget {
  const _AddDayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ctaBrightBlue,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.add, color: AppColors.surfaceWhite, size: 20),
        ),
      ),
    );
  }
}
