import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'line_area_chart.dart';
import 'section_card.dart';

class WeeklySwingsCard extends StatelessWidget {
  const WeeklySwingsCard({super.key, required this.controller});
  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Swings', style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
              Pill(
                label: 'This Week',
                background: AppColors.accentBlueBg,
                foreground: AppColors.ctaBrightBlue,
              ),
            ],
          ),
          const SizedBox(height: 18),
          LineAreaChart(
            values: controller.weeklySwingSeries,
            labels: ProgressController.weeklySwingLabels,
            lineColor: AppColors.ctaBrightBlue,
            fillTopColor: AppColors.chartFillTop,
            showAllDots: true,
          ),
        ],
      ),
    );
  }
}
