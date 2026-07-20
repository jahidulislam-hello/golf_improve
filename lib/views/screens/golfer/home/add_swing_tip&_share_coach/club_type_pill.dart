import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// Single filter pill in the "CLUB TYPE" row. Dark/navy when selected,
/// light-gray inactive fill otherwise — matches `AppColors.pillInactive`.
class ClubTypePill extends StatelessWidget {
  const ClubTypePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.pillInactive,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTextStyles.type14.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.surfaceWhite : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
