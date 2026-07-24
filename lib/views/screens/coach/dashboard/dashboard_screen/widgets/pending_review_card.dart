import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../models/pending_review.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// A single row in the "Pending Reviews" list. Fully tappable — wraps
/// the whole row (avatar, text, score, Review pill) in an InkWell so
/// tapping anywhere on the card fires [onTap], while the "Review"
/// pill itself has its own tap target via [onReviewPressed].
class PendingReviewCard extends StatelessWidget {
  const PendingReviewCard({
    super.key,
    required this.review,
    required this.onTap,
    this.onReviewPressed,
  });

  final PendingReview review;
  final VoidCallback onTap;
  final VoidCallback? onReviewPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.ctaBrightBlue.withOpacity(0.08),
          highlightColor: AppColors.ctaBrightBlue.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: review.avatarUrl, unread: review.isUnread),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.studentName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(review.subtitle, style: AppTextStyles.caption),
                      const SizedBox(height: 3),
                      Text(review.timeAgo, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${review.scorePercent}%',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ReviewPill(
                      onPressed: onReviewPressed ?? onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.unread});

  final String url;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: AppRadii.cardBorderRadius,
          child: Image.network(
            url,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              color: AppColors.pillInactive,
              child: const Icon(Icons.person, color: AppColors.textSecondary),
            ),
          ),
        ),
        if (unread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.ctaBrightBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceWhite, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.statusInfoBg,
      borderRadius: AppRadii.cardBorderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.cardBorderRadius,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            'Review',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ctaBrightBlue,
            ),
          ),
        ),
      ),
    );
  }
}
