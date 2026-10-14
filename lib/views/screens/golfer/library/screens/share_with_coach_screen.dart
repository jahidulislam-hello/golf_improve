import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';

import '../controllers/share_coach_controller.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/video_preview.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// Screen 3 — Share with Coach.
/// Reached from Screen 2 by tapping "Send to Coach".
class ShareWithCoachScreen extends StatefulWidget {
  const ShareWithCoachScreen({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.coachName = 'Coach',
    this.coachProfileUrl,
    this.coachId,
    this.swingLibraryId,
    this.practiceNoteId,
    this.initialStatus = '',
  });

  final String? videoUrl;
  final String? thumbnailUrl;
  final String coachName;
  final String? coachProfileUrl;
  final String? coachId;
  final String? swingLibraryId;
  final String? practiceNoteId;
  final String initialStatus;

  @override
  State<ShareWithCoachScreen> createState() => _ShareWithCoachScreenState();
}

class _ShareWithCoachScreenState extends State<ShareWithCoachScreen> {
  late final ShareCoachController controller;

  @override
  void initState() {
    super.initState();
    controller = ShareCoachController(
      coachName: widget.coachName,
      coachProfileUrl: widget.coachProfileUrl,
      coachId: widget.coachId,
      swingLibraryId: widget.swingLibraryId,
      practiceNoteId: widget.practiceNoteId,
      initialStatus: widget.initialStatus,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await controller.send();
    if (!mounted) return;
    if (!ok) {
      final message = controller.errorMessage ?? 'Could not share this swing.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controller.shareStatusLabel)),
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
                      Expanded(
                        child: Text(
                          'Share with ${controller.coachName}',
                          style: AppTextStyles.sectionHeader
                              .copyWith(fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.cardBackground,
                              backgroundImage: controller.coachProfileUrl != null &&
                                      controller.coachProfileUrl!.startsWith('http')
                                  ? NetworkImage(controller.coachProfileUrl!)
                                  : null,
                              child: controller.coachProfileUrl != null &&
                                      controller.coachProfileUrl!.startsWith('http')
                                  ? null
                                  : Text(
                                      controller.coachName.isEmpty
                                          ? 'C'
                                          : controller.coachName[0].toUpperCase(),
                                      style: AppTextStyles.type16.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.coachName,
                                    style: AppTextStyles.type16.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    'Your assigned coach',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: AppRadii.cardBorderRadius,
                        child: VideoPreview(
                          videoUrl: widget.videoUrl,
                          thumbnailUrl: widget.thumbnailUrl,
                          showOverlayButtons: false,
                          aspectRatio: 16 / 11,
                          borderRadius: AppRadii.cardBorderRadius,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SectionLabel('ADD A MESSAGE'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: AppRadii.cardBorderRadius,
                          border: AppRadii.cardBorder,
                        ),
                        child: TextField(
                          controller: controller.questionController,
                          enabled: controller.canSend,
                          minLines: 2,
                          maxLines: 4,
                          style: AppTextStyles.type14,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'What would you like your coach to look at?',
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
                      if (controller.shareStatusLabel.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: AppRadii.buttonBorderRadius,
                            border: AppRadii.cardBorder,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            controller.shareStatusLabel,
                            style: AppTextStyles.buttonLabel.copyWith(
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        )
                      else
                        PrimaryButton(
                          label: controller.isSending
                              ? 'Sending…'
                              : 'Send to Coach',
                          icon: Icons.send,
                          onTap: controller.canSend ? _send : () {},
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
