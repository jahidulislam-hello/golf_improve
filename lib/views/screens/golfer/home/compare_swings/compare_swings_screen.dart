import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/clip_header_row.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/video_compare_card.dart';
import 'compare_swings_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';


class CompareSwingsScreen extends StatefulWidget {
  const CompareSwingsScreen({super.key});

  @override
  State<CompareSwingsScreen> createState() => _CompareSwingsScreenState();
}

class _CompareSwingsScreenState extends State<CompareSwingsScreen> {
  late final CompareSwingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompareSwingsController(
      clipA: SwingClip(
        badgeLetter: 'A',
        badgeColor: AppColors.primaryNavy,
        label: 'Driver · Face On · Today',
        progress: 0.32,
      ),
      clipB: SwingClip(
        badgeLetter: 'B',
        badgeColor: AppColors.ctaBrightBlue,
        label: 'Driver · Face On · Last Week',
        progress: 0.58,
      ),
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _AppBarRow(
              isRefreshing: _controller.isRefreshing,
              onRefresh: _controller.refresh,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- Clip A -----
                    ClipHeaderRow(
                      clip: _controller.clipA,
                      onSpeedChanged: (speed) =>
                          _controller.setSpeed(_controller.clipA, speed),
                    ),
                    const SizedBox(height: 12),
                    VideoCompareCard(
                      thumbnail: _controller.clipA.thumbnailImage,
                      progress: _controller.clipA.progress,
                      progressColor: AppColors.ctaBrightBlue,
                      isPlaying: _controller.clipA.isPlaying,
                      onPlayTap: () => _controller.togglePlay(_controller.clipA),
                    ),

                    // ----- Play both -----
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.borderLightGray),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _controller.playBoth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  foregroundColor: AppColors.surfaceWhite,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.buttonBorderRadius,
                                  ),
                                ),
                                child: Text(
                                  'Play Both',
                                  style: AppTextStyles.buttonLabel
                                      .copyWith(fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.borderLightGray),
                          ),
                        ],
                      ),
                    ),

                    // ----- Clip B -----
                    ClipHeaderRow(
                      clip: _controller.clipB,
                      onSpeedChanged: (speed) =>
                          _controller.setSpeed(_controller.clipB, speed),
                    ),
                    const SizedBox(height: 12),
                    VideoCompareCard(
                      thumbnail: _controller.clipB.thumbnailImage,
                      progress: _controller.clipB.progress,
                      progressColor: AppColors.ctaBrightBlue,
                      isPlaying: _controller.clipB.isPlaying,
                      onPlayTap: () => _controller.togglePlay(_controller.clipB),
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
  const _AppBarRow({required this.isRefreshing, required this.onRefresh});

  final bool isRefreshing;
  final VoidCallback onRefresh;

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
          Text('Compare Swings', style: AppTextStyles.appBarTitle),
          const Spacer(),
          InkWell(
            onTap: isRefreshing ? null : onRefresh,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.pillInactive,
                shape: BoxShape.circle,
              ),
              child: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.textSecondary),
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
