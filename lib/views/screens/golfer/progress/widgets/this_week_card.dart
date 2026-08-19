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
    final isUp = controller.thisWeekTrend.toLowerCase() != 'down';
    final trendColor =
        isUp ? AppColors.accentGreen : AppColors.destructiveRed;
    final message = _message();

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
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${controller.thisWeekSwings}',
                    style: AppTextStyles.statNumber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'swings',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isUp
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.caption.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _message() {
    final base = controller.thisWeekMessage.isNotEmpty
        ? controller.thisWeekMessage
        : 'Up from ${controller.lastWeekSwings} last week';
    if (controller.isBestWeek && !base.toLowerCase().contains('best')) {
      return '$base — your best week yet.';
    }
    return base;
  }
}
