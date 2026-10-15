import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../../controllers/review_swing_controller.dart';

import '../../widgets/review/labeled_text_area_card.dart';
import '../../widgets/review/practice_plan_day_card.dart';
import '../../widgets/review/stat_row_card.dart';
import '../../widgets/review/video_analysis_card.dart';

/// "Your Feedback" tab: the coach's written note, the suggested drill,
/// and the practice plan the coach can edit and approve.
class YourFeedbackTab extends StatelessWidget {
  const YourFeedbackTab({super.key, required this.controller});

  final CoachReviewSwingController controller;

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
          label: 'Primary Correction',
          controller: controller.primaryCorrectionController,
          hintText: 'The one change you want this golfer to make...',
          minLines: 2,
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
          hintText: 'Name the drill for this correction...',
          icon: Icons.change_history_rounded,
          minLines: 2,
        ),
        const SizedBox(height: 18),
        LabeledTextAreaCard(
          label: 'Drill Subtitle',
          controller: controller.drillSubtitleController,
          hintText: 'A short cue the golfer can remember on the range...',
          minLines: 2,
        ),
        const SizedBox(height: 8),
        Text(
          'Suggested from your written feedback, their goals, and practice history.',
          style: AppTextStyles.caption,
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
        _ApprovePlanRow(
          approved: controller.planApproved,
          onChanged: controller.setPlanApproved,
        ),
      ],
    );
  }
}

class _ApprovePlanRow extends StatelessWidget {
  const _ApprovePlanRow({required this.approved, required this.onChanged});

  final bool approved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: approved,
        activeThumbColor: AppColors.surfaceWhite,
        activeTrackColor: AppColors.ctaBrightBlue,
        title: Text(
          'Approve this drill and plan',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Your edits are what the golfer will follow.',
          style: AppTextStyles.caption,
        ),
        onChanged: onChanged,
      ),
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
