import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// White rounded card with an uppercase eyebrow label, matching the
/// "WHAT'S THE REMINDER?" / "CLUB TYPE" / "SELECT VIDEO" / "SHARE SETTINGS"
/// sections used across the app's forms.
class AddSwingSectionCard extends StatelessWidget {
  const AddSwingSectionCard({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
    this.childTopSpacing = 14,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  /// Optional caption line under the label, e.g. "Permissions for how your
  /// Coach can interact with the video."
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final double childTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing == null)
            Text(label, style: AppTextStyles.sectionEyebrow)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.sectionEyebrow),
                trailing!,
              ],
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppTextStyles.caption),
          ],
          SizedBox(height: childTopSpacing),
          child,
        ],
      ),
    );
  }
}
