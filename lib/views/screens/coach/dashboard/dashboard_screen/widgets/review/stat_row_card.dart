import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

/// The "Driver / Face On / 0:12" three-column row directly under the
/// video card. Renders as one card with two hairline dividers, matching
/// the mock rather than three separate cards.
class SwingStatRow extends StatelessWidget {
  const SwingStatRow({
    super.key,
    required this.club,
    required this.angle,
    required this.durationLabel,
  });

  final String club;
  final String angle;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _StatColumn(value: club, label: 'Club')),
            const _VerticalDivider(),
            Expanded(child: _StatColumn(value: angle, label: 'Angle')),
            const _VerticalDivider(),
            Expanded(
              child: _StatColumn(value: durationLabel, label: 'Duration'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.borderLightGray);
  }
}
