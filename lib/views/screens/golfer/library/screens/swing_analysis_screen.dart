import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../controllers/swing_analysis_controller.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/video_preview.dart';
import 'ai_golf_coach_screen.dart';
import 'share_with_coach_screen.dart';
import 'review_swing_screen.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Screen 2 — Swing Analysis (AI Golf Coach summary for one recorded swing).
/// - Tapping the video opens Screen 5 (Review Swing).
/// - Tapping "AI Golf Coach" opens Screen 4 (AI chat).
/// - Tapping "Send to James Keller" opens Screen 3 (Share with Coach).
class SwingAnalysisScreen extends StatefulWidget {
  const SwingAnalysisScreen({super.key});

  @override
  State<SwingAnalysisScreen> createState() => _SwingAnalysisScreenState();
}

class _SwingAnalysisScreenState extends State<SwingAnalysisScreen> {
  final SwingAnalysisController controller = SwingAnalysisController();

  void _openReviewSwing() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReviewSwingScreen()),
    );
  }

  void _openAiChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiGolfCoachScreen()),
    );
  }

  void _openShareWithCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShareWithCoachScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).maybePop(),
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Text('Swing Analysis',
                          style: AppTextStyles.sectionHeader
                              .copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE7B5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BETA',
                          style: AppTextStyles.type10.copyWith(
                            color: const Color(0xFF8A6D1D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      CircleIconButton(
                        icon: Icons.share,
                        background: AppColors.backgroundOffWhite,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      GestureDetector(
                        onTap: _openReviewSwing,
                        child: VideoPreview(
                          position: controller.position,
                          total: controller.total,
                          isPlaying: controller.isPlaying,
                          onPlayToggle: controller.togglePlay,
                          showAnnotationLines: true,
                          onExpand: _openReviewSwing,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrimaryButton(
                              label: 'AI Golf Coach',
                              icon: Icons.psychology,
                              onTap: _openAiChat,
                            ),
                            const SizedBox(height: 16),
                            const WarningBanner(
                              text:
                                  'AI suggestions are experimental. Always review results with your golf coach before making technique changes.',
                            ),
                            const SizedBox(height: 16),
                            ...controller.insights.map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InsightCard(insight: i),
                              ),
                            ),
                            ProFeedbackCard(
                              initials: controller.proInitials,
                              quote: controller.proQuote,
                              improvementNote: controller.proImprovement,
                            ),
                            const SizedBox(height: 20),
                            Text('3 Things to Try',
                                style: AppTextStyles.sectionHeader
                                    .copyWith(fontSize: 18)),
                            ...List.generate(
                              controller.thingsToTry.length,
                              (i) => NumberedStepTile(
                                number: i + 1,
                                text: controller.thingsToTry[i],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: GestureDetector(
                          onTap: _openShareWithCoach,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: AppRadii.cardBorderRadius,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.share,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Share AI Result with Coach',
                                      style: AppTextStyles.type16.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Let ${controller.coachName} review the AI observations and add their professional feedback.',
                                  style: AppTextStyles.type13.copyWith(
                                      color: Colors.white60, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  label: 'Send to ${controller.coachName}',
                                  onTap: _openShareWithCoach,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
