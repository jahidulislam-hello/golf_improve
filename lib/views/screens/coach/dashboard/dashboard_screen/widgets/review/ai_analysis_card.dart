import 'package:flutter/material.dart';
import '../../models/swing_review.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// "AI Analysis Included [BETA]" card: a tappable header row plus a list
/// of individual observation rows, each tinted red (warning) or green
/// (clean) per [AiAnalysisSeverity].
class AiAnalysisCard extends StatelessWidget {
  const AiAnalysisCard({
    super.key,
    required this.points,
    this.onTap,
  });

  final List<AiAnalysisPoint> points;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.quickActionShareBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 18,
                        color: AppColors.quickActionShareIcon,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AI Analysis Included',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const _BetaBadge(),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Student shared AI results — tap to review',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.borderLightGray),
          for (int i = 0; i < points.length; i++)
            _AiPointRow(point: points[i], showDivider: i != points.length - 1),
        ],
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _AiPointRow extends StatelessWidget {
  const _AiPointRow({required this.point, required this.showDivider});

  final AiAnalysisPoint point;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isWarning = point.severity == AiAnalysisSeverity.warning;
    final bg = isWarning ? AppColors.aiWarningBg : AppColors.quickActionLogbookBg;
    final fg = isWarning
        ? AppColors.aiWarningIcon
        : AppColors.quickActionLogbookIcon;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(point.icon, size: 15, color: fg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(point.subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: AppColors.borderLightGray),
      ],
    );
  }
}
