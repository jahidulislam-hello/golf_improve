import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/services/offline_swing_queue.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../home/compare_swings/compare_swings_screen.dart';
import '../../library/screens/share_with_coach_screen.dart';
import '../models/capture_session.dart';
import 'fullscreen_review_screen.dart';
import 'practice_coach_chat_screen.dart';

/// Review the just-recorded clip. Trimming and local save run in the
/// background. Upload waits until the device is online.
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
  bool _discarded = false;
  double _speed = 1.0;
  String? _queuedKey;
  final DateTime _recordedAt = DateTime.now();

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
    _saveInBackground();
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

  CaptureSession _trimmedSession() {
    final playerSec = _initialized
        ? _controller.value.duration.inMilliseconds / 1000.0
        : widget.session.durationSeconds;
    final duration = playerSec > 0 ? playerSec : widget.session.durationSeconds;
    var start = 0.0;
    var end = duration;
    if (duration > 1.5) {
      start = 0.2;
      end = duration - 0.2;
      if (end <= start) end = duration;
    }
    return CaptureSession(
      videoPath: widget.session.videoPath,
      clubType: widget.session.clubType,
      cameraAngle: widget.session.cameraAngle,
      recordingMode: widget.session.recordingMode,
      handedness: widget.session.handedness,
      durationSeconds: duration,
      trimStart: start,
      trimEnd: end,
      poseSamples: widget.session.poseSamples,
      previewWidth: widget.session.previewWidth,
      previewHeight: widget.session.previewHeight,
      deviceModel: widget.session.deviceModel,
    ).sanitized();
  }

  /// Copies the clip, stores trim metadata, and syncs only when online.
  Future<void> _saveInBackground() async {
    if (_saving) return;
    setState(() => _saving = true);
    File? copy;
    try {
      final session = _trimmedSession();
      final source = File(session.videoPath);
      if (!await source.exists() || _discarded) return;

      final docs = await getApplicationDocumentsDirectory();
      final folder = Directory('${docs.path}/swings');
      await folder.create(recursive: true);
      final localId = 'mob_${DateTime.now().microsecondsSinceEpoch}';
      final idempotencyKey = 'sync_$localId';
      copy = File('${folder.path}/$localId.mp4');
      await source.copy(copy.path);
      if (_discarded) {
        if (await copy.exists()) await copy.delete();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final fileSize = await copy.length();
      _queuedKey = idempotencyKey;
      await OfflineSwingQueue.enqueue(prefs, {
        'local_id': localId,
        'idempotencyKey': idempotencyKey,
        'client_session_id': 'session_$localId',
        'videoPath': copy.path,
        'clubType': session.clubType,
        'cameraAngle': session.cameraAngle,
        'recordingMode': session.recordingMode,
        'handedness': session.handedness,
        'duration': session.durationSeconds,
        'trimStart': session.trimStart,
        'trimEnd': session.effectiveTrimEnd,
        'recorded_at': DateTime.now().toUtc().toIso8601String(),
        'fileSize': fileSize,
        'fileType': 'video/mp4',
      });
      if (_discarded) {
        await _removeQueued(prefs);
        return;
      }

      try {
        final service = GolferService(
          apiService: ApiService(sharedPreferences: prefs),
        );
        await service.syncPendingSwings();
      } catch (_) {}
    } catch (_) {
      if (copy != null && await copy.exists() && _queuedKey == null) {
        await copy.delete();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeQueued(SharedPreferences prefs) async {
    final key = _queuedKey;
    if (key == null) return;
    final items = await OfflineSwingQueue.load(prefs);
    items.removeWhere((item) => item['idempotencyKey'] == key);
    await OfflineSwingQueue.save(prefs, items);
    _queuedKey = null;
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          title: const Text('Discard Clip', style: AppTextStyles.sectionHeader),
          content: const Text(
            'Discard this clip? It will be removed from this device.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard',
                style: AppTextStyles.buttonLabel.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (discard == true) _discard();
  }

  void _discard() {
    _discarded = true;
    SharedPreferences.getInstance().then(_removeQueued);
    Navigator.of(context).pop();
  }

  String get _angleLabel {
    final angle = widget.session.cameraAngle.toLowerCase();
    if (angle.contains('down') || angle.contains('line')) {
      return 'Down-the-Line';
    }
    return 'Face-On';
  }

  Future<void> _openFullscreen() async {
    if (!_initialized) return;
    await _controller.pause();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenReviewScreen(
          videoPath: widget.session.videoPath,
          club: widget.session.clubType,
          angleLabel: _angleLabel,
          recordedAt: _recordedAt,
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'practice_note_${widget.session.videoPath.hashCode}';
    final existing = prefs.getString(key) ?? '';
    if (!mounted) return;
    final controller = TextEditingController(text: existing);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          title: const Text('Add Note', style: AppTextStyles.sectionHeader),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Write a practice note for this swing',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved == true) {
      await prefs.setString(key, controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved.')),
        );
      }
    }
    controller.dispose();
  }

  void _shareWithCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareWithCoachScreen(
          videoUrl: widget.session.videoPath,
        ),
      ),
    );
  }

  void _compare() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompareSwingsScreen()),
    );
  }

  void _talkWithCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PracticeCoachChatScreen()),
    );
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
        title: const Text('Review Swing', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Saving…',
                  style: AppTextStyles.caption,
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
                          _seekBy(const Duration(milliseconds: -33)),
                      onForward: () =>
                          _seekBy(const Duration(milliseconds: 33)),
                      speed: _speed,
                      onSpeedChanged: _setSpeed,
                    ),
                    const SizedBox(height: 16),
                    _ReviewActions(
                      onDraw: _openFullscreen,
                      onCompare: _compare,
                      onNote: _addNote,
                      onShare: _shareWithCoach,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ctaBrightBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.buttonBorderRadius,
                          ),
                        ),
                        onPressed: _talkWithCoach,
                        child: const Text(
                          'Talk with AI Golf Coach',
                          style: AppTextStyles.buttonLabel,
                        ),
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
                        onPressed: _confirmDiscard,
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

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.onDraw,
    required this.onCompare,
    required this.onNote,
    required this.onShare,
  });

  final VoidCallback onDraw;
  final VoidCallback onCompare;
  final VoidCallback onNote;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    Widget action(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            height: 84,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderLightGray),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.buttonBorderRadius,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: AppColors.ctaBrightBlue),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.type11.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        action(Icons.draw, 'Draw', onDraw),
        action(Icons.compare, 'Compare', onCompare),
        action(Icons.note_add_outlined, 'Add Note', onNote),
        action(Icons.ios_share, 'Share with Coach', onShare),
      ],
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
              _CircleIconButton(icon: Icons.skip_previous, onTap: onRewind),
              const SizedBox(width: 8),
              _CircleIconButton(icon: Icons.skip_next, onTap: onForward),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ctaBrightBlue),
        ),
        child: Icon(icon, color: AppColors.ctaBrightBlue, size: 22),
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
