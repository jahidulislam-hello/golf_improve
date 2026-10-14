import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/swing_review.dart';

/// Which tab of the Review Swing screen is showing.
enum ReviewSwingTab { submission, yourFeedback }

/// Drives the entire "Review Swing" screen: the tab selection, the video
/// play/scrub state, and every editable field on the "Your Feedback" tab
/// (coach notes, recommended drill, and the practice plan to edit or approve).
class CoachReviewSwingController extends ChangeNotifier {
  CoachReviewSwingController({
    required this.review,
    this.shareId,
    this.canSendFeedback = true,
  }) {
    _bindControllers();
    final id = (shareId != null && shareId!.isNotEmpty) ? shareId! : review.id;
    if (id.isNotEmpty) {
      loadShare(id);
    }
  }

  SwingReview review;
  final String? shareId;
  final bool canSendFeedback;

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  bool planApproved = true;

  ReviewSwingTab _tab = ReviewSwingTab.submission;
  ReviewSwingTab get tab => _tab;

  void setTab(ReviewSwingTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  late final TextEditingController _coachFeedbackController;
  late final TextEditingController _recommendedDrillController;
  late final TextEditingController _aiExtraContextController;

  TextEditingController get coachFeedbackController => _coachFeedbackController;
  TextEditingController get recommendedDrillController =>
      _recommendedDrillController;
  TextEditingController get aiExtraContextController =>
      _aiExtraContextController;

  List<PracticePlanItem> get practicePlan => review.practicePlan;

  void addPracticePlanDay() {
    final nextIndex = review.practicePlan.length;
    final startDay = nextIndex * 4 + 1;
    final endDay = startDay + 3;
    review.practicePlan.add(
      PracticePlanItem(
        id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
        dayRangeLabel: 'Days $startDay-$endDay',
      ),
    );
    notifyListeners();
  }

  void removePracticePlanDay(String id) {
    review.practicePlan.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updatePracticePlanDescription(String id, String description) {
    final item = review.practicePlan.firstWhere((item) => item.id == id);
    item.description = description;
  }

  void setPlanApproved(bool value) {
    planApproved = value;
    notifyListeners();
  }

  bool isSending = false;

  Future<void> loadShare(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final service = await _service();
      if (canSendFeedback) {
        try {
          await service.markShareViewed(id);
        } catch (_) {}
      }
      final response = await service.getShare(id);
      final data = _asMap(response['data']);
      if (data != null) {
        final previousAvatar = review.studentAvatarUrl;
        review = SwingReview.fromShareApi(data);
        if (review.studentAvatarUrl.isEmpty && previousAvatar.isNotEmpty) {
          review = SwingReview(
            id: review.id,
            studentName: review.studentName,
            studentAvatarUrl: previousAvatar,
            club: review.club,
            angle: review.angle,
            duration: review.duration,
            videoThumbnailUrl: review.videoThumbnailUrl,
            currentPositionLabel: review.currentPositionLabel,
            studentQuestion: review.studentQuestion,
            studentSessionNotes: review.studentSessionNotes,
            sessionTags: review.sessionTags,
            aiAnalysisPoints: review.aiAnalysisPoints,
            lastNoteOnStudent: review.lastNoteOnStudent,
            coachFeedback: review.coachFeedback,
            recommendedDrill: review.recommendedDrill,
            practicePlan: review.practicePlan,
            aiAgreement: review.aiAgreement,
            aiExtraContext: review.aiExtraContext,
          );
        }
        _syncControllers();
      }
      hasLoaded = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendFeedback() async {
    if (!canSendFeedback) return false;
    final feedback = _coachFeedbackController.text.trim();
    if (feedback.isEmpty) {
      errorMessage = 'Please write your coaching feedback.';
      notifyListeners();
      return false;
    }

    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      final service = await _service();
      final plan = review.practicePlan
          .where((e) => e.dayRangeLabel.isNotEmpty || e.description.isNotEmpty)
          .map((e) => e.toJson())
          .toList();
      await service.respondToShare(
        shareId: review.id,
        feedbackText: feedback,
        recommendedDrill: _recommendedDrillController.text.trim(),
        practicePlan: plan,
      );
      if (plan.isNotEmpty ||
          _recommendedDrillController.text.trim().isNotEmpty) {
        await service.updatePracticePlan(
          shareId: review.id,
          recommendedDrill: _recommendedDrillController.text.trim(),
          practicePlan: plan,
          isApproved: planApproved,
        );
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void _bindControllers() {
    _coachFeedbackController =
        TextEditingController(text: review.coachFeedback)
          ..addListener(() => review.coachFeedback = _coachFeedbackController.text);
    _recommendedDrillController =
        TextEditingController(text: review.recommendedDrill)
          ..addListener(
            () => review.recommendedDrill = _recommendedDrillController.text,
          );
    _aiExtraContextController =
        TextEditingController(text: review.aiExtraContext)
          ..addListener(
            () => review.aiExtraContext = _aiExtraContextController.text,
          );
  }

  void _syncControllers() {
    _coachFeedbackController.text = review.coachFeedback;
    _recommendedDrillController.text = review.recommendedDrill;
    _aiExtraContextController.text = review.aiExtraContext;
  }

  Future<CoachService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return CoachService(apiService: ApiService(sharedPreferences: prefs));
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  @override
  void dispose() {
    _coachFeedbackController.dispose();
    _recommendedDrillController.dispose();
    _aiExtraContextController.dispose();
    super.dispose();
  }
}
