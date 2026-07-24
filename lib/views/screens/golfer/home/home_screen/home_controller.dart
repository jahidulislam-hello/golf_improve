import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/views/base/golfer_navbar/golfer_navbar_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/share_with_coach_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/coach_feedback/coach_feedback_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/golf_logbook/golf_logbook_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_screen.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/swing_analysis_screen.dart';


/// Central controller for the Home / Dashboard screen.
///
/// Uses [ChangeNotifier] (no extra state-management package required) so the
/// screen can rebuild via [ListenableBuilder] / [AnimatedBuilder]. Owns:
///  - the hero banner [PageController] + auto-swipe [Timer]
///  - static section data (stats, active session, quick actions, activity)
///  - every tap handler referenced by the UI, so widgets stay dumb/stateless
class HomeController extends ChangeNotifier {
  HomeController() {
    _startAutoSwipe();
  }

  // ---------------------------------------------------------------------
  // Hero carousel
  // ---------------------------------------------------------------------

  final PageController heroPageController = PageController();
  Timer? _autoSwipeTimer;
  static const Duration autoSwipeInterval = Duration(seconds: 4);
  static const Duration autoSwipeAnimationDuration = Duration(milliseconds: 450);

  int _currentHeroIndex = 0;
  int get currentHeroIndex => _currentHeroIndex;

  final List<HeroBannerModel> heroBanners = const [
    HeroBannerModel(
      imageAsset: 'assets/images/golf_01.png',
      eyebrow: 'READY TO IMPROVE',
      title: 'Train smarter.\nPlay better.',
      ctaLabel: 'Start Recording',
    ),
    HeroBannerModel(
      imageAsset: 'assets/images/golf_02.png',
      eyebrow: 'AI POWERED',
      title: 'Analyze every\nswing instantly.',
      ctaLabel: 'Start Recording',
    ),
    HeroBannerModel(
      imageAsset: 'assets/images/golf_03.png',
      eyebrow: 'STAY ON TRACK',
      title: 'Get feedback\nfrom your coach.',
      ctaLabel: 'Start Recording',
    ),
  ];

