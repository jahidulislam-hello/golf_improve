import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// The social-sign-in style button: a full-width pill with a leading
/// icon, used for "Continue with Google" (white) and "Continue with
/// Apple" (dark navy). Pass your own [backgroundColor] / [textColor] /
/// [icon] to reuse it for either.
class SecondaryButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final bool withBorder;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.surfaceWhite,
    this.textColor = AppColors.textPrimary,
    this.withBorder = true,
  });

  /// Convenience constructor matching "Continue with Google".
  const SecondaryButton.google({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
  })  : icon = const _GoogleG(),
        backgroundColor = AppColors.surfaceWhite,
        textColor = AppColors.textPrimary,
        withBorder = false;

  /// Convenience constructor matching "Continue with Apple".
  const SecondaryButton.apple({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Apple',
  })  : icon = const Icon(Icons.apple, color: AppColors.surfaceWhite, size: 24),
        backgroundColor = AppColors.primaryNavy,
        textColor = AppColors.surfaceWhite,
        withBorder = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: withBorder
                ? const BorderSide(color: AppColors.borderLightGray)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.buttonLabel.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stand-in for the multicolor Google "G" mark (swap for the real
/// asset — e.g. `Image.asset('assets/google_g.png')` — when you have it).
class _GoogleG extends StatelessWidget {
  const _GoogleG({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/google.png', // Update with your actual path
      width: 22,
      height: 22,
      fit: BoxFit.contain,
    );
  }
}
