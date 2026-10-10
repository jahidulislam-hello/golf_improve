import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/home_controller.dart';

import '../widgets/active_session_card.dart';
import '../widgets/coach_feedback_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_activity_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Pixel-mapped recreation of the dashboard mock: greeting header, an
/// auto-swiping hero carousel, stat chips, an active session card, a coach
/// feedback banner, a 2x2 quick-action grid, and a recent activity list.
///
/// All state and interaction logic lives in [HomeController]; this widget
/// only lays things out and wires callbacks.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: DashboardHeader(
                      greeting: 'Good morning',
                      userName: _controller.userName,
                      avatarInitials: _controller.avatarInitials,
                      hasUnreadNotifications: _controller.hasUnreadNotifications,
                      onNotificationTap: () =>
                          _controller.onNotificationTap(context),
                      onProfileTap: () => _controller.onProfileTap(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20),
                  sliver: SliverToBoxAdapter(
                    child: HeroCarousel(
                      banners: _controller.heroBanners,
                      currentIndex: _controller.currentHeroIndex,
                      pageController: _controller.heroPageController,
                      onPageChanged: _controller.onHeroPageChanged,
                      onCtaTap: () => _controller.onStartRecordingTap(context),
                      onDragStart: _controller.onHeroDragStart,
                      onDragEnd: _controller.onHeroDragEnd,
                    ),
                  ),
                ),
                if (_controller.stats.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: StatCardRow(stats: _controller.stats),
                    ),
                  ),
                if (_controller.activeSession != null ||
                    _controller.hasCoachFeedback)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_controller.activeSession != null) ...[
                            SectionHeader(
                              title: 'Active Session',
                              actionLabel: 'View Timeline',
                              onActionTap: () =>
                                  _controller.onViewTimelineTap(context),
                            ),
                            const SizedBox(height: 12),
                            ActiveSessionCard(
                              session: _controller.activeSession!,
                              onTap: () =>
                                  _controller.onActiveSessionTap(context),
                            ),
                          ],
                          if (_controller.hasCoachFeedback) ...[
                            if (_controller.activeSession != null)
                              const SizedBox(height: 12),
                            CoachFeedbackCard(
                              feedback: _controller.coachFeedback,
                              onTap: () =>
                                  _controller.onCoachFeedbackTap(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (_controller.quickActions.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Quick Actions'),
                          const SizedBox(height: 12),
                          QuickActionGrid(
                            actions: _controller.quickActions,
                            onActionTap: (action) =>
                                _controller.onQuickActionTap(context, action),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_controller.recentActivities.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Recent Activity',
                            actionLabel: 'See All',
                            onActionTap: () =>
                                _controller.onSeeAllActivityTap(context),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: AppRadii.cardBorderRadius,
                            border: AppRadii.cardBorder,
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: List.generate(
                              _controller.recentActivities.length,
                              (index) {
                                final activity =
                                    _controller.recentActivities[index];
                                final isLast =
                                    index ==
                                    _controller.recentActivities.length - 1;
                                return RecentActivityTile(
                                  activity: activity,
                                  showDivider: !isLast,
                                  onTap: () => _controller.onActivityItemTap(
                                    context,
                                    activity,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}