  void _startAutoSwipe() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer.periodic(autoSwipeInterval, (_) {
      if (!heroPageController.hasClients || heroBanners.length <= 1) return;
      final nextIndex = (_currentHeroIndex + 1) % heroBanners.length;
      heroPageController.animateToPage(
        nextIndex,
        duration: autoSwipeAnimationDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  /// Call from PageView.onPageChanged.
  void onHeroPageChanged(int index) {
    _currentHeroIndex = index;
    notifyListeners();
  }

  /// Pause auto-swipe while the user is actively dragging the carousel,
  /// resume shortly after they let go.
  void onHeroDragStart() => _autoSwipeTimer?.cancel();
  void onHeroDragEnd() => _startAutoSwipe();

  // ---------------------------------------------------------------------
  // Stat chips
  // ---------------------------------------------------------------------

  final List<StatModel> stats = const [
    StatModel(value: '12.4', label: 'Handicap'),
    StatModel(value: '847', label: 'Swings'),
    StatModel(value: '23', label: 'This Week'),
  ];

  // ---------------------------------------------------------------------
  // Active session
  // ---------------------------------------------------------------------

  final ActiveSessionModel activeSession = const ActiveSessionModel(
    thumbnailAsset: 'assets/images/session_driver_face_on.jpg',
    title: 'Driver · Face On',
    statusLabel: 'Coach Reviewing',
  );

  // ---------------------------------------------------------------------
  // Coach feedback banner
  // ---------------------------------------------------------------------

  CoachFeedbackModel _coachFeedback = const CoachFeedbackModel(
    title: 'New Coach Feedback',
    subtitle: 'James Keller reviewed your 7 Iron session',
    isUnread: true,
  );
  CoachFeedbackModel get coachFeedback => _coachFeedback;

  // ---------------------------------------------------------------------
  // Quick actions
  // ---------------------------------------------------------------------

  final List<QuickActionModel> quickActions = const [
    QuickActionModel(
      type: QuickActionType.aiAnalysis,
      icon: Icons.psychology_alt_outlined,
      title: 'AI Analysis',
      subtitle: 'Review your swing',
      backgroundColor: AppColors.quickActionAiBg,
      iconColor: AppColors.quickActionAiIcon,
    ),
    QuickActionModel(
      type: QuickActionType.logbook,
      icon: Icons.menu_book_outlined,
      title: 'Logbook',
      subtitle: 'Tips & reminders',
      backgroundColor: AppColors.quickActionLogbookBg,
      iconColor: AppColors.quickActionLogbookIcon,
    ),
    QuickActionModel(
      type: QuickActionType.shareWithCoach,
      icon: Icons.share_outlined,
      title: 'Share with Coach',
      subtitle: 'Send for review',
      backgroundColor: AppColors.quickActionShareBg,
      iconColor: AppColors.quickActionShareIcon,
    ),
    QuickActionModel(
      type: QuickActionType.library,
      icon: Icons.video_library_outlined,
      title: 'Library',
      subtitle: 'All your swings',
      backgroundColor: AppColors.quickActionLibraryBg,
      iconColor: AppColors.quickActionLibraryIcon,
    ),
  ];

  // ---------------------------------------------------------------------
  // Recent activity
  // ---------------------------------------------------------------------

  final List<RecentActivityModel> recentActivities = const [
    RecentActivityModel(
      thumbnailAsset: 'assets/images/activity_driver.jpg',
      title: 'Driver · Face On',
      subtitle: 'Today, 9:14 AM',
      scorePercent: 84,
    ),
    RecentActivityModel(
      thumbnailAsset: 'assets/images/activity_7iron.jpg',
      title: '7 Iron · Down the Line',
      subtitle: 'Yesterday, 4:30 PM',
      scorePercent: 91,
    ),
    RecentActivityModel(
      thumbnailAsset: 'assets/images/activity_sandwedge.jpg',
      title: 'Sand Wedge · Side On',
      subtitle: 'Mon, 11:00 AM',
      scorePercent: 76,
    ),
  ];

  // ---------------------------------------------------------------------
  // Tap handlers — every interactive element in the UI routes through here
  // so navigation / analytics / API calls can be wired up in one place.
  // ---------------------------------------------------------------------

  void onNotificationTap(BuildContext context) {
    _toast(context, 'Opening notifications');
  }

  void onProfileTap(BuildContext context) {
    _toast(context, 'Opening profile');
  }

  void onStartRecordingTap(BuildContext context) {
    _toast(context, 'Starting a new recording…');
  }

  void onActiveSessionTap(BuildContext context) {
    _openSessionTimeline(context);
  }

  void onViewTimelineTap(BuildContext context) {
    _openSessionTimeline(context);
  }

  void onCoachFeedbackTap(BuildContext context) {
    // Mark as read on open.
    _coachFeedback = CoachFeedbackModel(
      title: _coachFeedback.title,
      subtitle: _coachFeedback.subtitle,
      isUnread: false,
    );
    notifyListeners();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()),
    );
  }

  void _openSessionTimeline(BuildContext context) {
    final timelineController = SessionTimelineController();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SessionTimelineScreen(controller: timelineController),
          ),
        )
        .then((_) => timelineController.dispose());
  }

  void onQuickActionTap(BuildContext context, QuickActionModel action) {
    switch (action.type) {
      case QuickActionType.aiAnalysis:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SwingAnalysisScreen()),
        );
        break;
      case QuickActionType.logbook:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GolfLogbookScreen()),
        );
        break;
      case QuickActionType.shareWithCoach:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShareWithCoachScreen()),
        );
        break;
      case QuickActionType.library:
        _openLibraryTab();
        break;
    }
  }

  void _openLibraryTab() {
    if (Get.isRegistered<GolferNavbarController>()) {
      Get.find<GolferNavbarController>().changeIndex(1);
    }
  }

  void onSeeAllActivityTap(BuildContext context) {
    _toast(context, 'Opening full activity history');
  }

  void onActivityItemTap(BuildContext context, RecentActivityModel item) {
    _toast(context, 'Opening "${item.title}"');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryNavy,
        ),
      );
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    heroPageController.dispose();
    super.dispose();
  }
}