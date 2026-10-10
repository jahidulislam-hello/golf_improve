import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// One tile in the 2x2 "Quick Actions" grid (AI Analysis, Logbook, Share
/// with Coach, Library). Fully tappable via [onTap].
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.action,
    required this.onTap,
  });

  final QuickActionModel action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: AppRadii.cardBorderRadius,
      child: InkWell(
        borderRadius: AppRadii.cardBorderRadius,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardBorderRadius,
            border: AppRadii.cardBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.iconColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.type16.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays out four [QuickActionCard]s in a fixed 2x2 grid.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<QuickActionModel> actions;
  final ValueChanged<QuickActionModel> onActionTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionCard(
          action: action,
          onTap: () => onActionTap(action),
        );
      },
    );
  }
}
