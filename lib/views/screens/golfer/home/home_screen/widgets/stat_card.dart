import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';


/// One of the three stat chips ("12.4 Handicap", "847 Swings", "23 This
/// Week") shown in a row below the hero carousel.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final StatModel stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: AppTextStyles.type23.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Lays out the three [StatCard]s in an evenly-spaced row with hairline
/// separators, matching the design.
class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.stats});

  final List<StatModel> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return SizedBox(
              height: 44,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.borderLightGray,
              ),
            );
          }
          final stat = stats[i ~/ 2];
          return Expanded(child: StatCard(stat: stat));
        }),
      ),
    );
  }
}
