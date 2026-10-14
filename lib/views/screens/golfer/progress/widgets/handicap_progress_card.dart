import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'package:golf_training_app/views/screens/golfer/progress/widgets/handicap_update_dialog.dart';
import 'package:golf_training_app/views/screens/golfer/progress/widgets/line_area_chart.dart';
import 'section_card.dart';
import 'package:golf_training_app/core/app_radii.dart';

class HandicapProgressCard extends StatelessWidget {
  const HandicapProgressCard({super.key, required this.controller});
  final ProgressController controller;

  Future<void> _openUpdateDialog(BuildContext context) async {
    if (controller.isUpdatingHandicap) return;
    final result = await showDialog<double>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => HandicapUpdateDialog(
        initialValue: controller.handicapIndex,
        min: -9.9,
        max: 54.0,
      ),
    );
    if (result == null || !context.mounted) return;
    final ok = await controller.updateHandicapIndex(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Handicap updated'
                : (controller.errorMessage ?? 'Could not update handicap'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryNavy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdated = controller.lastUpdatedLabel.isEmpty
        ? 'Last Updated: —'
        : 'Last Updated: ${controller.lastUpdatedLabel}';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Handicap Progress', style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(lastUpdated, style: AppTextStyles.caption),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.isUpdatingHandicap
                    ? null
                    : () => _openUpdateDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaBrightBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.ctaBrightBlue.withOpacity(0.6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonBorderRadius,
                  ),
                ),
                child: controller.isUpdatingHandicap
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update HCP',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Starting',
                  value: controller.startingHandicap.toStringAsFixed(1),
                  valueColor: AppColors.ctaBrightBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: 'Change',
                  value: controller.handicapChangeLabel,
                  valueColor: controller.handicapChangeIsPositive
                      ? AppColors.accentGreen
                      : (controller.improvement > 0
                          ? AppColors.destructiveRed
                          : AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LineAreaChart(
            values: controller.handicapTrend,
            labels: controller.handicapTrendLabels,
            lineColor: AppColors.ctaBrightBlue,
            fillTopColor: AppColors.chartFillTop,
            dotAtEndOnly: true,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundOffWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
