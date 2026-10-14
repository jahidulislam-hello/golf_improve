import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_models.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// White rounded card titled "Journey" containing a vertical stepper
/// of [JourneyStep]s, matching the design's connected-dots timeline.
class JourneyTimelineCard extends StatelessWidget {
  const JourneyTimelineCard({
    super.key,
    required this.steps,
    this.focusStep,
  });

  final List<JourneyStep> steps;
  final JourneyStep? focusStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
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
          if (focusStep != null) ...[
            const SizedBox(height: 10),
            Text(
              focusStep!.status == JourneyStepStatus.queued
                  ? focusStep!.subtitle
                  : 'Next · ${focusStep!.title}',
              style: AppTextStyles.type14.copyWith(
                color: focusStep!.status == JourneyStepStatus.queued
                    ? AppColors.warningText
                    : AppColors.ctaBrightBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
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
    final lineReached = step.status == JourneyStepStatus.completed ||
        step.status == JourneyStepStatus.inProgress;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepIcon(step: step),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: lineReached
                        ? AppColors.primaryNavy
                        : AppColors.borderLightGray,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 8 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${step.step}. ${step.title}',
                          style: (isMuted
                                  ? AppTextStyles.type14.copyWith(
                                      color: AppColors.textSecondary,
                                    )
                                  : AppTextStyles.type14)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (step.dateLabel != null) ...[
                        const SizedBox(width: 8),
                        Text(step.dateLabel!, style: AppTextStyles.type11),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(step.subtitle, style: AppTextStyles.type13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        step.statusLabel,
                        style: AppTextStyles.type11.copyWith(
                          color: _statusColor(step.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(JourneyStepStatus status) {
    switch (status) {
      case JourneyStepStatus.completed:
        return AppColors.accentGreen;
      case JourneyStepStatus.inProgress:
        return AppColors.ctaBrightBlue;
      case JourneyStepStatus.queued:
        return AppColors.warningText;
      case JourneyStepStatus.upcoming:
        return AppColors.textSecondary;
    }
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

      case JourneyStepStatus.queued:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.warningBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: AppColors.warningText,
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
          child: const Icon(
            Icons.circle_outlined,
            color: AppColors.textSecondary,
            size: 15,
          ),
        );
    }
  }
}
