import 'package:flutter/material.dart';
import '../models/swing_review.dart';

/// Which tab of the Review Swing screen is showing.
enum ReviewSwingTab { submission, yourFeedback }

/// Drives the entire "Review Swing" screen: the tab selection, the video
/// play/scrub state, and every editable field on the "Your Feedback" tab
/// (coach notes, recommended drill, practice-plan builder, AI agreement).
///
/// Wire it up with Provider/ChangeNotifierProvider, or instantiate it
/// directly inside a StatefulWidget as shown in [ReviewSwingScreen].
class ReviewSwingController extends ChangeNotifier {
  ReviewSwingController({required this.review}) {
    _coachFeedbackController = TextEditingController(text: review.coachFeedback)
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

  final SwingReview review;

  ReviewSwingTab _tab = ReviewSwingTab.submission;
  ReviewSwingTab get tab => _tab;

  void setTab(ReviewSwingTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  // ----- Video playback (mock state; wire up to your real player) -----

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  // ----- "Your Feedback" text fields -----

  late final TextEditingController _coachFeedbackController;
  late final TextEditingController _recommendedDrillController;
  late final TextEditingController _aiExtraContextController;

  TextEditingController get coachFeedbackController => _coachFeedbackController;
  TextEditingController get recommendedDrillController =>
      _recommendedDrillController;
  TextEditingController get aiExtraContextController =>
      _aiExtraContextController;

  // ----- Practice Plan Builder -----

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
    // No notifyListeners() needed here — the TextField already owns its
    // own text; we're just keeping the model in sync as the coach types.
  }

  // ----- AI agreement -----

  AiAgreement get aiAgreement => review.aiAgreement;

  void setAiAgreement(AiAgreement value) {
    review.aiAgreement = value;
    notifyListeners();
  }

  // ----- Submit -----

  bool isSending = false;

  Future<void> sendFeedback() async {
    isSending = true;
    notifyListeners();
    try {
      // Hook your real API call here, e.g.:
      // await reviewRepository.submitFeedback(review);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _coachFeedbackController.dispose();
    _recommendedDrillController.dispose();
    _aiExtraContextController.dispose();
    super.dispose();
  }
}
