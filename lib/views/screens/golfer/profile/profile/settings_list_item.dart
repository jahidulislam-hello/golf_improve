import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// A single tappable row inside the settings list card
/// (e.g. "Personal Info", "Logbook", "Notifications"...).
class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBackgroundColor = AppColors.pillInactive,
    this.iconColor = AppColors.textPrimary,
    this.trailingIconColor = AppColors.textSecondary,
    this.titleStyle = AppTextStyles.listItemTitle,
    this.showDivider = true,
    this.height = 70,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color trailingIconColor;
  final TextStyle titleStyle;
  final bool showDivider;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: titleStyle,
                        ),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.listItemSubtitle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: trailingIconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderCard,
            ),
          ),
      ],
    );
  }
}