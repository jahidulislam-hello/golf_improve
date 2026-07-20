import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/review_models.dart';



/// Card for a single pending swing review: video thumbnail with overlay
/// info, the golfer's quote, and a "Review Now" CTA. Tapping anywhere on
/// the card (or the CTA) triggers [onTap].
class PendingReviewCard extends StatelessWidget {
  const PendingReviewCard({
    super.key,
    required this.review,
    required this.onTap,
  });

  final PendingReview review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderCard),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNavy.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(review: review),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u201C${review.quote}\u201D',
                      style: AppTextStyles.quoteText,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ReviewNowButton(onTap: onTap),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.review});

  final PendingReview review;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video thumbnail image.
          Image.network(
            review.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primaryNavy,
            ),
          ),
          // Bottom scrim so the overlaid text/pills stay legible.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3060D18)],
                stops: [0.45, 1.0],
              ),
            ),
          ),
          // Centered play button.
          Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.28),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            ),
          ),
          // Top-right pills: AI Included + duration.
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                if (review.aiIncluded) ...[
                  _Pill(
                    label: 'AI Included',
                    icon: Icons.auto_awesome,
                    background: AppColors.betaBadgeBg,
                    foreground: AppColors.betaBadgeText,
                  ),
                  const SizedBox(width: 8),
                ],
                _Pill(
                  label: review.durationLabel,
                  background: Colors.black.withOpacity(0.55),
                  foreground: Colors.white,
                ),
              ],
            ),
          ),
          // Bottom-left name + subtitle.
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.golferName, style: AppTextStyles.thumbnailName),
                const SizedBox(height: 2),
                Text(review.subtitle, style: AppTextStyles.thumbnailSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.pillLabel.copyWith(color: foreground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ReviewNowButton extends StatelessWidget {
  const _ReviewNowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryNavy,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text('Review Now', style: AppTextStyles.reviewNowLabel),
        ),
      ),
    );
  }
}
