import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:video_player/video_player.dart';

class _Stroke {
  _Stroke(this.points);

  final List<Offset> points;
}

/// Full-screen playback for a saved clip. Drawing and playback stay on device.
class FullscreenReviewScreen extends StatefulWidget {
  const FullscreenReviewScreen({
    super.key,
    required this.videoPath,
    required this.club,
    required this.angleLabel,
    required this.recordedAt,
  });

  final String videoPath;
  final String club;
  final String angleLabel;
  final DateTime recordedAt;

  @override
  State<FullscreenReviewScreen> createState() => _FullscreenReviewScreenState();
}

class _FullscreenReviewScreenState extends State<FullscreenReviewScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _headerOpen = true;
  bool _drawing = false;
  double _speed = 1;
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redo = [];
  _Stroke? _draft;

  static const _frame = Duration(milliseconds: 33);
  static const _speeds = [0.25, 0.5, 1.0];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
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

  double get _progress {
    if (!_ready || _controller.value.duration.inMilliseconds == 0) return 0;
    return (_controller.value.position.inMilliseconds /
            _controller.value.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  void _togglePlay() {
    if (!_ready) return;
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _cycleSpeed() {
    final index = _speeds.indexOf(_speed);
    final next = _speeds[(index + 1) % _speeds.length];
    setState(() => _speed = next);
    _controller.setPlaybackSpeed(next);
  }

  void _seekFraction(double fraction) {
    if (!_ready) return;
    final duration = _controller.value.duration;
    final ms = (duration.inMilliseconds * fraction.clamp(0.0, 1.0) /
            _frame.inMilliseconds)
        .round() *
        _frame.inMilliseconds;
    _controller.seekTo(
      Duration(milliseconds: ms.clamp(0, duration.inMilliseconds)),
    );
  }

  void _undo() {
    if (_draft != null) {
      setState(() => _draft = null);
      return;
    }
    if (_strokes.isEmpty) return;
    setState(() => _redo.add(_strokes.removeLast()));
  }

  void _redoStroke() {
    if (_redo.isEmpty) return;
    setState(() => _strokes.add(_redo.removeLast()));
  }

  void _startStroke(Offset point, Size size) {
    _controller.pause();
    setState(() {
      _redo.clear();
      _draft = _Stroke([_norm(point, size)]);
    });
  }

  void _extendStroke(Offset point, Size size) {
    final draft = _draft;
    if (draft == null) return;
    setState(() => draft.points.add(_norm(point, size)));
  }

  void _endStroke() {
    final draft = _draft;
    if (draft == null) return;
    setState(() {
      if (draft.points.length > 1) _strokes.add(draft);
      _draft = null;
    });
  }

  Offset _norm(Offset point, Size size) {
    if (size.width <= 0 || size.height <= 0) return Offset.zero;
    return Offset(
      (point.dx / size.width).clamp(0.0, 1.0),
      (point.dy / size.height).clamp(0.0, 1.0),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _speedLabel => _speed == 1 ? '1x' : '${_speed}x';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.black),
                  if (_ready)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final videoSize = _controller.value.size;
                        final aspect = videoSize.width <= 0 ||
                                videoSize.height <= 0
                            ? 16 / 9
                            : videoSize.width / videoSize.height;
                        return Center(
                          child: AspectRatio(
                            aspectRatio: aspect,
                            child: LayoutBuilder(
                              builder: (context, box) {
                                final size = Size(box.maxWidth, box.maxHeight);
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    VideoPlayer(_controller),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: _drawing
                                          ? (details) => _startStroke(
                                                details.localPosition,
                                                size,
                                              )
                                          : null,
                                      onPanUpdate: _drawing
                                          ? (details) => _extendStroke(
                                                details.localPosition,
                                                size,
                                              )
                                          : null,
                                      onPanEnd: _drawing
                                          ? (_) => _endStroke()
                                          : null,
                                      child: CustomPaint(
                                        painter: _StrokePainter(
                                          strokes: [
                                            ..._strokes,
                                            if (_draft != null) _draft!,
                                          ],
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _RoundVideoButton(
                      icon: Icons.edit,
                      selected: _drawing,
                      onTap: () => setState(() => _drawing = !_drawing),
                    ),
                  ),
                ],
              ),
            ),
            _controlBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Material(
      color: const Color(0xFF6B7280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _headerOpen = !_headerOpen),
                  icon: Icon(
                    _headerOpen ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.club,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.type16.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Done',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_headerOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                '${widget.angleLabel}  ·  ${_formatDate(widget.recordedAt)}',
                style: AppTextStyles.type14.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _controlBar() {
    return ColoredBox(
      color: AppCaptureColors.scrubberTrackBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
        child: Row(
          children: [
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(
                _ready && _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
            Expanded(child: _TickScrubber(progress: _progress, onSeek: _seekFraction)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _cycleSpeed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppRadii.cardBorderRadius,
                ),
                child: Text(
                  _speedLabel,
                  style: AppTextStyles.type13.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _strokes.isEmpty && _draft == null ? null : _undo,
              icon: Icon(
                Icons.undo,
                color: _strokes.isEmpty && _draft == null
                    ? Colors.white38
                    : Colors.white,
              ),
            ),
            IconButton(
              onPressed: _redo.isEmpty ? null : _redoStroke,
              icon: Icon(
                Icons.redo,
                color: _redo.isEmpty ? Colors.white38 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundVideoButton extends StatelessWidget {
  const _RoundVideoButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ctaBrightBlue : Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _TickScrubber extends StatelessWidget {
  const _TickScrubber({required this.progress, required this.onSeek});

  final double progress;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            onSeek((details.localPosition.dx / width).clamp(0.0, 1.0));
          },
          onTapDown: (details) {
            onSeek((details.localPosition.dx / width).clamp(0.0, 1.0));
          },
          child: SizedBox(
            height: 36,
            width: width,
            child: CustomPaint(painter: _TickPainter(progress: progress)),
          ),
        );
      },
    );
  }
}

class _TickPainter extends CustomPainter {
  const _TickPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = AppCaptureColors.scrubberTickMinor
      ..strokeWidth = 2;
    const tickCount = 28;
    for (var i = 0; i <= tickCount; i++) {
      final x = size.width / tickCount * i;
      final tall = i % 4 == 0;
      canvas.drawLine(
        Offset(x, size.height / 2 - (tall ? 10 : 5)),
        Offset(x, size.height / 2 + (tall ? 10 : 5)),
        tickPaint,
      );
    }
    final x = size.width * progress;
    canvas.drawLine(
      Offset(x, 2),
      Offset(x, size.height - 2),
      Paint()
        ..color = AppCaptureColors.scrubberPlayhead
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.strokes});

  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final path = Path()
        ..moveTo(
          stroke.points.first.dx * size.width,
          stroke.points.first.dy * size.height,
        );
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
