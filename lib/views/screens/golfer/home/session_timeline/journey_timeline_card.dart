import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_models.dart';


/// White rounded card titled "Journey" containing a vertical stepper
/// of [JourneyStep]s, matching the design's connected-dots timeline.
class JourneyTimelineCard extends StatelessWidget {
  const JourneyTimelineCard({super.key, required this.steps});

  final List<JourneyStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journey', style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
          const SizedBox(height: 18),
          for (int i = 0; i < steps.length; i++)
            _JourneyRow(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({required this.step, required this.isLast});

  final JourneyStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isMuted = step.status == JourneyStepStatus.upcoming;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + connecting line column.
          Column(
            children: [
              _StepIcon(step: step),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: step.status == JourneyStepStatus.upcoming
                        ? AppColors.borderLightGray
                        : AppColors.primaryNavy,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Text content.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title,
                        style: isMuted
                            ? AppTextStyles.journeyItemTitleMuted
                            : AppTextStyles.journeyItemTitle,
                      ),
                      if (step.badgeText != null) ...[
                        const SizedBox(width: 6),
                        _BetaBadge(text: step.badgeText!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(step.subtitle, style: AppTextStyles.journeyItemSubtitle),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(step.timestamp!, style: AppTextStyles.journeyItemTimestamp),
                  ],
                  if (step.status == JourneyStepStatus.inProgress) ...[
                    const SizedBox(height: 4),
                    Text('In progress…', style: AppTextStyles.journeyInProgress),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.step});

  final JourneyStep step;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;

    switch (step.status) {
      case JourneyStepStatus.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primaryNavy,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.surfaceWhite, size: 18),
        );

      case JourneyStepStatus.inProgress:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ctaBrightBlue, width: 2),
          ),
          child: const Icon(
            Icons.remove_red_eye_outlined,
            color: AppColors.ctaBrightBlue,
            size: 16,
          ),
        );

      case JourneyStepStatus.upcoming:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.pillInactive,
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon ?? Icons.circle_outlined,
            color: AppColors.textSecondary,
            size: 15,
          ),
        );
    }
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.betaBadgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTextStyles.betaBadge),
    );
  }
}
