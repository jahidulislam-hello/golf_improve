import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:video_player/video_player.dart';

/// Shared swing-video preview with real network/file playback via
/// [video_player]. Shows play/pause, progress, optional annotation lines,
/// and expand / target overlay buttons.
class VideoPreview extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final bool showAnnotationLines;
  final bool showOverlayButtons;
  final VoidCallback? onExpand;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final bool autoPlay;

  /// Kept for older call sites that still pass fake playback state.
  /// Ignored when [videoUrl] is set — the player owns real state.
  final Duration? position;
  final Duration? total;
  final bool? isPlaying;
  final VoidCallback? onPlayToggle;

  const VideoPreview({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.showAnnotationLines = false,
    this.showOverlayButtons = true,
    this.onExpand,
    this.aspectRatio = 16 / 10,
    this.borderRadius = BorderRadius.zero,
    this.autoPlay = false,
    this.position,
    this.total,
    this.isPlaying,
    this.onPlayToggle,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _hasError = false;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    final url = widget.videoUrl?.trim() ?? '';
    if (url.isEmpty || !url.startsWith('http')) {
      _disposeController();
      if (mounted) {
        setState(() {
          _initializing = false;
          _hasError = false;
          _loadedUrl = null;
        });
      }
      return;
    }

    if (_loadedUrl == url && _controller != null) return;

    _disposeController();
    setState(() {
      _initializing = true;
      _hasError = false;
      _loadedUrl = url;
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    controller.addListener(_onTick);

    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }
      setState(() => _initializing = false);
      if (widget.autoPlay) {
        await controller.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = true;
      });
    }
  }

  void _disposeController() {
    final c = _controller;
    _controller = null;
    if (c != null) {
      c.removeListener(_onTick);
      c.dispose();
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      widget.onPlayToggle?.call();
      return;
    }
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    widget.onPlayToggle?.call();
  }

  Future<void> _seekRelative(Offset local, double width) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || width <= 0) return;
    final fraction = (local.dx / width).clamp(0.0, 1.0);
    final target = c.value.duration * fraction;
    await c.seekTo(target);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized && !_hasError;
    final playing = ready ? c.value.isPlaying : (widget.isPlaying ?? false);
    final position = ready
        ? c.value.position
        : (widget.position ?? Duration.zero);
    final total = ready
        ? c.value.duration
        : (widget.total ?? Duration.zero);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    final thumb = widget.thumbnailUrl ?? '';
    final hasNetworkThumb = thumb.startsWith('http');

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              )
            else if (hasNetworkThumb)
              Image.network(
                thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _VideoPlaceholder(),
              )
            else
              const _VideoPlaceholder(),
            // Tap-to-pause while playing (below chrome so controls stay tappable).
            if (playing && ready)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _togglePlay,
                ),
              ),
            if (_initializing)
              const ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (_hasError)
              const ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Icon(Icons.error_outline,
                      color: Colors.white70, size: 32),
                ),
              ),
            if (widget.showAnnotationLines) const _SwingPlaneOverlay(),
            if (widget.showOverlayButtons)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _OverlayCircleButton(
                      icon: Icons.open_in_full,
                      background: AppColors.ctaBrightBlue,
                      onTap: widget.onExpand,
                    ),
                    const SizedBox(height: 8),
                    const _OverlayCircleButton(
                      icon: Icons.track_changes,
                      background: Colors.black38,
                    ),
                  ],
                ),
              ),
            if (!playing || !ready)
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scrub to the moment you want to analyse. Then draw.',
                    style:
                        AppTextStyles.type11.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: ready
                                  ? (d) => _seekRelative(
                                        d.localPosition,
                                        constraints.maxWidth,
                                      )
                                  : null,
                              onHorizontalDragUpdate: ready
                                  ? (d) => _seekRelative(
                                        d.localPosition,
                                        constraints.maxWidth,
                                      )
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.ctaBrightBlue,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_fmt(position)}/${_fmt(total)}',
                        style: AppTextStyles.type11
                            .copyWith(color: Colors.white70),
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

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _OverlayCircleButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final VoidCallback? onTap;
  const _OverlayCircleButton({
    required this.icon,
    required this.background,
    this.onTap,
  });

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
