import 'package:flutter/material.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/controllers/review_swing_controller.dart';
import '../../models/swing_review.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// The "Submission | Your Feedback" underline tab bar. Deliberately not a
/// [TabBar]/[TabController] pair so it can be driven directly by
/// [ReviewSwingController.tab] without an extra Ticker/Sync dance.
class ReviewTabBar extends StatelessWidget {
  const ReviewTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ReviewSwingTab selected;
  final ValueChanged<ReviewSwingTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundOffWhite,
      child: Row(
        children: [
          _TabItem(
            label: 'Submission',
            isSelected: selected == ReviewSwingTab.submission,
            onTap: () => onChanged(ReviewSwingTab.submission),
          ),
          _TabItem(
            label: 'Your Feedback',
            isSelected: selected == ReviewSwingTab.yourFeedback,
            onTap: () => onChanged(ReviewSwingTab.yourFeedback),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.textPrimary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
