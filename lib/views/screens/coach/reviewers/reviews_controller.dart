import 'package:flutter/foundation.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/review_models.dart';


/// Controls the state behind the Reviews screen: the pending queue,
/// the completed history, loading/error state, and the actions that
/// mutate them (e.g. marking a review complete after the coach submits
/// feedback on the Review Swing screen).
///
/// Plain [ChangeNotifier] so it works with `ListenableBuilder`,
/// `provider`, `get_it`, or any state-management approach the app uses —
/// no extra package dependency required.
class ReviewsController extends ChangeNotifier {
  ReviewsController({List<PendingReview>? pending, List<CompletedReview>? completed}) {
    _pendingReviews = pending ?? _seedPending();
    _completedReviews = completed ?? _seedCompleted();
  }

  late List<PendingReview> _pendingReviews;
  late List<CompletedReview> _completedReviews;

  bool _isLoading = false;
  String? _errorMessage;

  List<PendingReview> get pendingReviews => List.unmodifiable(_pendingReviews);
  List<CompletedReview> get completedReviews => List.unmodifiable(_completedReviews);

  int get pendingCount => _pendingReviews.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Call from a RefreshIndicator or on screen init to (re)load reviews
  /// from your backend. Replace the TODO with a real API/repository call.
  Future<void> fetchReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: replace with a real repository/API call, e.g.:
      // final result = await reviewsRepository.fetchReviews();
      // _pendingReviews = result.pending;
      // _completedReviews = result.completed;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _errorMessage = 'Could not load reviews. Pull to refresh to try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Moves a review from Pending to Completed — call this after the coach
  /// submits feedback on the Review Swing screen.
  void markReviewComplete(String reviewId) {
    final index = _pendingReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;

    final review = _pendingReviews[index];
    _pendingReviews = List.of(_pendingReviews)..removeAt(index);
    _completedReviews = [
      CompletedReview(
        id: review.id,
        golferName: review.golferName,
        club: review.club,
        angle: review.angle,
        completedAt: DateTime.now(),
      ),
      ..._completedReviews,
    ];
    notifyListeners();
  }

  PendingReview? findPendingById(String id) {
    for (final r in _pendingReviews) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<PendingReview> _seedPending() => const [
        PendingReview(
          id: 'r1',
          golferName: 'Alex Thompson',
          club: 'Driver',
          angle: 'Face On',
          thumbnailUrl: 'https://example.com/thumbnails/alex_driver.jpg',
          videoUrl: 'https://example.com/videos/alex_driver.mp4',
          duration: Duration(seconds: 12),
          quote: 'My downswing path feels off — can you check my transition?',
          aiIncluded: true,
        ),
        PendingReview(
          id: 'r2',
          golferName: 'Sarah Chen',
          club: '7 Iron',
          angle: 'Down the Line',
          thumbnailUrl: 'https://example.com/thumbnails/sarah_iron.jpg',
          videoUrl: 'https://example.com/videos/sarah_iron.mp4',
          duration: Duration(seconds: 9),
          quote: 'Does my hip rotation look better than last week?',
        ),
        PendingReview(
          id: 'r3',
          golferName: 'Mike Rodriguez',
          club: 'Wedge',
          angle: 'Side On',
          thumbnailUrl: 'https://example.com/thumbnails/mike_wedge.jpg',
          videoUrl: 'https://example.com/videos/mike_wedge.mp4',
          duration: Duration(seconds: 15),
          quote: 'What am I doing wrong with the follow-through?',
          aiIncluded: true,
        ),
      ];

  List<CompletedReview> _seedCompleted() => [
        CompletedReview(
          id: 'c1',
          golferName: 'Emma Park',
          club: 'Driver',
          angle: 'Face On',
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        CompletedReview(
          id: 'c2',
          golferName: 'Alex Thompson',
          club: 'Iron',
          angle: 'Down the Line',
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
}
