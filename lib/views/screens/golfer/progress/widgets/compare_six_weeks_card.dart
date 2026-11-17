import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_swings_screen.dart';
import 'package:golf_training_app/views/screens/golfer/progress/progress_controller.dart';
import 'section_card.dart';

class CompareSixWeeksCard extends StatelessWidget {
  const CompareSixWeeksCard({super.key, required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final recent = controller.compareRecent;
    final earlier = controller.compareEarlier;
    final pairReady = recent != null && earlier != null;
    final stats = controller.sixWeekComparison;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare with 6 Weeks Ago',
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'This week against the same week six weeks ago.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          if (stats == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            _MetricRow(label: 'Swings', metric: stats.swings),
            _MetricRow(label: 'Minutes practised', metric: stats.minutes),
            _MetricRow(label: 'Practice sessions', metric: stats.sessions),
            _MetricRow(label: 'Active days', metric: stats.activeDays),
            _HandicapRow(stats: stats),
            if (!stats.hasPreviousData) ...[
              const SizedBox(height: 12),
              Text(
                'You had no practice six weeks ago yet. Keep recording and '
                'this comparison fills in automatically.',
                style: AppTextStyles.caption.copyWith(height: 1.4),
              ),
            ],
          ],
          if (pairReady) ...[
            const SizedBox(height: 20),
            Text(
              '${recent.club} · ${recent.angleLabel}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SwingThumb(swing: earlier, caption: 'Earlier'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SwingThumb(swing: recent, caption: 'Latest'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompareSwingsScreen(
                        initialSwingAId: earlier.id,
                        initialSwingBId: recent.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaBrightBlue,
                  foregroundColor: AppColors.surfaceWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonBorderRadius,
                  ),
                ),
                child: Text(
                  'Compare Swings',
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: AppColors.surfaceWhite,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Label   previous → current   (+diff)" — higher is better.
class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.metric});

  final String label;
  final ComparisonMetric metric;

  @override
  Widget build(BuildContext context) {
    return _ComparisonLine(
      label: label,
      previous: '${metric.previous}',
      current: '${metric.current}',
      difference: metric.difference.toDouble(),
      lowerIsBetter: false,
      decimals: 0,
    );
  }
}

class _HandicapRow extends StatelessWidget {
  const _HandicapRow({required this.stats});

  final SixWeekComparison stats;

  @override
  Widget build(BuildContext context) {
    String fmt(double? v) => v == null ? '–' : v.toStringAsFixed(1);
    return _ComparisonLine(
      label: 'Handicap',
      previous: fmt(stats.handicapPrevious),
      current: fmt(stats.handicapCurrent),
      difference: stats.handicapDifference,
      lowerIsBetter: true,
      decimals: 1,
    );
  }
}

class _ComparisonLine extends StatelessWidget {
  const _ComparisonLine({
    required this.label,
    required this.previous,
    required this.current,
    required this.difference,
    required this.lowerIsBetter,
    required this.decimals,
  });

  final String label;
  final String previous;
  final String current;
  final double? difference;
  final bool lowerIsBetter;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final diff = difference;
    final improved =
        diff != null && diff != 0 && (lowerIsBetter ? diff < 0 : diff > 0);
    final color = improved
        ? AppColors.insightPositiveIcon
        : AppColors.textSecondary;
    final diffLabel = diff == null || diff == 0
        ? '='
        : '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(decimals)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
          Text(
            '$previous → $current',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              diffLabel,
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwingThumb extends StatelessWidget {
  const _SwingThumb({required this.swing, required this.caption});

  final ProgressCompareSwing swing;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final thumb = swing.thumbnailUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: AppRadii.cardBorderRadius,
            child: thumb.startsWith('http')
                ? Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ThumbFallback(),
                  )
                : const _ThumbFallback(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
        if (swing.dateLabel.isNotEmpty)
          Text(swing.dateLabel, style: AppTextStyles.caption),
      ],
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryNavy,
      child: const Center(
        child: Icon(Icons.golf_course, color: Colors.white24, size: 36),
      ),
    );
  }
}
