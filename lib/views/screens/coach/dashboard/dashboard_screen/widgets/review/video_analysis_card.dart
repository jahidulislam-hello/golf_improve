import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/core/app_radii.dart';

/// The dark video card at the top of the Review Swing screen: swing
/// thumbnail/player, top-right expand + target (draw-annotation) buttons,
/// a center play button, an optional swing-plane line the coach has
/// drawn, and a bottom scrub bar with a time label.
///
/// This renders the *chrome* around a video player. Swap [child] for your
/// actual video widget (e.g. a `VideoPlayer` from the `video_player`
/// package) — by default it falls back to [thumbnailUrl].
class VideoAnalysisCard extends StatelessWidget {
  const VideoAnalysisCard({
    super.key,
    required this.thumbnailUrl,
    required this.positionLabel,
    required this.isPlaying,
    required this.onPlayPause,
    this.child,
    this.showScrubHint = true,
    this.showSwingPlaneLine = true,
    this.onExpand,
    this.onDrawTool,
  });

  final String thumbnailUrl;

  /// e.g. "0:02/0:08"
  final String positionLabel;

  final bool isPlaying;
  final VoidCallback onPlayPause;

  /// Pass your real video player widget here to replace the static
  /// thumbnail image underneath the overlay chrome.
  final Widget? child;

  /// Shows the "Scrub to the moment you want to analyse. Then draw."
  /// helper copy (Submission tab only in the mock).
  final bool showScrubHint;

  /// Shows the blue dashed annotation line + dot markers.
  final bool showSwingPlaneLine;

  final VoidCallback? onExpand;
  final VoidCallback? onDrawTool;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.cardBorderRadius,
      child: AspectRatio(
        aspectRatio: 4 / 3.1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child ??
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.primaryNavy),
                ),

            if (showSwingPlaneLine) const _SwingPlaneOverlay(),

            // Top-right controls
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                children: [
                  _CircleIconButton(
                    icon: Icons.open_in_full_rounded,
                    background: AppColors.ctaBrightBlue,
                    iconColor: AppColors.surfaceWhite,
                    onTap: onExpand,
                  ),
                  const SizedBox(height: 10),
                  _CircleIconButton(
                    icon: Icons.gps_fixed_rounded,
                    background: Colors.white.withOpacity(0.85),
                    iconColor: AppColors.textPrimary,
                    onTap: onDrawTool,
                  ),
                ],
              ),
            ),

            // Center play button
            Center(
              child: _CircleIconButton(
                icon: isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                background: Colors.white.withOpacity(0.35),
                iconColor: AppColors.surfaceWhite,
                size: 56,
                iconSize: 28,
                onTap: onPlayPause,
              ),
            ),

            // Bottom gradient + scrub bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 28, 14, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primaryNavy.withOpacity(0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showScrubHint) ...[
                      Text(
                        'Scrub to the moment you want to analyse. Then draw.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          positionLabel,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

/// A diagonal dashed line with dot endpoints — the swing-plane annotation
/// the coach draws over the frame. Positioned to roughly match the mock;
/// swap for real drawn-path coordinates once you wire up the draw tool.
class _SwingPlaneOverlay extends StatelessWidget {
  const _SwingPlaneOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      top: 60,
      child: Transform.rotate(
        angle: -math.pi / 7,
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _dot(),
            CustomPaint(
              size: const Size(150, 2),
              painter: _DashedLinePainter(color: AppColors.ctaBrightBlue),
            ),
            _dot(),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: AppColors.ctaBrightBlue,
          shape: BoxShape.circle,
        ),
      );
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(math.min(startX + dashWidth, size.width), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.onTap,
    this.size = 36,
    this.iconSize = 18,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
