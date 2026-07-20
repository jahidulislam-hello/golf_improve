import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// A soft-tinted callout card. Two presets cover the mock:
/// - [TintedInfoCard.question] — light blue, avatar + label + quoted text.
/// - [TintedInfoCard.note] — cream/amber, icon + eyebrow label + italic text.
class TintedInfoCard extends StatelessWidget {
  const TintedInfoCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.labelColor,
    required this.label,
    required this.body,
    this.leadingAvatarUrl,
    this.leadingIcon,
    this.labelStyle,
    this.bodyStyle,
  });

  /// "Student's Question" — blue tint, small round avatar leading the label.
  factory TintedInfoCard.question({
    required String avatarUrl,
    required String question,
  }) {
    return TintedInfoCard(
      backgroundColor: AppColors.statusInfoBg,
      borderColor: AppColors.ctaBrightBlue.withOpacity(0.15),
      labelColor: AppColors.ctaBrightBlue,
      label: "Student's Question",
      body: '"$question"',
      leadingAvatarUrl: avatarUrl,
    );
  }

  /// "Your Last Note on Alex" — cream tint, book icon, uppercase eyebrow.
  factory TintedInfoCard.note({required String studentFirstName, required String note}) {
    return TintedInfoCard(
      backgroundColor: AppColors.noteHighlightBg,
      borderColor: AppColors.noteHighlightBorder,
      labelColor: AppColors.noteHighlightText,
      label: 'YOUR LAST NOTE ON $studentFirstName',
      body: '"$note"',
      leadingIcon: Icons.menu_book_rounded,
      labelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.noteHighlightText,
        letterSpacing: 0.4,
      ),
      bodyStyle: AppTextStyles.body.copyWith(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: AppColors.noteHighlightText,
      ),
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final String label;
  final String body;
  final String? leadingAvatarUrl;
  final IconData? leadingIcon;
  final TextStyle? labelStyle;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingAvatarUrl != null) ...[
                ClipOval(
                  child: Image.network(
                    leadingAvatarUrl!,
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.pillInactive,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: labelColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: labelStyle ??
                      AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: labelColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: bodyStyle ??
                AppTextStyles.body.copyWith(fontSize: 14.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}
