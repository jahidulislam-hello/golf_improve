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
    final ready = recent != null && earlier != null;

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
            ready
                ? '${recent.club} · ${recent.angleLabel}'
                : 'Same club and angle, about six weeks apart.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          if (!ready)
            Text(
              'Record two swings with the same club and angle to see them here.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _SwingThumb(
                    swing: earlier,
                    caption: 'Earlier',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SwingThumb(
                    swing: recent,
                    caption: 'Latest',
                  ),
                ),
              ],
            ),
          if (ready) ...[
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
