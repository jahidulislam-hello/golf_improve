import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/capture_overlays.dart';
import 'review_swing_screen.dart';

enum SwingView { faceOn, downTheLine, sideOn }

enum CaptureMode { slowMo, swing, video }

/// Screens 1-3: live camera capture with alignment guide -> auto-detect
/// skeleton overlay, mode tabs, and record button.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  SwingView _view = SwingView.downTheLine;
  CaptureMode _mode = CaptureMode.swing;

  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _recordTimer;

  /// Simulated pose-detection state. Wire this up to a real ML Kit /
  /// TFLite pose model — set `_autoDetectReady` and `_joints` from your
  /// model's output on each camera frame instead of the timer below.
  bool _autoDetectReady = false;
  bool _showAlignmentTip = false;
  List<Joint> _joints = const [];

  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!camStatus.isGranted || !micStatus.isGranted) {
      setState(() {
        _permissionError =
            'Camera and microphone access are required to record your swing. '
            'Enable them in Settings to continue.';
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _permissionError = 'No camera found on this device.');
        return;
      }
      await _startCamera(_cameras.first);
    } catch (e) {
      setState(() => _permissionError = 'Could not start the camera: $e');
    }
  }

  Future<void> _startCamera(CameraDescription description) async {
    final previous = _controller;
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller = controller;
    await controller.initialize();
    await previous?.dispose();
    if (!mounted) return;
    setState(() {});
    _beginAutoDetectSimulation();
  }

  /// Mirrors the flow across screenshots 1 -> 2 -> 3: no detection yet, then
  /// "AUTO DETECT · READY" with an alignment tip, then the tip clears.
  void _beginAutoDetectSimulation() {
    setState(() {
      _autoDetectReady = false;
      _showAlignmentTip = false;
      _joints = const [];
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _autoDetectReady = true;
        _showAlignmentTip = true;
        _joints = defaultSwingJoints;
      });
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _showAlignmentTip = false);
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameras[_cameraIndex]);
  }

  Future<void> _toggleRecord() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isRecording) {
      _recordTimer?.cancel();
      final file = await controller.stopVideoRecording();
      setState(() => _isRecording = false);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReviewSwingScreen(videoPath: file.path),
        ),
      );
    } else {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: _permissionError != null
            ? _PermissionError(message: _permissionError!)
            : _controller == null || !_controller!.value.isInitialized
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.ctaBrightBlue,
                    ),
                  )
                : _buildCameraUi(),
      ),
    );
  }

  Widget _buildCameraUi() {
    final controller = _controller!;
    return Column(
      children: [
        _TopBar(
          isRecording: _isRecording,
          elapsed: _formatDuration(_elapsed),
          onClose: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 12),
        _ModeTabs(
          selected: _view,
          onSelect: (v) => setState(() => _view = v),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.0,
                    child: CameraPreview(controller),
                  ),
                  CustomPaint(
                    painter: _autoDetectReady
                        ? AutoDetectFramePainter(joints: _joints)
                        : const AlignmentGuidePainter(),
                  ),
                  if (_autoDetectReady)
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(child: _AutoDetectPill()),
                    ),
                  if (_showAlignmentTip)
                    const Positioned(
                      left: 16,
                      right: 16,
                      top: 64,
                      child: _AlignmentTipCard(),
                    ),
                  Positioned(
                    right: 12,
                    top: _autoDetectReady ? 64 : 14,
                    child: _SideIconRail(onFlip: _flipCamera),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _BottomControls(
          isRecording: _isRecording,
          onRecord: _toggleRecord,
          onFlip: _flipCamera,
        ),
        const SizedBox(height: 14),
        _CaptureModeTabs(
          selected: _mode,
          onSelect: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _PermissionError extends StatelessWidget {
  final String message;
  const _PermissionError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isRecording;
  final String elapsed;
  final VoidCallback onClose;

  const _TopBar({
    required this.isRecording,
    required this.elapsed,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _RoundIconButton(icon: Icons.close, onTap: onClose),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppCaptureColors.scrimPillBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle,
                    size: 10,
                    color: isRecording
                        ? AppCaptureColors.recordButtonRed
                        : Colors.white70),
                const SizedBox(width: 6),
                Text(elapsed,
                    style: AppTextStyles.type14
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Spacer(),
          _RoundIconButton(icon: Icons.crop_free, onTap: () {}),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppCaptureColors.scrimPillBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  final SwingView selected;
  final ValueChanged<SwingView> onSelect;
  const _ModeTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, SwingView value) {
      final isSelected = value == selected;
      return GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppCaptureColors.modeTabSelectedBg
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: AppTextStyles.type13.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppCaptureColors.modeTabSelectedText
                  : AppCaptureColors.modeTabUnselectedText,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppCaptureColors.scrimPillBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tab('Face On', SwingView.faceOn),
          tab('Down the Line', SwingView.downTheLine),
          tab('Side On', SwingView.sideOn),
        ],
      ),
    );
  }
}

class _AutoDetectPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppCaptureColors.autoDetectPillBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text('AUTO DETECT · READY',
              style: AppTextStyles.type11.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              )),
        ],
      ),
    );
  }
}

class _AlignmentTipCard extends StatelessWidget {
  const _AlignmentTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCaptureColors.alignmentCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALIGNMENT',
              style: AppTextStyles.type11.copyWith(
                color: AppCaptureColors.autoDetectGreen,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              )),
          const SizedBox(height: 4),
          Text('Step back 40cm',
              style: AppTextStyles.type18.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.55,
              minHeight: 6,
              backgroundColor: AppCaptureColors.alignmentProgressTrack,
              color: AppCaptureColors.autoDetectGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideIconRail extends StatelessWidget {
  final VoidCallback onFlip;
  const _SideIconRail({required this.onFlip});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RoundIconButton(icon: icon, onTap: onTap),
        );
    return Column(
      children: [
        btn(Icons.menu, () {}),
        btn(Icons.add, () {}),
        btn(Icons.crop_square, onFlip),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onRecord;
  final VoidCallback onFlip;

  const _BottomControls({
    required this.isRecording,
    required this.onRecord,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRecord,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppCaptureColors.recordButtonRing, width: 4),
              ),
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: AppCaptureColors.recordButtonRed,
                  borderRadius:
                      BorderRadius.circular(isRecording ? 8 : 32),
                ),
              ),
            ),
          ),
          _RoundIconButton(icon: Icons.cameraswitch, onTap: onFlip),
        ],
      ),
    );
  }
}

class _CaptureModeTabs extends StatelessWidget {
  final CaptureMode selected;
  final ValueChanged<CaptureMode> onSelect;
  const _CaptureModeTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, CaptureMode value) {
      final isSelected = value == selected;
      return GestureDetector(
        onTap: () => onSelect(value),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.type13.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isSelected
                    ? AppCaptureColors.captureTabActiveDot
                    : AppCaptureColors.captureTabInactive,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppCaptureColors.captureTabActiveDot,
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        tab('SLOW-MO', CaptureMode.slowMo),
        tab('SWING', CaptureMode.swing),
        tab('VIDEO', CaptureMode.video),
      ],
    );
  }
}
