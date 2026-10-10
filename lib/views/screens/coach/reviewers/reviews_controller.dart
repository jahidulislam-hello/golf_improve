import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/coach_service.dart';
import 'package:golf_training_app/views/screens/coach/reviewers/review_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsController extends ChangeNotifier {
  ReviewsController() {
    fetchReviews();
  }

  List<PendingReview> _pendingReviews = [];
  List<CompletedReview> _completedReviews = [];

  bool _isLoading = true;
  bool hasLoaded = false;
  String? _errorMessage;

  List<PendingReview> get pendingReviews => List.unmodifiable(_pendingReviews);
  List<CompletedReview> get completedReviews =>
      List.unmodifiable(_completedReviews);

  int get pendingCount => _pendingReviews.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final service = CoachService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final results = await Future.wait([
        service.getReceivedShares(status: 'pending'),
        service.getReceivedShares(status: 'responded'),
      ]);
      _pendingReviews = _parsePending(results[0]['data']);
      _completedReviews = _parseCompleted(results[1]['data']);
      hasLoaded = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      if (!showLoader) rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  CompletedReview? findCompletedById(String id) {
    for (final r in _completedReviews) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<PendingReview> _parsePending(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(_pendingFromApi)
        .toList();
  }

  List<CompletedReview> _parseCompleted(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(_completedFromApi)
        .toList();
  }

  PendingReview _pendingFromApi(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final swing = _asMap(json['swingLibrary']);
    final seconds = _asInt(swing?['duration']);
    return PendingReview(
      id: '${json['_id'] ?? ''}',
      golferName: '${user?['name'] ?? ''}',
      avatarUrl: '${user?['profileUrl'] ?? ''}',
      club: '${swing?['clubType'] ?? ''}',
      angle: '${swing?['cameraAngle'] ?? ''}',
      thumbnailUrl: '${swing?['thumbnailUrl'] ?? swing?['videoUrl'] ?? ''}',
      videoUrl: '${swing?['videoUrl'] ?? ''}',
      duration: Duration(seconds: seconds),
      quote: '${json['message'] ?? ''}',
      aiIncluded: json['isAiAnalysis'] == true,
    );
  }

  CompletedReview _completedFromApi(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final swing = _asMap(json['swingLibrary']);
    final seconds = _asInt(swing?['duration']);
    final completedAt = DateTime.tryParse(
          '${json['updatedAt'] ?? json['createdAt'] ?? ''}',
        ) ??
        DateTime.now();
    return CompletedReview(
      id: '${json['_id'] ?? ''}',
      golferName: '${user?['name'] ?? ''}',
      avatarUrl: '${user?['profileUrl'] ?? ''}',
      club: '${swing?['clubType'] ?? ''}',
      angle: '${swing?['cameraAngle'] ?? ''}',
      thumbnailUrl: '${swing?['thumbnailUrl'] ?? swing?['videoUrl'] ?? ''}',
      videoUrl: '${swing?['videoUrl'] ?? ''}',
      duration: Duration(seconds: seconds),
      quote: '${json['message'] ?? ''}',
      completedAt: completedAt,
    );
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  int _asInt(dynamic raw) {
    if (raw is num) return raw.round();
    return int.tryParse('${raw ?? ''}') ?? 0;
  }
}
