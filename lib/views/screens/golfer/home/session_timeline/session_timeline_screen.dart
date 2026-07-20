import 'package:flutter/material.dart';
import '../controllers/session_timeline_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/session_video_preview.dart';
import '../widgets/journey_timeline_card.dart';
import '../widgets/coach_feedback_card.dart';

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
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SessionVideoPreview(
                        video: controller.video,
                        onTogglePlay: controller.togglePlayback,
                        onExpand: controller.onExpandVideo,
                        onOpenAnalysisTool: controller.onOpenAnalysisTool,
                        onScrub: controller.seekToFraction,
                      ),
                    ),
                    const SizedBox(height: 20),
                    JourneyTimelineCard(steps: controller.journeySteps),
                    const SizedBox(height: 20),
                    CoachFeedbackCard(
                      feedback: controller.feedback,
                      onReadFullFeedback: controller.onReadFullFeedback,
                    ),
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
