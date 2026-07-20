import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/pending_review_card.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/reviews_controller.dart';

import 'completed_review_tile.dart';
import 'review_swing_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, this.controller});

  /// Optional injected controller (e.g. from a DI container / provider).
  /// If omitted, the screen creates and owns its own instance.
  final ReviewsController? controller;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ReviewsController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _openReviewSwing(BuildContext context, String reviewId) async {
    final review = _controller.findPendingById(reviewId);
    if (review == null) return;

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReviewSwingScreen(review: review)),
    );

    if (completed == true) {
      _controller.markReviewComplete(reviewId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _controller.fetchReviews,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(count: _controller.pendingCount)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text('PENDING', style: AppTextStyles.sectionEyebrow),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: _controller.pendingReviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final review = _controller.pendingReviews[index];
                        return PendingReviewCard(
                          review: review,
                          onTap: () => _openReviewSwing(context, review.id),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text('COMPLETED', style: AppTextStyles.sectionEyebrow),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: _controller.completedReviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return CompletedReviewTile(review: _controller.completedReviews[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reviews', style: AppTextStyles.pageTitle),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.statusInfoBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count Pending',
              style: AppTextStyles.pillLabel.copyWith(color: AppColors.ctaBrightBlue),
            ),
          ),
        ],
      ),
    );
  }
}
