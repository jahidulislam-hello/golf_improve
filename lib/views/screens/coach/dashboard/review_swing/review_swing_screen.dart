import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/controllers/review_swing_controller.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/models/swing_review.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/screens/tabs/feedback_tab.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/screens/tabs/submission_tab.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/widgets/review/review_app_bar.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/widgets/review/review_tab_bar.dart';
import 'package:golf_training_app/views/screens/coach/dashboard/dashboard_screen/widgets/review/send_feedback_button.dart';


/// The full "Review Swing" screen: header, Submission/Your Feedback tabs,
/// and a sticky "Send Feedback" button. All state lives in
/// [ReviewSwingController] — pass one in, or let the screen create its
/// own from [review].
class CoachReviewSwingScreen extends StatefulWidget {
  const CoachReviewSwingScreen({
    super.key,
    this.review,
    this.shareId,
    this.controller,
    this.onBack,
    this.canSendFeedback = true,
  }) : assert(
          review != null || controller != null || shareId != null,
          'Provide a SwingReview, shareId, or a ReviewSwingController',
        );

  final SwingReview? review;
  final String? shareId;
  final CoachReviewSwingController? controller;
  final VoidCallback? onBack;
  final bool canSendFeedback;

  @override
  State<CoachReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<CoachReviewSwingScreen> {
  late final CoachReviewSwingController _controller =
      widget.controller ??
          CoachReviewSwingController(
            review: widget.review ??
                SwingReview(
                  id: widget.shareId ?? '',
                  studentName: '',
                  studentAvatarUrl: '',
                  club: '',
                  angle: '',
                  duration: Duration.zero,
                  videoThumbnailUrl: '',
                  currentPositionLabel: '',
                  studentQuestion: '',
                  studentSessionNotes: '',
                  sessionTags: const [],
                  aiAnalysisPoints: const [],
                ),
            shareId: widget.shareId ?? widget.review?.id,
            canSendFeedback: widget.canSendFeedback,
          );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      // We created it ourselves, so we own disposing it.
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSend() async {
    final ok = await _controller.sendFeedback();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback sent'),
          duration: Duration(milliseconds: 900),
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }
    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppColors.primaryNavy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = _controller.review;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: ReviewAppBar(
                title: 'Review Swing',
                subtitle: review.subtitleLine,
                onBack: widget.onBack,
              ),
            ),
            ReviewTabBar(
              selected: _controller.tab,
              onChanged: _controller.setTab,
            ),
            Expanded(
              child: _controller.isLoading && !_controller.hasLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : IndexedStack(
                      index: _controller.tab == ReviewSwingTab.submission ? 0 : 1,
                      children: [
                        SubmissionTab(controller: _controller),
                        YourFeedbackTab(controller: _controller),
                      ],
                    ),
            ),
            if (widget.canSendFeedback)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SendFeedbackButton(
                  onPressed: _handleSend,
                  isLoading: _controller.isSending,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
