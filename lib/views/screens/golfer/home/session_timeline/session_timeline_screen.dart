import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/journey_timeline_card.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_timeline_controller.dart';
import 'package:golf_training_app/views/screens/golfer/home/session_timeline/session_video_preview.dart';

import 'coach_feedback_card.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// "Session Timeline" screen — pixel match of the provided design:
/// back-nav app bar, full-bleed swing video preview with scrub bar,
/// a white "Journey" stepper card, and a dark coach-feedback card.
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => SessionTimelineScreen(
///       controller: SessionTimelineController(),
///     ),
///   ),
/// );
/// ```
class SessionTimelineScreen extends StatefulWidget {
  const SessionTimelineScreen({super.key, required this.controller});

  final SessionTimelineController controller;

  @override
  State<SessionTimelineScreen> createState() => _SessionTimelineScreenState();
}

class _SessionTimelineScreenState extends State<SessionTimelineScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            _AppBarRow(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          color: AppColors.ctaBrightBlue,
                          backgroundColor: AppColors.borderLightGray,
                        ),
                      ),
                    ClipRRect(
                      borderRadius: AppRadii.cardBorderRadius,
                      child: SessionVideoPreview(
                        video: controller.video,
                        onTogglePlay: controller.togglePlayback,
                        onExpand: controller.onExpandVideo,
                        onOpenAnalysisTool: controller.onOpenAnalysisTool,
                        onScrub: controller.seekToFraction,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (controller.isOffline) ...[
                      const _OfflineBanner(),
                      const SizedBox(height: 12),
                    ],
                    JourneyTimelineCard(
                      steps: controller.journeySteps,
                      focusStep: controller.focusStep,
                    ),
                    if (controller.showReadFeedback &&
                        controller.feedback != null) ...[
                      const SizedBox(height: 20),
                      CoachFeedbackCard(
                        feedback: controller.feedback!,
                        buttonLabel: controller.feedbackButtonLabel,
                        onReadFullFeedback: () =>
                            controller.onReadFullFeedback(context),
                      ),
                    ] else if (controller.showReadFeedback) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.onReadFullFeedback(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ctaBrightBlue,
                            foregroundColor: AppColors.surfaceWhite,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.buttonBorderRadius,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            controller.feedbackButtonLabel,
                            style: AppTextStyles.buttonLabel,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: AppRadii.cardBorderRadius,
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Text(
        'Sharing is queued and will continue automatically later.',
        style: AppTextStyles.type13.copyWith(color: AppColors.warningText),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Session Timeline', style: AppTextStyles.pageTitle),
        ],
      ),
    );
  }
}
