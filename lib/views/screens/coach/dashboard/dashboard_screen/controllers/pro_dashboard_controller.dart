import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pending_review.dart';
import '../models/dashboard_activity.dart';

/// Pro Dashboard state from GET `/meta/coach` and GET `/user/get-my-profile`.
class ProDashboardController extends ChangeNotifier {
  ProDashboardController() {
    loadDashboard();
  }

  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;

  String coachName = '';
  String? avatarUrl;
  int notificationCount = 0;

  int activeStudents = 0;
  int sessionsThisWeek = 0;
  int pendingReviewsCount = 0;

  List<PendingReview> _pendingReviews = [];
  List<DashboardActivity> _activities = [];

  List<PendingReview> get pendingReviews => List.unmodifiable(_pendingReviews);
  List<DashboardActivity> get activities => List.unmodifiable(_activities);

  Future<void> loadDashboard({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final service = await _service();
      final results = await Future.wait([
        service.getMyProfile(),
        service.getCoachHome(),
      ]);
      _applyProfile(results[0]['data']);
      final homeData = _asMap(results[1]['data']);
      if (homeData != null) {
        _applyHome(homeData);
      }
      hasLoaded = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      if (!showLoader) rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDashboard(showLoader: false);

  void openReview(String reviewId) {
    final index = _pendingReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;
    _pendingReviews[index] = _pendingReviews[index].copyWith(isUnread: false);
    notifyListeners();
  }

  void resolveReview(String reviewId) {
    _pendingReviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  void _applyProfile(dynamic rawData) {
    final data = _asMap(rawData);
    if (data == null) return;
    coachName = (data['name'] ?? '').toString();
    final profileUrl = data['profileUrl']?.toString();
    avatarUrl =
        (profileUrl != null && profileUrl.isNotEmpty) ? profileUrl : null;
  }

  void _applyHome(Map<String, dynamic> data) {
    final summary = _asMap(data['summary']);
    if (summary != null) {
      notificationCount = _asInt(summary['unreadNotificationCount']);
      activeStudents = _asInt(summary['totalStudents']);
      pendingReviewsCount = _asInt(summary['pendingReviews']);
      sessionsThisWeek = _asInt(summary['sessionsThisWeek']);
    }

    final pending = data['pendingSharedSwings'];
    if (pending is List) {
      _pendingReviews = pending
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(_pendingFromApi)
          .toList();
    } else {
      _pendingReviews = [];
    }

    final recent = data['recentActivity'];
    if (recent is List) {
      _activities = recent
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(_activityFromApi)
          .toList();
    } else {
      _activities = [];
    }
  }

  PendingReview _pendingFromApi(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final swing = _asMap(json['swingLibrary']);
    final status = (json['status'] ?? '').toString().toLowerCase();
    final viewedAt = json['viewedAt'];
    final thumbnail = _readString(swing, 'thumbnailUrl') ??
        _readString(swing, 'videoUrl') ??
        '';
    final video = _readString(swing, 'videoUrl') ?? '';

    return PendingReview(
      id: (json['_id'] ?? '').toString(),
      studentName: _readString(user, 'name') ?? '',
      club: _readString(swing, 'clubType') ?? '',
      angle: _readString(swing, 'cameraAngle') ?? '',
      timeAgo: _friendlyDate(_readString(json, 'createdAt')),
      scorePercent: _asInt(swing?['overallScore']).clamp(0, 100),
      avatarUrl: _readString(user, 'profileUrl') ?? '',
      thumbnailUrl: thumbnail,
      videoUrl: video,
      isUnread: status != 'viewed' && viewedAt == null,
    );
  }

  DashboardActivity _activityFromApi(Map<String, dynamic> json) {
    final type = (json['type'] ?? '').toString().toLowerCase();
    final title = (json['title'] ?? json['description'] ?? '').toString();
    return DashboardActivity(
      id: (json['shareId'] ?? json['_id'] ?? title).toString(),
      message: title,
      timeAgo: _friendlyDate(_readString(json, 'createdAt')),
      kind: _activityKind(type),
    );
  }

  ActivityKind _activityKind(String type) {
    if (type.contains('review')) return ActivityKind.review;
    if (type.contains('milestone')) return ActivityKind.milestone;
    return ActivityKind.upload;
  }

  Future<CoachService> _service() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiService = ApiService(sharedPreferences: sharedPreferences);
    return CoachService(apiService: apiService);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _readString(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int _asInt(dynamic raw) {
    if (raw is num) return raw.round();
    return int.tryParse('${raw ?? ''}') ?? 0;
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
    if (diff == 0) {
      final minutes = now.difference(local).inMinutes;
      if (minutes < 1) return 'Just now';
      if (minutes < 60) return '${minutes}m ago';
      final hours = minutes ~/ 60;
      return '${hours}h ago';
    }
    if (diff == 1) return 'Yesterday';
    return '${local.day}/${local.month}/${local.year}';
  }
}
