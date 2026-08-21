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
    this.includeSwingVideo = true,
    this.includeAiAnalysis = false,
    this.includePersonalNotes = false,
    this.alreadyShared = false,
  });

  final String? videoUrl;
  final String? thumbnailUrl;
  final String coachName;
  final String? coachProfileUrl;
  final bool includeSwingVideo;
  final bool includeAiAnalysis;
  final bool includePersonalNotes;
  final bool alreadyShared;

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
      includeSwingVideo: widget.includeSwingVideo,
      includeAiAnalysis: widget.includeAiAnalysis,
      includePersonalNotes: widget.includePersonalNotes,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _send() {
    controller.send();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent to ${widget.coachName}.')),
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
                      Expanded(
                        child: Text(
                          'Share with ${widget.coachName}',
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
                      if (widget.coachProfileUrl != null &&
                          widget.coachProfileUrl!.startsWith('http'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    NetworkImage(widget.coachProfileUrl!),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.coachName,
                                      style: AppTextStyles.type16.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      widget.alreadyShared
                                          ? 'Already shared with this coach'
                                          : 'Your assigned coach',
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
                      const SectionLabel('YOUR QUESTION'),
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
                          minLines: 2,
                          maxLines: 4,
                          style: AppTextStyles.type14,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'What would you like ${widget.coachName} to focus on?',
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
                        label: widget.alreadyShared
                            ? 'Shared with ${widget.coachName}'
                            : 'Send to ${widget.coachName}',
                        icon: Icons.send,
                        onTap: widget.alreadyShared ? () {} : _send,
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
