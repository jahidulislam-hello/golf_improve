import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// A single "title / caption / switch" row, used inside the
/// "SHARE SETTINGS" card. Pass [showDivider] = false for the last row.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.caption,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final String caption;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.type14.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(caption, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.surfaceWhite,
                activeTrackColor: AppColors.primaryNavy,
                inactiveThumbColor: AppColors.surfaceWhite,
                inactiveTrackColor: AppColors.pillInactive,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.borderLightGray.withValues(alpha: 0.6)),
      ],
    );
  }
}
