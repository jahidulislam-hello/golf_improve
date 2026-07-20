import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// A small caps label (optionally with a leading icon) above a white
/// rounded text area. Used for "Your Coaching Feedback", "Recommended
/// Drill", and the free-text field under "Respond to AI Analysis".
class LabeledTextAreaCard extends StatelessWidget {
  const LabeledTextAreaCard({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.icon,
    this.minLines = 3,
    this.dense = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final int minLines;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.quickActionLibraryIcon),
                const SizedBox(width: 6),
              ],
              Text(
                label.toUpperCase(),
                style: AppTextStyles.inputLabel,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(dense ? 12 : 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: null,
            style: AppTextStyles.inputValue.copyWith(fontSize: 14.5),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
