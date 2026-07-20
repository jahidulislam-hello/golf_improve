import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

import '../controllers/share_coach_controller.dart';
import '../controllers/review_swing_controller.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/video_preview.dart';

/// Screen 3 — Share with Coach.
/// Reached from Screen 2 by tapping "Send to James Keller".
class ShareWithCoachScreen extends StatefulWidget {
  const ShareWithCoachScreen({super.key});

  @override
  State<ShareWithCoachScreen> createState() => _ShareWithCoachScreenState();
}

class _ShareWithCoachScreenState extends State<ShareWithCoachScreen> {
  final ShareCoachController controller = ShareCoachController();
  // Local, static playback state just for the read-only preview here.
  final ReviewSwingController previewController = ReviewSwingController();

  @override
  void dispose() {
    controller.dispose();
    previewController.dispose();
    super.dispose();
  }

  void _send() {
    controller.send();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sent to your coach.')),
    );
    Navigator.of(context).maybePop();
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
                      Text('Share with coach',
                          style: AppTextStyles.sectionHeader
                              .copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: VideoPreview(
                          position: previewController.position,
                          total: previewController.total,
                          isPlaying: previewController.isPlaying,
                          onPlayToggle: previewController.togglePlay,
                          showOverlayButtons: false,
                          aspectRatio: 16 / 11,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SectionLabel('YOUR QUESTION'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLightGray),
                        ),
                        child: TextField(
                          controller: controller.questionController,
                          minLines: 2,
                          maxLines: 4,
                          style: AppTextStyles.type14,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'What would you like your Coach to focus on?',
                            hintStyle: AppTextStyles.type14
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('WHAT TO INCLUDE'),
                      const SizedBox(height: 10),
                      ...List.generate(
                        controller.includeItems.length,
                        (i) => ShareIncludeTile(
                          item: controller.includeItems[i],
                          onToggle: () => controller.toggleItem(i),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Send to Coach',
                        icon: Icons.send,
                        onTap: _send,
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
