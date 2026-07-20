import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_swings_controller.dart';

import 'speed_pill_group.dart';

/// "(A) Driver · Face On · Today   0.25× 0.5× 1×" row shown above each
/// clip's thumbnail.
class ClipHeaderRow extends StatelessWidget {
  const ClipHeaderRow({
    super.key,
    required this.clip,
    required this.onSpeedChanged,
  });

  final SwingClip clip;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: clip.badgeColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            clip.badgeLetter,
            style: AppTextStyles.type11.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            clip.label,
            style: AppTextStyles.type14.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        SpeedPillGroup(
          selected: clip.speed,
          activeColor: clip.badgeColor,
          onChanged: onSpeedChanged,
        ),
      ],
    );
  }
}
