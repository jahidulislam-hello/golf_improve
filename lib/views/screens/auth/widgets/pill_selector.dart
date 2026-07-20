import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// The row of selectable pills used for Gender and Practice Sessions Per
/// Week on the "Tell us about yourself" screen. Selected pill = navy
/// background + white text; unselected = light gray background.
class PillSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const PillSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final bool isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryNavy : AppColors.pillInactive,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              option,
              style: AppTextStyles.type14.copyWith(
                color: isSelected ? AppColors.surfaceWhite : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
