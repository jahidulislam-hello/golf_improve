import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../controllers/review_swing_controller.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/video_preview.dart';
import 'review_swing_fullscreen_screen.dart';

/// Screen 5 — Review Swing (dark background, annotated preview).
/// Reached from Screen 2 by tapping the video.
/// Tapping the fullscreen/expand icon opens Screen 6.
class ReviewSwingScreen extends StatefulWidget {
  const ReviewSwingScreen({super.key});

  @override
  State<ReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<ReviewSwingScreen> {
  final ReviewSwingController controller = ReviewSwingController();

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReviewSwingFullscreenScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryNavy,
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
                        background: Colors.white.withOpacity(0.08),
                        iconColor: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Review Swing',
                        style: AppTextStyles.sectionHeader.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: VideoPreview(
                    position: controller.position,
                    total: controller.total,
                    isPlaying: controller.isPlaying,
                    onPlayToggle: controller.togglePlay,
                    showAnnotationLines: controller.showDrawing,
                    onExpand: _openFullscreen,
                    aspectRatio: 16 / 10,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
