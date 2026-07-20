import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../controllers/pro_dashboard_controller.dart';
import '../models/pending_review.dart';
import '../widgets/activity_tile.dart';
import '../widgets/pending_review_card.dart';
import '../widgets/stat_card.dart';

/// Pixel-matched recreation of the "Pro Dashboard" screen:
/// header (name + notification bell + avatar), 3 stat tiles,
/// a Pending Reviews list (fully touchable cards), and an Activity feed.
class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key, this.controller});

  final ProDashboardController? controller;

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen> {
  late final ProDashboardController _controller =
      widget.controller ?? ProDashboardController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onReviewTap(PendingReview review) {
    _controller.openReview(review.id);

    // Hook your navigation to a review-detail screen here, e.g.:
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (_) => ReviewDetailScreen(reviewId: review.id),
    // ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening review for ${review.studentName}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Header(controller: _controller),
              const SizedBox(height: 24),
              _StatsRow(controller: _controller),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Pending Reviews',
                trailing: '${_controller.pendingReviewsCount} New',
              ),
              const SizedBox(height: 12),
              ..._controller.pendingReviews.map(
                (review) => PendingReviewCard(
                  review: review,
                  onTap: () => _onReviewTap(review),
                ),
              ),
              const SizedBox(height: 16),
              Text('Activity', style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderCard),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _controller.activities.length; i++)
                      ActivityTile(
                        activity: _controller.activities[i],
                        showDivider: i != _controller.activities.length - 1,
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

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ProDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final initials = controller.coachName
        .trim()
        .split(RegExp(r'\s+'))
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pro Dashboard', style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                controller.coachName,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
              ),
            ],
          ),
        ),
        _NotificationBell(count: controller.notificationCount),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryNavy,
          child: Text(
            initials,
            style: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLightGray),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                color: AppColors.notificationBadgeRed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surfaceWhite,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});

  final ProDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${controller.activeStudents}',
            label: 'Students',
            sublabel: 'active',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            value: '${controller.pendingReviewsCount}',
            label: 'Pending',
            sublabel: 'reviews',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            value: '${controller.sessionsThisWeek}',
            label: 'Sessions',
            sublabel: 'this week',
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionHeader.copyWith(fontSize: 18)),
        Text(trailing, style: AppTextStyles.linkText.copyWith(fontSize: 13)),
      ],
    );
  }
}
