import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/review_models.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// Row for a single already-reviewed swing in the "Completed" section.
class CompletedReviewTile extends StatelessWidget {
  const CompletedReviewTile({super.key, required this.review, this.onTap});

  final CompletedReview review;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: AppRadii.cardBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardBorderRadius,
            border: AppRadii.cardBorder,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.successGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.golferName,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(review.subtitle, style: AppTextStyles.caption),
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
