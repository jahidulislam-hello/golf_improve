import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import '../controllers/review_swing_fullscreen_controller.dart';
import '../widgets/shared_widgets.dart';

/// Screen 6 — Review Swing fullscreen editor.
/// Reached from Screen 5 by tapping the fullscreen icon on the video.
/// Shows the full-bleed frame, a pencil (edit/draw) button, a collapse
/// button, and a tick-mark scrubber with play / speed / reset / redo
/// controls along the bottom.
class ReviewSwingFullscreenScreen extends StatefulWidget {
  const ReviewSwingFullscreenScreen({super.key});

  @override
  State<ReviewSwingFullscreenScreen> createState() =>
      _ReviewSwingFullscreenScreenState();
}

class _ReviewSwingFullscreenScreenState
    extends State<ReviewSwingFullscreenScreen> {
  final ReviewSwingFullscreenController controller =
      ReviewSwingFullscreenController();

  static String _formatSpeed(double speed) {
    return speed == speed.roundToDouble()
        ? speed.toInt().toString()
        : speed.toString();
  }

  void _save() {
    controller.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Swing saved.')),
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
                      Text('Review Swing',
                          style: AppTextStyles.sectionHeader
                              .copyWith(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _save,
                        child: Text(
                          'Save',
                          style: AppTextStyles.type16.copyWith(
                            color: AppColors.ctaBrightBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full-bleed placeholder frame (address position).
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF8FC1E3), Color(0xFF4E8A52)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.golf_course,
                              color: Colors.white38, size: 64),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 90,
                        child: Column(
                          children: [
                            CircleIconButton(
                              icon: Icons.edit,
                              background: Colors.black87,
                              iconColor: Colors.white,
                              onTap: controller.toggleEditing,
                              size: 44,
                            ),
                            const SizedBox(height: 12),
                            CircleIconButton(
                              icon: Icons.close_fullscreen,
                              background: AppColors.ctaBrightBlue,
                              iconColor: Colors.white,
                              onTap: () => Navigator.of(context).maybePop(),
                              size: 44,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.primaryNavy,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: AppColors.ctaBrightBlue,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: AppColors.ctaBrightBlue,
                        ),
                        child: Slider(
                          value: controller.scrubValue,
                          onChanged: controller.setScrub,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: controller.togglePlay,
                            child: Icon(
                              controller.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: controller.cycleSpeed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.ctaBrightBlue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${_formatSpeed(controller.playbackSpeed)}x',
                                style: AppTextStyles.type13.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: controller.resetSpeed,
                            child: const Icon(Icons.replay,
                                color: Colors.white54, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _TickRuler(value: controller.scrubValue)),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.forward,
                                color: Colors.white54, size: 18),
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
      },
    );
  }
}

/// The thin tick-mark scrubber ruler with a highlighted center indicator,
/// matching the frame-by-frame scrub bar in the reference design.
class _TickRuler extends StatelessWidget {
  final double value;
  const _TickRuler({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        painter: _TickRulerPainter(value: value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TickRulerPainter extends CustomPainter {
  final double value;
  _TickRulerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;
    const tickCount = 40;
    for (int i = 0; i <= tickCount; i++) {
      final x = size.width * i / tickCount;
      final isTall = i % 5 == 0;
      canvas.drawLine(
        Offset(x, size.height / 2 - (isTall ? 8 : 4)),
        Offset(x, size.height / 2 + (isTall ? 8 : 4)),
        tickPaint,
      );
    }
    final centerX = size.width * value;
    final centerPaint = Paint()
      ..color = AppColors.ctaBrightBlue
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TickRulerPainter oldDelegate) =>
      oldDelegate.value != value;
}
