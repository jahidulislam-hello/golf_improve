import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'package:golf_training_app/views/screens/golfer/progress/widgets/trend_arrow_icon.dart';
import 'section_card.dart';

class ThisWeekCard extends StatelessWidget {
  const ThisWeekCard({super.key, required this.controller});
  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: TrendArrowIcon(size: 46),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THIS WEEK',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.ctaBrightBlue,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _WeekStat(
                      value: '${controller.sessionsThisWeek}',
                      label: 'Sessions',
                    ),
                  ),
                  Expanded(
                    child: _WeekStat(
                      value: '${controller.thisWeekSwings}',
                      label: 'Swings',
                    ),
                  ),
                  Expanded(
                    child: _WeekStat(
                      value: '${controller.minutesThisWeek}',
                      label: 'Minutes Practised',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                controller.weekComparison,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.statNumber.copyWith(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
