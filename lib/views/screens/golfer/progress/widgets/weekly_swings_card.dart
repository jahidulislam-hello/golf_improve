import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
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
          Text(
            controller.weeklyChartTitle,
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricChip(
                label: 'Swings',
                selected: controller.chartMetric == ProgressChartMetric.swings,
                onTap: () => controller.selectChart(ProgressChartMetric.swings),
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Minutes',
                selected: controller.chartMetric == ProgressChartMetric.minutes,
                onTap: () =>
                    controller.selectChart(ProgressChartMetric.minutes),
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Sessions',
                selected:
                    controller.chartMetric == ProgressChartMetric.sessions,
                onTap: () =>
                    controller.selectChart(ProgressChartMetric.sessions),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LineAreaChart(
            values: controller.activeWeeklySeries,
            labels: controller.weeklySwingLabels,
            lineColor: AppColors.ctaBrightBlue,
            fillTopColor: AppColors.chartFillTop,
            showAllDots: true,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBlueBg : AppColors.backgroundOffWhite,
          borderRadius: AppRadii.cardBorderRadius,
          border: selected ? null : AppRadii.cardBorder,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.ctaBrightBlue : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
