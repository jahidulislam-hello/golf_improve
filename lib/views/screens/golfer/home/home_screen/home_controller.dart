import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/utils/api_constants.dart';
import 'package:golf_training_app/views/base/golfer_navbar/golfer_navbar_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/share_with_coach_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/coach_feedback/coach_feedback_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_swings_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/golf_logbook/golf_logbook_screen.dart';
import 'package:golf_training_app/views/screens/golfer/home/home_screen/model.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_screen.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/ai_golf_coach_screen.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/swing_analysis_screen.dart';
import 'package:golf_training_app/views/screens/golfer/profile/notification/notification_screen.dart';
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

  bool _isDisposed = false;

  // ---------------------------------------------------------------------
  // Hero carousel
  // ---------------------------------------------------------------------

  final PageController heroPageController = PageController();
  Timer? _autoSwipeTimer;
  static const Duration autoSwipeInterval = Duration(seconds: 4);
  static const Duration autoSwipeAnimationDuration = Duration(
    milliseconds: 450,
  );

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
      // Replaced AI-looking golf_03 (club across shoulders) for launch.
      imageAsset: 'assets/images/golf_02.png',
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
    _notifySafely();
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

  static const String _cacheKey = ApiConstants.keyHomeCache;
  bool hasLoaded = false;
  bool _isRefreshing = false;

  /// Cache-first load: paint the last known Home instantly, then refresh from
  /// the API in the background. Offline uploads/shares are flushed afterwards
  /// so they never delay the first paint.
  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isDisposed) return;
    _restoreCache(prefs);
    await refresh(prefs: prefs);
    if (_isDisposed) return;
    unawaited(_flushOfflineWork(prefs));
  }

  /// Reloads Home data. Shows the loader only when nothing is on screen yet.
  Future<void> refresh({SharedPreferences? prefs}) async {
    if (_isRefreshing || _isDisposed) return;
    _isRefreshing = true;
    isLoading = !hasLoaded;
    _notifySafely();

    try {
      final sharedPreferences = prefs ?? await SharedPreferences.getInstance();
      final golferService = GolferService(
        apiService: ApiService(sharedPreferences: sharedPreferences),
      );

      // Profile and home summary are independent — fetch them together.
      final results = await Future.wait([
        golferService.getMyProfile(),
        golferService.getHomeSummary(),
      ]);
      if (_isDisposed) return;

      final profileData = _asMap(results[0]['data']);
      final homeData = _asMap(results[1]['data']);
      _applyProfile(profileData);
      if (homeData != null) _applyHomeData(homeData);
      unawaited(_refreshUnreadCount(golferService));
      hasLoaded = true;
      errorMessage = null;

      await sharedPreferences.setString(
        _cacheKey,
        jsonEncode({'name': userName, 'home': homeData}),
      );
    } catch (e) {
      if (_isDisposed) return;
      // Keep showing cached data; only surface the error on an empty screen.
      if (!hasLoaded) {
        errorMessage = e is ApiError ? e.message : e.toString();
      }
    } finally {
      _isRefreshing = false;
      if (!_isDisposed) {
        isLoading = false;
        _notifySafely();
      }
    }
  }

  Future<void> _flushOfflineWork(SharedPreferences prefs) async {
    try {
      final golferService = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      await golferService.syncPendingSwings();
      await golferService.flushQueuedShares();
    } catch (_) {}
  }

  void _applyProfile(Map<String, dynamic>? profileData) {
    if (profileData == null) return;
    final name = _readString(profileData, 'name');
    if (name != null && name.isNotEmpty) {
      userName = name;
      avatarInitials = _buildInitials(name);
    }
  }

  void _restoreCache(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final cached = _asMap(jsonDecode(raw));
      if (cached == null) return;
      final name = cached['name'];
      if (name is String && name.isNotEmpty) {
        userName = name;
        avatarInitials = _buildInitials(name);
      }
      final home = _asMap(cached['home']);
      if (home != null) {
        _applyHomeData(home);
        hasLoaded = true;
      }
      _notifySafely();
    } catch (_) {}
  }

  /// Time-of-day greeting for the header.
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  String? _consistencyLabel(dynamic raw) {
    final consistency = _asMap(raw);
    if (consistency == null) return null;
    final percentage = consistency['percentage'];
    if (percentage is num) return '${percentage.round()}%';
    final ratio = consistency['ratio'];
    if (ratio is num) return '${(ratio * 100).round()}%';
    return null;
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
          value:
              _consistencyLabel(summary['consistency']) ??
              '${summary['totalAiAnalyses'] ?? 0}',
          label: summary['consistency'] is Map ? 'Consistency' : 'AI Analyses',
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

    // Always available, even when the server sends no quick-action payloads.
    final quickActionData = _asMap(data['quickAction']) ?? const {};
    quickActions = [
      const QuickActionModel(
        type: QuickActionType.aiCoach,
        icon: Icons.psychology_alt_outlined,
        title: 'AI Coach',
        subtitle: 'Ask anything',
        backgroundColor: AppColors.quickActionAiBg,
        iconColor: AppColors.quickActionAiIcon,
      ),
      QuickActionModel(
        type: QuickActionType.compareSwing,
        icon: Icons.compare_arrows_rounded,
        title: 'Compare',
        subtitle: 'Side by Side View',
        backgroundColor: AppColors.quickActionLibraryBg,
        iconColor: AppColors.quickActionLibraryIcon,
        payload: _asMap(quickActionData['compareSwing']),
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
    ];

    final recent = data['recentActivities'];
    if (recent is List) {
      recentActivities = recent
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(
            (activity) => RecentActivityModel(
              thumbnailUrl:
                  _readString(activity, 'thumbnailUrl') ??
                  _readString(activity, 'videoUrl') ??
                  '',
              title:
                  '${_readString(activity, 'clubType') ?? 'All Clubs'} · ${_readString(activity, 'cameraAngle') ?? 'All Angles'}',
              subtitle: _friendlyDate(_readString(activity, 'createdAt')),
              scorePercent: (_asNum(activity['overallScore'])?.round() ?? 0)
                  .clamp(0, 100),
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
        subtitle:
            _readString(feedback, 'message') ??
            _readString(feedback, 'note') ??
            _readString(feedback, 'title') ??
            'Coach sent feedback on your session',
        isUnread: true,
        shareId: _readId(feedback, const [
          'shareId',
          'share_id',
          'shareSwingId',
          '_id',
          'id',
        ]),
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

  String? _readId(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final nested = value['_id'] ?? value['id'];
        final text = nested?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
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

  Future<void> onNotificationTap(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
    if (_isDisposed) return;
    // Everything was seen in the inbox — clear the badge.
    final hadUnread = hasUnreadNotifications;
    hasUnreadNotifications = false;
    _notifySafely();
    if (!hadUnread) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      ).markAllNotificationsRead();
    } catch (_) {}
  }

  Future<void> _refreshUnreadCount(GolferService service) async {
    try {
      final count = await service.getUnreadNotificationCount();
      if (_isDisposed) return;
      hasUnreadNotifications = count > 0;
      _notifySafely();
    } catch (_) {}
  }

  void onProfileTap(BuildContext context) {
    if (Get.isRegistered<GolferNavbarController>()) {
      Get.find<GolferNavbarController>().changeIndex(4);
    }
  }

  void onStartRecordingTap(BuildContext context) {
    _openTab(GolferNavbarController.recordTab);
  }

  void _openTab(int index) {
    if (Get.isRegistered<GolferNavbarController>()) {
      Get.find<GolferNavbarController>().changeIndex(index);
    }
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
      shareId: _coachFeedback.shareId,
    );
    _notifySafely();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachFeedbackScreen(shareId: _coachFeedback.shareId),
      ),
    );
  }

  void _openSessionTimeline(BuildContext context) {
    final payload = activeSession?.payload;
    final timelineController = SessionTimelineController(
      shareId: _readId(payload, const ['shareId', 'share_id', 'shareSwingId']),
      analysisId: _readId(payload, const [
        'analysisId',
        'swingLibraryId',
        'swingLibrary',
        'libraryId',
        '_id',
        'id',
      ]),
      thumbnailUrl: activeSession?.thumbnailUrl ?? '',
      sessionLabel: activeSession?.title ?? '',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                SessionTimelineScreen(controller: timelineController),
          ),
        )
        .then((_) => timelineController.dispose());
  }

  void onQuickActionTap(BuildContext context, QuickActionModel action) {
    switch (action.type) {
      case QuickActionType.aiAnalysis:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SwingAnalysisScreen(initialData: action.payload),
          ),
        );
        break;
      case QuickActionType.compareSwing:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CompareSwingsScreen()));
        break;
      case QuickActionType.logbook:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GolfLogbookScreen()));
        break;
      case QuickActionType.shareWithCoach:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShareWithCoachScreen(initialData: action.payload),
          ),
        );
        break;
      case QuickActionType.library:
        _openTab(GolferNavbarController.libraryTab);
        break;
      case QuickActionType.aiCoach:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiGolfCoachScreen()),
        );
        break;
    }
  }

  void onSeeAllActivityTap(BuildContext context) {
    _openTab(GolferNavbarController.libraryTab);
  }

  void onActivityItemTap(BuildContext context, RecentActivityModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SwingAnalysisScreen(initialData: item.payload),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSwipeTimer?.cancel();
    heroPageController.dispose();
    super.dispose();
  }
}
