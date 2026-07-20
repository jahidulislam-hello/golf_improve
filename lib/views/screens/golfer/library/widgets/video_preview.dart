import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';


/// Shared swing-video preview surface: placeholder frame + play button +
/// scrub caption + progress bar with elapsed/total time. Optionally shows
/// the blue swing-plane annotation lines (used on Screens 2 & 5) and the
/// expand / target overlay buttons in the top-right corner.
class VideoPreview extends StatelessWidget {
  final Duration position;
  final Duration total;
  final bool isPlaying;
  final VoidCallback onPlayToggle;
  final bool showAnnotationLines;
  final bool showOverlayButtons;
  final VoidCallback? onExpand;
  final double aspectRatio;
  final BorderRadius borderRadius;

  const VideoPreview({
    super.key,
    required this.position,
    required this.total,
    required this.isPlaying,
    required this.onPlayToggle,
    this.showAnnotationLines = false,
    this.showOverlayButtons = true,
    this.onExpand,
    this.aspectRatio = 16 / 10,
    this.borderRadius = BorderRadius.zero,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder video frame.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7FA6C9), Color(0xFF3E6B45)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.sports_golf, color: Colors.white38, size: 48),
              ),
            ),
            if (showAnnotationLines) const _SwingPlaneOverlay(),
            if (showOverlayButtons)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _OverlayCircleButton(
                      icon: Icons.open_in_full,
                      background: AppColors.ctaBrightBlue,
                      onTap: onExpand,
                    ),
                    const SizedBox(height: 8),
                    const _OverlayCircleButton(
                      icon: Icons.track_changes,
                      background: Colors.black38,
                    ),
                  ],
                ),
              ),
            // Center play button.
            Center(
              child: GestureDetector(
                onTap: onPlayToggle,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Bottom scrub caption + progress bar.
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scrub to the moment you want to analyse. Then draw.',
                    style: AppTextStyles.type11.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total.inMilliseconds == 0
                                ? 0
                                : position.inMilliseconds / total.inMilliseconds,
                            minHeight: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.ctaBrightBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_fmt(position)}/${_fmt(total)}',
                        style: AppTextStyles.type11.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayCircleButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final VoidCallback? onTap;
  const _OverlayCircleButton({required this.icon, required this.background, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

/// Blue diagonal swing-plane annotation lines drawn over the video, matching
/// the freehand drawing shown on the Swing Analysis / Review Swing screens.
class _SwingPlaneOverlay extends StatelessWidget {
  const _SwingPlaneOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SwingPlanePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SwingPlanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ctaBrightBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = AppColors.ctaBrightBlue;

    final p1 = Offset(size.width * 0.22, size.height * 0.35);
    final p2 = Offset(size.width * 0.85, size.height * 0.12);
    canvas.drawLine(p1, p2, paint);
    canvas.drawCircle(p1, 5, dotPaint);
    canvas.drawCircle(p2, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
