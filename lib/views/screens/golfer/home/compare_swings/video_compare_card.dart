import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';


/// Thumbnail card for one swing clip: 16:9-ish image, a centered translucent
/// play button, and a scrub progress bar along the bottom edge.
///
/// Swap [thumbnail] for your real video-thumbnail widget (e.g. a
/// `VideoPlayerController` frame or a cached network thumbnail) — this
/// widget only handles the chrome (play button + progress bar) on top.
class VideoCompareCard extends StatelessWidget {
  const VideoCompareCard({
    super.key,
    required this.progress,
    required this.progressColor,
    required this.onPlayTap,
    this.thumbnail,
    this.isPlaying = false,
    this.height = 180,
  });

  final ImageProvider? thumbnail;
  final double progress;
  final Color progressColor;
  final bool isPlaying;
  final VoidCallback onPlayTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.cardBorderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ----- Thumbnail / video surface -----
            if (thumbnail != null)
              Image(image: thumbnail!, fit: BoxFit.cover)
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8FA998), Color(0xFF4C6B52)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.landscape_rounded,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
              ),

            // ----- Play button -----
            Center(
              child: InkWell(
                onTap: onPlayTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.surfaceWhite,
                    size: 28,
                  ),
                ),
              ),
            ),

            // ----- Scrub progress bar -----
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            color: AppColors.surfaceWhite.withValues(alpha: 0.4),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(color: progressColor),
                          ),
                        ],
                      );
                    },
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
