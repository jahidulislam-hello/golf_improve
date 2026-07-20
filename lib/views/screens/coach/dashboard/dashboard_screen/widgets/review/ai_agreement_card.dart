import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../../models/swing_review.dart';

import 'labeled_text_area_card.dart';

/// "Respond to AI Analysis [BETA]" card: prompt text, an Agreed / Correct
/// it pair of toggle pills, and a free-text field for extra context.
class AiAgreementCard extends StatelessWidget {
  const AiAgreementCard({
    super.key,
    required this.agreement,
    required this.onChanged,
    required this.extraContextController,
  });

  final AiAgreement agreement;
  final ValueChanged<AiAgreement> onChanged;
  final TextEditingController extraContextController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 15,
                color: AppColors.quickActionShareIcon,
              ),
              const SizedBox(width: 6),
              Text('RESPOND TO AI ANALYSIS', style: AppTextStyles.inputLabel),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.betaBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'BETA',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.betaBadgeText,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Do you agree with the AI observations, or do you want to '
            'correct them?',
            style: AppTextStyles.caption.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoicePill(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Agreed',
                  isSelected: agreement == AiAgreement.agreed,
                  selectedBg: AppColors.quickActionLogbookBg,
                  selectedFg: AppColors.quickActionLogbookIcon,
                  onTap: () => onChanged(AiAgreement.agreed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoicePill(
                  icon: Icons.thumb_down_alt_outlined,
                  label: 'Correct it',
                  isSelected: agreement == AiAgreement.needsCorrection,
                  selectedBg: AppColors.pillInactive,
                  selectedFg: AppColors.textPrimary,
                  onTap: () => onChanged(AiAgreement.needsCorrection),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LabeledTextAreaCard(
            label: '',
            controller: extraContextController,
            hintText: 'Add any extra professional context...',
            minLines: 2,
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? selectedBg : AppColors.backgroundOffWhite;
    final fg = isSelected ? selectedFg : AppColors.textSecondary;
    final borderColor = isSelected ? selectedBg : AppColors.borderLightGray;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label removed above the "extra context" LabeledTextAreaCard when empty
/// looks slightly off since the label row collapses to a leading spacer.
/// Kept intentionally minimal — feel free to give it its own compact
/// no-label text-field variant if you want tighter spacing.
