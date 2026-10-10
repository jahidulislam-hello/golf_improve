import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/add_swing_section_card.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/dashed_border_box.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/settings_toggle_row.dart';
import 'share_with_coach_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';


class ShareWithCoachScreen extends StatefulWidget {
  const ShareWithCoachScreen({super.key, this.initialData});

  final Map<String, dynamic>? initialData;

  @override
  State<ShareWithCoachScreen> createState() => _ShareWithCoachScreenState();
}

class _ShareWithCoachScreenState extends State<ShareWithCoachScreen> {
  late final ShareWithCoachController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShareWithCoachController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final ok = await _controller.send();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a video before sending.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            _AppBarRow(
              // "Save" is only meaningfully enabled once there's something
              // to persist as a draft; wire this up to your own draft logic.
              onSave: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- Select video -----
                    AddSwingSectionCard(
                      label: 'SELECT VIDEO',
                      trailing: InkWell(
                        onTap: () {
                          // TODO: open the full video library.
                        },
                        child: Text('View All', style: AppTextStyles.linkText),
                      ),
                      child: InkWell(
                        borderRadius: AppRadii.cardBorderRadius,
                        onTap: () {
                          // TODO: hook up to your media picker, then:
                          // _controller.selectVideo(pickedFileName);
                        },
                        child: DashedBorderBox(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: _controller.hasSelectedVideo
                              ? _SelectedVideoContent(
                                  fileName: _controller.selectedVideoName!,
                                  onChoose: () {
                                    // TODO: reopen the picker to swap the clip.
                                  },
                                )
                              : _EmptyVideoContent(
                                  onChoose: () {
                                    // TODO: hook up to your media picker, then:
                                    // _controller.selectVideo(pickedFileName);
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Your question -----
                    AddSwingSectionCard(
                      label: 'YOUR QUESTION',
                      child: TextField(
                        controller: _controller.questionController,
                        maxLines: 3,
                        minLines: 2,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText:
                              'What would you like your Coach to focus on?',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Share settings -----
                    AddSwingSectionCard(
                      label: 'SHARE SETTINGS',
                      subtitle:
                          'Permissions for how your Coach can interact with '
                          'the video.',
                      childTopSpacing: 4,
                      child: Column(
                        children: [
                          SettingsToggleRow(
                            title: 'Allow Coach to draw on video',
                            caption: 'Coach can annotate technique on the frame',
                            value: _controller.allowCoachToDraw,
                            onChanged: _controller.toggleAllowCoachToDraw,
                          ),
                          SettingsToggleRow(
                            title: 'High Quality Export',
                            caption: 'Share in full resolution (uses more data)',
                            value: _controller.highQualityExport,
                            onChanged: _controller.toggleHighQualityExport,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Send to coach -----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.ctaBlueGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _controller.canSend ? _onSend : null,
                      child: Center(
                        child: _controller.isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.surfaceWhite,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    color: AppColors.surfaceWhite,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send to Coach',
                                    style: AppTextStyles.buttonLabel,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVideoContent extends StatelessWidget {
  const _EmptyVideoContent({required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.pillInactive,
            borderRadius: AppRadii.cardBorderRadius,
          ),
          child: const Icon(
            Icons.videocam_outlined,
            color: AppColors.textSecondary,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'No video selected',
          style: AppTextStyles.type16.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to choose from your Library',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: onChoose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: AppColors.surfaceWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.buttonBorderRadius,
              ),
            ),
            child: Text(
              'Choose Video',
              style: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedVideoContent extends StatelessWidget {
  const _SelectedVideoContent({
    required this.fileName,
    required this.onChoose,
  });

  final String fileName;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.statusInfoBg,
            borderRadius: AppRadii.cardBorderRadius,
          ),
          child: const Icon(
            Icons.videocam_rounded,
            color: AppColors.ctaBrightBlue,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          fileName,
          style: AppTextStyles.type16.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text('Ready to share', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onChoose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.borderLightGray),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.buttonBorderRadius,
              ),
            ),
            child: const Text(
              'Change Video',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.pillInactive,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Share with Coach', style: AppTextStyles.appBarTitle),
          const Spacer(),
          InkWell(
            onTap: onSave,
            borderRadius: BorderRadius.circular(8),
            child: Text('Save', style: AppTextStyles.linkText),
          ),
        ],
      ),
    );
  }
}
