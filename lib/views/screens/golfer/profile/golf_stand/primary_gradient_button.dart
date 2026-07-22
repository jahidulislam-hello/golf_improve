import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// Generic full-width gradient CTA button (e.g. "Activate Golf Stand",
/// "Send Feedback"). Screen-agnostic so any screen needing this style
/// of primary action can reuse it.
class PrimaryGradientButton extends StatelessWidget {
  const PrimaryGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isActive ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.ctaBlueGradient : null,
            color: enabled ? null : AppColors.borderLightGray,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: AppColors.ctaBrightBlue.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(AppColors.surfaceWhite),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: enabled
                      ? AppColors.surfaceWhite
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: enabled
                      ? AppColors.surfaceWhite
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}