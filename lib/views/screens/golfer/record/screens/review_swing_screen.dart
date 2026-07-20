import 'dart:io';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:video_player/video_player.dart';

import 'analysing_screen.dart';

/// Screens 4-5: review the just-recorded clip, scrub through it, pick a
/// playback speed, then either send it for AI analysis or discard it.
class ReviewSwingScreen extends StatefulWidget {
  final String videoPath;
  const ReviewSwingScreen({super.key, required this.videoPath});

  @override
  State<ReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<ReviewSwingScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
      });
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    _controller.setPlaybackSpeed(speed);
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _seekBy(Duration delta) {
    final target = _controller.value.position + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _controller.value.duration
            ? _controller.value.duration
            : target);
    _controller.seekTo(clamped);
  }

  void _analyze() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnalysingScreen()),
    );
  }

  void _discard() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _RoundBackButton(onTap: () => Navigator.of(context).pop()),
        ),
        leadingWidth: 56,
        title: Text('Review Swing', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.ctaBrightBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: Text('Save',
                  style: AppTextStyles.buttonLabel.copyWith(fontSize: 15)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                color: Colors.black,
                child: _initialized
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScrubberCard(
                      controller: _controller,
                      initialized: _initialized,
                      onPlay: _togglePlay,
                      onRewind: () =>
                          _seekBy(const Duration(milliseconds: -200)),
                      onForward: () =>
                          _seekBy(const Duration(milliseconds: 200)),
                      speed: _speed,
                      onSpeedChanged: _setSpeed,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ctaBrightBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _analyze,
                        icon: const Icon(Icons.psychology_alt_outlined),
                        label: Text('Analyze with AI',
                            style: AppTextStyles.buttonLabel),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.destructiveRed,
                          side: BorderSide(color: AppColors.borderLightGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _discard,
                        icon: const Icon(Icons.close),
                        label: Text('Discard Clip',
                            style: AppTextStyles.buttonLabel.copyWith(
                                color: AppColors.destructiveRed)),
                      ),
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

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.pillInactive,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chevron_left,
            color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

class _ScrubberCard extends StatelessWidget {
  final VideoPlayerController controller;
  final bool initialized;
  final VoidCallback onPlay;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  const _ScrubberCard({
    required this.controller,
    required this.initialized,
    required this.onPlay,
    required this.onRewind,
    required this.onForward,
    required this.speed,
    required this.onSpeedChanged,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final position = initialized ? controller.value.position : Duration.zero;
    final duration = initialized ? controller.value.duration : Duration.zero;
    final progress = (duration.inMilliseconds == 0)
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onPlay,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.borderLightGray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    initialized && controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(_fmt(position),
                  style: AppTextStyles.type16
                      .copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              _CircleIconButton(icon: Icons.replay, onTap: onRewind),
              const SizedBox(width: 8),
              _CircleIconButton(icon: Icons.forward, onTap: onForward),
            ],
          ),
          const SizedBox(height: 14),
          _ScrubberRuler(
            progress: progress.clamp(0.0, 1.0),
            onScrub: (v) {
              if (!initialized) return;
              controller.seekTo(duration * v);
            },
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [0.25, 0.5, 1.0].map((s) {
              final selected = s == speed;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => onSpeedChanged(s),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppCaptureColors.speedPillActiveBg
                          : AppCaptureColors.speedPillInactiveBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${s == 1.0 ? '1' : s}x',
                      style: AppTextStyles.type13.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ctaBrightBlue),
        ),
        child: Icon(icon, color: AppColors.ctaBrightBlue, size: 16),
      ),
    );
  }
}

/// Ruler-style scrubber: many minor ticks + a filled played-track + a tall
/// playhead tick, draggable — matches the timeline in screenshots 4-5.
class _ScrubberRuler extends StatelessWidget {
  final double progress;
  final ValueChanged<double> onScrub;
  const _ScrubberRuler({required this.progress, required this.onScrub});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return GestureDetector(
        onHorizontalDragUpdate: (details) {
          final v = (details.localPosition.dx / width).clamp(0.0, 1.0);
          onScrub(v);
        },
        onTapDown: (details) {
          final v = (details.localPosition.dx / width).clamp(0.0, 1.0);
          onScrub(v);
        },
        child: SizedBox(
          height: 44,
          width: width,
          child: CustomPaint(
            painter: _RulerPainter(progress: progress),
          ),
        ),
      );
    });
  }
}

class _RulerPainter extends CustomPainter {
  final double progress;
  const _RulerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppCaptureColors.scrubberTrackBg;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(10));
    canvas.drawRRect(rrect, bg);

    final tickPaint = Paint()
      ..color = AppCaptureColors.scrubberTickMinor
      ..strokeWidth = 2;
    const tickCount = 40;
    for (var i = 0; i <= tickCount; i++) {
      final x = size.width / tickCount * i;
      final tall = i % 5 == 0;
      canvas.drawLine(
        Offset(x, size.height / 2 - (tall ? 10 : 5)),
        Offset(x, size.height / 2 + (tall ? 10 : 5)),
        tickPaint,
      );
    }

    final playedPaint = Paint()..color = AppCaptureColors.scrubberPlayed;
    final playheadX = size.width * progress;
    canvas.drawLine(
      Offset(playheadX, 4),
      Offset(playheadX, size.height - 4),
      Paint()
        ..color = AppCaptureColors.scrubberPlayhead
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(playheadX, size.height / 2), 6, playedPaint);
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}


