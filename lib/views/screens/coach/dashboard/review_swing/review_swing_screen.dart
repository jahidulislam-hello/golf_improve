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
    this.controller,
    this.onBack,
  }) : assert(
          review != null || controller != null,
          'Provide either a SwingReview or a ReviewSwingController',
        );

  final SwingReview? review;
  final CoachReviewSwingController? controller;
  final VoidCallback? onBack;

  @override
  State<CoachReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<CoachReviewSwingScreen> {
  late final CoachReviewSwingController _controller =
      widget.controller ?? CoachReviewSwingController(review: widget.review!);

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
    await _controller.sendFeedback();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback sent'),
          duration: Duration(milliseconds: 900),
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
              child: IndexedStack(
                index: _controller.tab == ReviewSwingTab.submission ? 0 : 1,
                children: [
                  SubmissionTab(controller: _controller),
                  YourFeedbackTab(controller: _controller),
                ],
              ),
            ),
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
