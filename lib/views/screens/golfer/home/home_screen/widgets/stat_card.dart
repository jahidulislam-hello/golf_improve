import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// One of the three stat chips ("12.4 Handicap", "847 Swings", "23 This
/// Week") shown in a row below the hero carousel.
///
/// Content-only — the outer [StatCardRow] owns the single card border.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final StatModel stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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

/// Lays out the three [StatCard]s in one card with straight hairline
/// dividers between columns (no per-cell borders).
class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.stats});

  final List<StatModel> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(stats.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Container(
                width: AppRadii.cardBorderWidth,
                color: AppColors.borderLightGray,
              );
            }
            final stat = stats[i ~/ 2];
            return Expanded(child: StatCard(stat: stat));
          }),
        ),
      ),
    );
  }
}
