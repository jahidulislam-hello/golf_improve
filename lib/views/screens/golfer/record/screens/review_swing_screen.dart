import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../models/capture_session.dart';
import 'analysing_screen.dart';

/// Review the just-recorded clip, then upload + AI-analyse via AnalysingScreen.
class ReviewSwingScreen extends StatefulWidget {
  final CaptureSession session;

  const ReviewSwingScreen({super.key, required this.session});

  @override
  State<ReviewSwingScreen> createState() => _ReviewSwingScreenState();
}

class _ReviewSwingScreenState extends State<ReviewSwingScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _saving = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.session.videoPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
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

  void _seekFraction(double fraction) {
    if (!_initialized) return;
    final duration = _controller.value.duration;
    _controller.seekTo(duration * fraction.clamp(0.0, 1.0));
  }

  CaptureSession _sessionWithPlayerDuration() {
    final playerSec = _initialized
        ? _controller.value.duration.inMilliseconds / 1000.0
        : widget.session.durationSeconds;
    final duration = playerSec > 0 ? playerSec : widget.session.durationSeconds;
    return CaptureSession(
      videoPath: widget.session.videoPath,
      clubType: widget.session.clubType,
      cameraAngle: widget.session.cameraAngle,
      recordingMode: widget.session.recordingMode,
      handedness: widget.session.handedness,
      durationSeconds: duration,
      trimStart: 0,
      trimEnd: duration,
      poseSamples: widget.session.poseSamples,
      previewWidth: widget.session.previewWidth,
      previewHeight: widget.session.previewHeight,
      deviceModel: widget.session.deviceModel,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final session = _sessionWithPlayerDuration();
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );

      await service.uploadSwingForAnalysis(
        videoPath: session.videoPath,
        clubType: session.clubType,
        cameraAngle: session.cameraAngle,
        recordingMode: session.recordingMode,
        handedness: session.handedness,
        duration: session.durationSeconds,
        trimStart: session.trimStart,
        trimEnd: session.effectiveTrimEnd,
        cameraData: SwingTelemetryBuilder.cameraData(
          cameraAngle: session.cameraAngle,
          width: session.previewWidth,
          height: session.previewHeight,
          deviceModel: session.deviceModel,
        ),
        calibration: SwingTelemetryBuilder.calibration(),
        swingPhases: SwingTelemetryBuilder.swingPhases(
          durationSeconds: session.durationSeconds,
          samples: session.poseSamples,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swing saved.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _analyze() {
    final session = _sessionWithPlayerDuration();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysingScreen(session: session),
      ),
    );
  }

  Future<void> _openFullscreen() async {
    if (!_initialized) return;
    final wasPlaying = _controller.value.isPlaying;
    final position = _controller.value.position;
    await _controller.pause();

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReviewFullscreenPlayer(
          videoPath: widget.session.videoPath,
          initialPosition: position,
          initialSpeed: _speed,
          autoPlay: wasPlaying,
        ),
      ),
    );
  }

  void _discard() {
    Navigator.of(context).pop();
  }

  double get _progress {
    if (!_initialized) return 0;
    final duration = _controller.value.duration.inMilliseconds;
    if (duration <= 0) return 0;
    return (_controller.value.position.inMilliseconds / duration)
        .clamp(0.0, 1.0);
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
            child: Center(
              child: SizedBox(
                width: 75,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ctaBrightBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTextStyles.type13.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_initialized)
                      FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    else
                      const Center(
                        child:
                            CircularProgressIndicator(color: Colors.white),
                      ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _initialized ? _openFullscreen : null,
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _VideoProgressBar(
                progress: _progress,
                onSeek: _seekFraction,
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
                            borderRadius: AppRadii.buttonBorderRadius,
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
                          side:
                              const BorderSide(color: AppColors.borderLightGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.buttonBorderRadius,
                          ),
                        ),
                        onPressed: _discard,
                        icon: const Icon(Icons.close),
                        label: Text('Discard Clip',
                            style: AppTextStyles.buttonLabel
                                .copyWith(color: AppColors.destructiveRed)),
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

class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({
    required this.progress,
    required this.onSeek,
  });

  final double progress;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: AppColors.ctaBrightBlue,
        inactiveTrackColor: AppColors.borderLightGray,
        thumbColor: AppColors.ctaBrightBlue,
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: onSeek,
      ),
    );
  }
}

/// Fullscreen local-file player opened from the expand icon.
class _ReviewFullscreenPlayer extends StatefulWidget {
  const _ReviewFullscreenPlayer({
    required this.videoPath,
    required this.initialPosition,
    required this.initialSpeed,
    required this.autoPlay,
  });

  final String videoPath;
  final Duration initialPosition;
  final double initialSpeed;
  final bool autoPlay;

  @override
  State<_ReviewFullscreenPlayer> createState() =>
      _ReviewFullscreenPlayerState();
}

class _ReviewFullscreenPlayerState extends State<_ReviewFullscreenPlayer> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) async {
        if (!mounted) return;
        await _controller.setPlaybackSpeed(widget.initialSpeed);
        await _controller.seekTo(widget.initialPosition);
        if (widget.autoPlay) await _controller.play();
        setState(() => _ready = true);
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  double get _progress {
    if (!_ready) return 0;
    final duration = _controller.value.duration.inMilliseconds;
    if (duration <= 0) return 0;
    return (_controller.value.position.inMilliseconds / duration)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _ready
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio == 0
                          ? 16 / 9
                          : _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 72,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      activeTrackColor: AppColors.ctaBrightBlue,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.ctaBrightBlue,
                    ),
                    child: Slider(
                      value: _progress,
                      onChanged: (v) {
                        if (!_ready) return;
                        final d = _controller.value.duration;
                        _controller.seekTo(d * v);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: !_ready
                        ? null
                        : () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                    icon: Icon(
                      _ready && _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
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
    final ms =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final position = initialized ? controller.value.position : Duration.zero;
    final duration = initialized ? controller.value.duration : Duration.zero;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: AppRadii.cardBorderRadius,
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
            progress: duration.inMilliseconds == 0
                ? 0
                : (position.inMilliseconds / duration.inMilliseconds)
                    .clamp(0.0, 1.0),
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
                      borderRadius: AppRadii.cardBorderRadius,
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
