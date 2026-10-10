import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'circle_icon_button.dart';


/// Generic "< Title / Subtitle" header bar used across screens (Golf
/// Stand activation, Review Swing, etc). Kept screen-agnostic so any
/// screen needing a back button + title/subtitle pair can reuse it.
class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  /// Optional widget shown at the far right (e.g. a "..." menu button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          size: 36,
          iconSize: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.sectionHeader.copyWith(fontSize: 19),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}