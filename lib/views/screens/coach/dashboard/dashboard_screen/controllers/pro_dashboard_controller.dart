import 'package:flutter/foundation.dart';
import '../models/pending_review.dart';
import '../models/dashboard_activity.dart';

/// Holds every piece of state the Pro Dashboard screen needs:
/// header info, the 3 stat tiles, the Pending Reviews list, and the
/// Activity feed. Wire this up with Provider / ChangeNotifierProvider,
/// or just instantiate it directly in a StatefulWidget — either works.
class ProDashboardController extends ChangeNotifier {
  ProDashboardController({
    this.coachName = 'James Keller',
    this.notificationCount = 3,
  }) {
    _seedMockData();
  }

  final String coachName;
  int notificationCount;

  int activeStudents = 4;
  int sessionsThisWeek = 12;

  List<PendingReview> _pendingReviews = [];
  List<DashboardActivity> _activities = [];

  List<PendingReview> get pendingReviews => List.unmodifiable(_pendingReviews);
  List<DashboardActivity> get activities => List.unmodifiable(_activities);

  /// Count shown in the "3 Pending" stat tile — always derived from the
  /// live list rather than hardcoded, so it stays correct as reviews
  /// are opened/cleared.
  int get pendingReviewsCount => _pendingReviews.length;

  void _seedMockData() {
    _pendingReviews = [
      PendingReview(
        id: 'r1',
        studentName: 'Alex Thompson',
        club: 'Driver',
        angle: 'Face On',
        timeAgo: '2h ago',
        scorePercent: 84,
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
      ),
      PendingReview(
        id: 'r2',
        studentName: 'Sarah Chen',
        club: '7 Iron',
        angle: 'Down the Line',
        timeAgo: '5h ago',
        scorePercent: 91,
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
      ),
      PendingReview(
        id: 'r3',
        studentName: 'Mike Rodriguez',
        club: 'Wedge',
        angle: 'Side On',
        timeAgo: 'Yesterday',
        scorePercent: 72,
        avatarUrl: 'https://i.pravatar.cc/150?img=51',
      ),
    ];

    _activities = const [
      DashboardActivity(
        id: 'a1',
        message: 'Emma Park uploaded 3 swings',
        timeAgo: '1h ago',
        kind: ActivityKind.upload,
      ),
      DashboardActivity(
        id: 'a2',
        message: "You reviewed Alex's Driver session",
        timeAgo: '3h ago',
        kind: ActivityKind.review,
      ),
      DashboardActivity(
        id: 'a3',
        message: 'Mike reached 80% consistency',
        timeAgo: 'Yesterday',
        kind: ActivityKind.milestone,
      ),
    ];
  }

  /// Call this when a Pending Review card is tapped, e.g. to navigate to
  /// a review detail screen. Marks it read locally and notifies listeners
  /// so the blue unread dot disappears immediately.
  void openReview(String reviewId) {
    final index = _pendingReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;
    _pendingReviews[index] = _pendingReviews[index].copyWith(isUnread: false);
    notifyListeners();
  }

  /// Removes a review from the pending list entirely (e.g. after the
  /// coach submits feedback from a detail screen).
  void resolveReview(String reviewId) {
    _pendingReviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  Future<void> refresh() async {
    // Hook your real API/repository call here.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    notifyListeners();
  }
}
