import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_swings_controller.dart';


/// Row of three speed pills ("0.25×", "0.5×", "1×"). The active pill is
/// filled with [activeColor] (navy for clip A, bright blue for clip B in
/// the reference design); inactive pills use the standard light-gray fill.
class SpeedPillGroup extends StatelessWidget {
  const SpeedPillGroup({
    super.key,
    required this.selected,
    required this.activeColor,
    required this.onChanged,
  });

  final PlaybackSpeed selected;
  final Color activeColor;
  final ValueChanged<PlaybackSpeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final speed in PlaybackSpeed.values) ...[
          _SpeedPill(
            label: speed.label,
            selected: speed == selected,
            activeColor: activeColor,
            onTap: () => onChanged(speed),
          ),
          if (speed != PlaybackSpeed.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _SpeedPill extends StatelessWidget {
  const _SpeedPill({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.pillInactive,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppTextStyles.type13.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.surfaceWhite : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
