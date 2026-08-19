import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/views/base/golfer_navbar/golfer_navbar_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/share_with_coach_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/coach_feedback/coach_feedback_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/golf_logbook/golf_logbook_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_screen.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/swing_analysis_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
    _bootstrap();
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

  List<StatModel> stats = const [];

  // ---------------------------------------------------------------------
  // Active session
  // ---------------------------------------------------------------------

  ActiveSessionModel? activeSession;

  // ---------------------------------------------------------------------
  // Profile header data (filled from GET /user/get-my-profile)
  // ---------------------------------------------------------------------
  String userName = '';
  String avatarInitials = '';
  bool hasUnreadNotifications = false;

  // ---------------------------------------------------------------------
  // API state
  // ---------------------------------------------------------------------
  bool isLoading = false;
  String? errorMessage;

  Future<void> _bootstrap() async {
    isLoading = true;
    notifyListeners();

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final apiService = ApiService(sharedPreferences: sharedPreferences);
      final golferService = GolferService(apiService: apiService);

      final profileResponse = await golferService.getMyProfile();
      final profileData = _asMap(profileResponse['data']);
      if (profileData != null) {
        final name = _readString(profileData, 'name');
        if (name != null && name.isNotEmpty) {
          userName = name;
          avatarInitials = _buildInitials(name);
        }
      }

      final homeResponse = await golferService.getHomeSummary();
      final homeData = _asMap(homeResponse['data']);
      if (homeData != null) {
        _applyHomeData(homeData);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyHomeData(Map<String, dynamic> data) {
    final summary = _asMap(data['summary']);
    if (summary != null) {
      stats = [
        StatModel(
          value: '${summary['totalSessions'] ?? 0}',
          label: 'Total Sessions',
        ),
        StatModel(
          value: '${summary['swingsThisWeek'] ?? 0}',
          label: 'Swings This Week',
        ),
        StatModel(
          value: '${summary['totalAiAnalyses'] ?? 0}',
          label: 'AI Analyses',
        ),
      ];
    }

    final active = _asMap(data['activeSession']);
    if (active != null) {
      activeSession = ActiveSessionModel(
        thumbnailUrl: _readString(active, 'videoUrl') ?? '',
        title:
            '${_readString(active, 'clubType') ?? 'All Clubs'} · ${_readString(active, 'cameraAngle') ?? 'All Angles'}',
        statusLabel: _readString(active, 'status') ?? 'In Progress',
        payload: active,
      );
    } else {
      activeSession = null;
    }

    final quickActionData = _asMap(data['quickAction']);
    if (quickActionData != null) {
      quickActions = [
        QuickActionModel(
          type: QuickActionType.aiAnalysis,
          icon: Icons.psychology_alt_outlined,
          title: 'AI Analysis',
          subtitle: 'Review your swing',
          backgroundColor: AppColors.quickActionAiBg,
          iconColor: AppColors.quickActionAiIcon,
          payload: _asMap(quickActionData['aiAnalysis']),
        ),
        QuickActionModel(
          type: QuickActionType.logbook,
          icon: Icons.menu_book_outlined,
          title: 'Logbook',
          subtitle: 'Tips & reminders',
          backgroundColor: AppColors.quickActionLogbookBg,
          iconColor: AppColors.quickActionLogbookIcon,
          payload: _asMap(quickActionData['logbook']),
        ),
        QuickActionModel(
          type: QuickActionType.shareWithCoach,
          icon: Icons.share_outlined,
          title: 'Share with Coach',
          subtitle: 'Send for review',
          backgroundColor: AppColors.quickActionShareBg,
          iconColor: AppColors.quickActionShareIcon,
          payload: _asMap(quickActionData['shareSwing']),
        ),
        const QuickActionModel(
          type: QuickActionType.library,
          icon: Icons.video_library_outlined,
          title: 'Library',
          subtitle: 'All your swings',
          backgroundColor: AppColors.quickActionLibraryBg,
          iconColor: AppColors.quickActionLibraryIcon,
        ),
      ];
    }

    final recent = data['recentActivities'];
    if (recent is List) {
      recentActivities = recent
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(
            (activity) => RecentActivityModel(
              thumbnailUrl: _readString(activity, 'thumbnailUrl') ??
                  _readString(activity, 'videoUrl') ??
                  '',
              title:
                  '${_readString(activity, 'clubType') ?? 'All Clubs'} · ${_readString(activity, 'cameraAngle') ?? 'All Angles'}',
              subtitle: _friendlyDate(_readString(activity, 'createdAt')),
              scorePercent:
                  (_asNum(activity['overallScore'])?.round() ?? 0).clamp(0, 100),
              payload: activity,
            ),
          )
          .toList();
    } else {
      recentActivities = const [];
    }

    final feedback = _asMap(data['coachFeedback']);
    if (feedback != null) {
      hasCoachFeedback = true;
      _coachFeedback = CoachFeedbackModel(
        title: 'New Coach Feedback',
        subtitle: _readString(feedback, 'message') ??
            _readString(feedback, 'note') ??
            _readString(feedback, 'title') ??
            'Coach sent feedback on your session',
        isUnread: true,
      );
      hasUnreadNotifications = true;
    } else {
      hasCoachFeedback = false;
      hasUnreadNotifications = false;
    }
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  num? _asNum(dynamic raw) {
    if (raw is num) return raw;
    return num.tryParse('${raw ?? ''}');
  }

  String _friendlyDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final now = DateTime.now();
    final local = parsed.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${local.day}/${local.month}/${local.year}';
  }

  String _buildInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ---------------------------------------------------------------------
  // Coach feedback banner
  // ---------------------------------------------------------------------

  bool hasCoachFeedback = false;
  CoachFeedbackModel _coachFeedback = const CoachFeedbackModel(
    title: 'New Coach Feedback',
    subtitle: '',
    isUnread: true,
  );
  CoachFeedbackModel get coachFeedback => _coachFeedback;

  // ---------------------------------------------------------------------
  // Quick actions
  // ---------------------------------------------------------------------

  List<QuickActionModel> quickActions = const [];

  // ---------------------------------------------------------------------
  // Recent activity
  // ---------------------------------------------------------------------

  List<RecentActivityModel> recentActivities = const [];

  // ---------------------------------------------------------------------
  // Tap handlers — every interactive element in the UI routes through here
  // so navigation / analytics / API calls can be wired up in one place.
  // ---------------------------------------------------------------------

  void onNotificationTap(BuildContext context) {
    _toast(context, 'Opening notifications');
  }

  void onProfileTap(BuildContext context) {
    if (Get.isRegistered<GolferNavbarController>()) {
      Get.find<GolferNavbarController>().changeIndex(4);
    }
  }

  void onStartRecordingTap(BuildContext context) {
    _toast(context, 'Starting a new recording…');
  }

  void onActiveSessionTap(BuildContext context) {
    if (activeSession == null) return;
    _openSessionTimeline(context);
  }

  void onViewTimelineTap(BuildContext context) {
    if (activeSession == null) return;
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
          MaterialPageRoute(
            builder: (_) => SwingAnalysisScreen(
              initialData: action.payload,
            ),
          ),
        );
        break;
      case QuickActionType.logbook:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GolfLogbookScreen()),
        );
        break;
      case QuickActionType.shareWithCoach:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShareWithCoachScreen(
              initialData: action.payload,
            ),
          ),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SwingAnalysisScreen(
          initialData: item.payload,
        ),
      ),
    );
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