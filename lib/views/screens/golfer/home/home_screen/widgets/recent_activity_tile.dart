import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';


/// One row in the "Recent Activity" list: thumbnail, title/subtitle, and a
/// trailing score percentage. Tappable via [onTap].
class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.showDivider = true,
  });

  final RecentActivityModel activity;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Image.asset(
                        activity.thumbnailAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.borderLightGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: AppTextStyles.type14.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(activity.subtitle, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${activity.scorePercent}%',
                        style: AppTextStyles.type14.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('Score', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
              if (showDivider) ...[
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLightGray,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
