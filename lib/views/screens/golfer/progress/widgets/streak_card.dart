import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'section_card.dart';
import 'package:golf_training_app/core/app_radii.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.controller});
  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final target = controller.weeklyTargetSessions;
    final done = controller.sessionsThisWeek;
    final progress = target <= 0 ? 0.0 : (done / target).clamp(0.0, 1.0);

    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.insightPositiveIconBg,
              borderRadius: AppRadii.cardBorderRadius,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.accentGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Consistency',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.consistencyLabel,
                  style: AppTextStyles.sectionHeader.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: AppRadii.cardBorderRadius,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.borderLightGray,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
