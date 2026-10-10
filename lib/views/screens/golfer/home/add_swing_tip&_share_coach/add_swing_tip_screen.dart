import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/add_swing_section_card.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/club_type_pill.dart';
import 'package:golf_training_app/views/screens/golfer/home/add_swing_tip&_share_coach/dashed_border_box.dart';

import 'add_swing_tip_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';


class AddSwingTipScreen extends StatefulWidget {
  const AddSwingTipScreen({super.key});

  @override
  State<AddSwingTipScreen> createState() => _AddSwingTipScreenState();
}

class _AddSwingTipScreenState extends State<AddSwingTipScreen> {
  late final AddSwingTipController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddSwingTipController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final ok = await _controller.save();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a reminder before saving.')),
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
            _AppBarRow(onShareWithPro: () {}),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- Reminder text -----
                    AddSwingSectionCard(
                      label: "WHAT'S THE REMINDER?",
                      child: TextField(
                        controller: _controller.reminderController,
                        maxLines: 3,
                        minLines: 2,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText:
                              'e.g. Keep left elbow close to body on the downswing…',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Mark as important -----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppRadii.cardBorderRadius,
                        border: AppRadii.cardBorder,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.betaBadgeBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: AppColors.betaBadgeText,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mark as Important',
                                  style: AppTextStyles.type16.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Highlighted in your logbook',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _controller.markAsImportant,
                            onChanged: _controller.toggleMarkAsImportant,
                            activeColor: AppColors.surfaceWhite,
                            activeTrackColor: AppColors.ctaBrightBlue,
                            inactiveThumbColor: AppColors.surfaceWhite,
                            inactiveTrackColor: AppColors.pillInactive,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Club type -----
                    AddSwingSectionCard(
                      label: 'CLUB TYPE',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final type in AddSwingTipController.clubTypes)
                            ClubTypePill(
                              label: type,
                              selected: _controller.selectedClubType == type,
                              onTap: () => _controller.selectClubType(type),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Link to swing video -----
                    AddSwingSectionCard(
                      label: 'LINK TO SWING VIDEO',
                      child: InkWell(
                        borderRadius: AppRadii.cardBorderRadius,
                        onTap: () {
                          // TODO: hook up to your media picker, then:
                          // _controller.attachVideo(pickedFileName);
                        },
                        child: DashedBorderBox(
                          child: _controller.hasAttachedVideo
                              ? Column(
                                  children: [
                                    const Icon(
                                      Icons.videocam_rounded,
                                      color: AppColors.ctaBrightBlue,
                                      size: 26,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _controller.attachedVideoName!,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _controller.removeVideo,
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Icon(
                                      Icons.videocam_outlined,
                                      color: AppColors.textSecondary,
                                      size: 26,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Attach existing clip',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Filming reminder banner -----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.proFeedbackBg,
                        borderRadius: AppRadii.cardBorderRadius,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.ctaBrightBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filming Reminder',
                                  style: AppTextStyles.type14.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ctaBrightBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This tip will appear as an overlay when you '
                                  'start the camera.',
                                  style: AppTextStyles.type13.copyWith(
                                    color: AppColors.ctaBrightBlue
                                        .withValues(alpha: 0.8),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Save button -----
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
                      onTap: _controller.canSave ? _onSave : null,
                      child: Center(
                        child: _controller.isSaving
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
                            : Text('Save', style: AppTextStyles.buttonLabel),
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

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.onShareWithPro});

  final VoidCallback onShareWithPro;

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
          Text('Add Swing Tip', style: AppTextStyles.appBarTitle),
          const Spacer(),
          InkWell(
            onTap: onShareWithPro,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Text('Share with pro', style: AppTextStyles.linkText),
                const SizedBox(width: 4),
                const Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: AppColors.ctaBrightBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
