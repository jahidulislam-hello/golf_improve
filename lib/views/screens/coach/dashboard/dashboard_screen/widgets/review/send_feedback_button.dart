import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// The full-width "Send Feedback" button pinned at the bottom of both tabs.
class SendFeedbackButton extends StatelessWidget {
  const SendFeedbackButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Send Feedback',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.ctaBlueGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.ctaBrightBlue.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
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
                    const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: AppColors.surfaceWhite,
                    ),
                    const SizedBox(width: 8),
                    Text(label, style: AppTextStyles.buttonLabel),
                  ],
                ),
        ),
      ),
    );
  }
}
