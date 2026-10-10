import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:video_player/video_player.dart';
import '../controllers/review_swing_fullscreen_controller.dart';
import '../widgets/shared_widgets.dart';

/// Screen 6 — Review Swing fullscreen editor with real video playback.
class ReviewSwingFullscreenScreen extends StatefulWidget {
  const ReviewSwingFullscreenScreen({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
  });

  final String? videoUrl;
  final String? thumbnailUrl;

  @override
  State<ReviewSwingFullscreenScreen> createState() =>
      _ReviewSwingFullscreenScreenState();
}

class _ReviewSwingFullscreenScreenState
    extends State<ReviewSwingFullscreenScreen> {
  final ReviewSwingFullscreenController controller =
      ReviewSwingFullscreenController();

  VideoPlayerController? _player;
  bool _ready = false;
  bool _hasError = false;
  bool _scrubbing = false;

  static String _formatSpeed(double speed) {
    return speed == speed.roundToDouble()
        ? speed.toInt().toString()
        : speed.toString();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
    _initPlayer();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    _disposePlayer();
    controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final p = _player;
    if (p != null && p.value.isInitialized) {
      p.setPlaybackSpeed(controller.playbackSpeed);
      if (controller.isPlaying && !p.value.isPlaying) {
        p.play();
      } else if (!controller.isPlaying && p.value.isPlaying) {
        p.pause();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _initPlayer() async {
    final url = widget.videoUrl?.trim() ?? '';
    if (url.isEmpty || !url.startsWith('http')) return;

    final player = VideoPlayerController.networkUrl(Uri.parse(url));
    _player = player;
    player.addListener(_onPlayerTick);

    try {
      await player.initialize();
      await player.setLooping(true);
      if (!mounted || _player != player) {
        await player.dispose();
        return;
      }
      setState(() => _ready = true);
      if (controller.isPlaying) {
        await player.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _disposePlayer() {
    final p = _player;
    _player = null;
    if (p != null) {
      p.removeListener(_onPlayerTick);
      p.dispose();
    }
  }

  void _onPlayerTick() {
    final p = _player;
    if (p == null || !p.value.isInitialized || _scrubbing) return;
    final duration = p.value.duration;
    if (duration.inMilliseconds > 0) {
      controller.setScrub(
        p.value.position.inMilliseconds / duration.inMilliseconds,
      );
    }
  }

  Future<void> _onScrubChanged(double value) async {
    _scrubbing = true;
    controller.setScrub(value);
    final p = _player;
    if (p != null && p.value.isInitialized) {
      final duration = p.value.duration;
      await p.seekTo(duration * value);
    }
    _scrubbing = false;
  }

  void _save() {
    controller.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Swing saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _player;
    final thumb = widget.thumbnailUrl ?? '';

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
                      if (_ready && p != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: p.value.size.width,
                            height: p.value.size.height,
                            child: VideoPlayer(p),
                          ),
                        )
                      else if (thumb.startsWith('http'))
                        Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _FullscreenPlaceholder(),
                        )
                      else
                        const _FullscreenPlaceholder(),
                      if (!_ready && !_hasError && (widget.videoUrl ?? '').isNotEmpty)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      if (_hasError)
                        const Center(
                          child: Icon(Icons.error_outline,
                              color: Colors.white70, size: 40),
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
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14),
                          activeTrackColor: AppColors.ctaBrightBlue,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: AppColors.ctaBrightBlue,
                        ),
                        child: Slider(
                          value: controller.scrubValue.clamp(0.0, 1.0),
                          onChanged: _onScrubChanged,
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
                          Expanded(
                              child: _TickRuler(value: controller.scrubValue)),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final player = _player;
                              if (player == null ||
                                  !player.value.isInitialized) {
                                return;
                              }
                              final next = player.value.position +
                                  const Duration(seconds: 1);
                              final max = player.value.duration;
                              await player.seekTo(next > max ? max : next);
                            },
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

class _FullscreenPlaceholder extends StatelessWidget {
  const _FullscreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FC1E3), Color(0xFF4E8A52)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.golf_course, color: Colors.white38, size: 64),
      ),
    );
  }
}

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
    final centerX = size.width * value.clamp(0.0, 1.0);
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
