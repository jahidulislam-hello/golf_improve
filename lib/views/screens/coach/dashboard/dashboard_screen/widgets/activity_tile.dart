import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../models/dashboard_activity.dart';


/// One row in the "Activity" feed — a tinted icon circle plus a
/// message + timestamp. Colors are picked per [ActivityKind] to match
/// the quick-action tints already defined in AppColors.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    this.onTap,
    this.showDivider = true,
  });

  final DashboardActivity activity;
  final VoidCallback? onTap;
  final bool showDivider;

  ({Color bg, Color fg}) get _tint {
    switch (activity.kind) {
      case ActivityKind.upload:
        return (bg: AppColors.quickActionAiBg, fg: AppColors.quickActionAiIcon);
      case ActivityKind.review:
        return (
          bg: AppColors.quickActionLogbookBg,
          fg: AppColors.quickActionLogbookIcon,
        );
      case ActivityKind.milestone:
        return (
          bg: AppColors.quickActionShareBg,
          fg: AppColors.quickActionShareIcon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tint;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: tint.bg, shape: BoxShape.circle),
            child: Icon(activity.icon, size: 18, color: tint.fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.message,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(activity.timeAgo, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );

    final tappable = onTap == null
        ? row
        : InkWell(onTap: onTap, child: row);

    if (!showDivider) return tappable;

    return Column(
      children: [
        tappable,
        Divider(height: 1, color: AppColors.borderLightGray),
      ],
    );
  }
}
