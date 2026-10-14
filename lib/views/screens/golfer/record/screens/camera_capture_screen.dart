import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pose_detector_service.dart';
import '../models/camera_categories.dart';
import '../models/capture_session.dart';
import '../widgets/capture_overlays.dart';
import 'review_swing_screen.dart';

/// AI Camera: live preview, category-driven angle/mode selectors, ML Kit pose,
/// then hand-off to Review Swing with telemetry for upload.
class CameraCaptureScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const CameraCaptureScreen({super.key, this.onClose});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();

  final PoseDetectorService _poseService = PoseDetectorService();
  final List<PoseSample> _poseSamples = [];

  bool _isStreaming = false;
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _recordTimer;
  Stopwatch? _recordStopwatch;
  static const Duration _minRecordDuration = Duration(seconds: 2);

  bool _autoDetectReady = false;
  bool _showAlignmentTip = false;
  bool _didShowAlignmentTip = false;
  List<Joint?> _joints = const [];
  List<Joint?> _smoothedJoints = const [];
  int _previewWidth = 1920;
  int _previewHeight = 1080;

  String? _permissionError;
  String? _categoriesError;
  bool _loadingCategories = true;

  List<String> _cameraAngles = const ['Face On', 'Down The Line'];
  List<String> _recordingModes = const ['slow-mo', 'swing', 'video'];
  List<SwingCategory> _categories = const [];

  String _selectedAngle = 'Down The Line';
  String _selectedMode = 'swing';
  SwingCategory? _selectedCategory;
  String _handedness = 'right';

  bool get _isUsingFrontCamera {
    final controller = _controller;
    if (controller == null) return false;
    return controller.description.lensDirection == CameraLensDirection.front;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_initCamera(), _loadCategories()]);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getCameraCategories();
      final dataMap = response['data'];
      if (dataMap is Map) {
        final data = CameraCategoriesData.fromJson(
          Map<String, dynamic>.from(dataMap),
        );
        _applyCategories(data);
      }

      final user = ApiService(sharedPreferences: prefs).getUserData();
      final rawHand =
          (user?['handedness'] ?? user?['dominantHand'] ?? user?['hand'])
              ?.toString()
              .toLowerCase();
      if (rawHand != null && rawHand.contains('left')) {
        _handedness = 'left';
      }
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  void _applyCategories(CameraCategoriesData data) {
    final classified = CaptureFieldNormalizer.classifyLists(
      cameraAngles: data.cameraAngles,
      recordingModes: data.recordingModes,
    );
    _cameraAngles = classified.angles;
    _recordingModes = classified.modes;

    // Keep only club-like categories (ignore angle/mode strings wrongly nested).
    final clubCats = data.categories
        .where((c) => CaptureFieldNormalizer.looksLikeClubName(c.name))
        .toList();
    _categories = clubCats.isNotEmpty ? clubCats : data.categories;

    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
      _applyCategoryDefaults(_selectedCategory!);
    } else {
      _selectedAngle = CaptureFieldNormalizer.cameraAngle(
        _cameraAngles.contains(_selectedAngle)
            ? _selectedAngle
            : _cameraAngles.first,
      );
      _selectedMode = CaptureFieldNormalizer.recordingMode(
        _recordingModes.contains(_selectedMode)
            ? _selectedMode
            : _recordingModes.first,
      );
    }
  }

  void _applyCategoryDefaults(SwingCategory category) {
    final classified = CaptureFieldNormalizer.classifyLists(
      cameraAngles: category.cameraAngles.isNotEmpty
          ? category.cameraAngles
          : _cameraAngles,
      recordingModes: category.recordingModes.isNotEmpty
          ? category.recordingModes
          : _recordingModes,
    );
    _cameraAngles = classified.angles;
    _recordingModes = classified.modes;

    final preferredAngle = CaptureFieldNormalizer.cameraAngle(
      category.defaultCameraAngle,
    );
    final preferredMode = CaptureFieldNormalizer.recordingMode(
      category.defaultRecordingMode,
    );

    _selectedAngle = _cameraAngles.contains(preferredAngle)
        ? preferredAngle
        : (_cameraAngles.isNotEmpty ? _cameraAngles.first : preferredAngle);
    _selectedMode = _recordingModes.contains(preferredMode)
        ? preferredMode
        : (_recordingModes.isNotEmpty ? _recordingModes.first : preferredMode);
  }

  Future<void> _initCamera() async {
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
      final preferredCamera =
          _findCamera(
            preferredDirections: const [
              CameraLensDirection.back,
              CameraLensDirection.external,
              CameraLensDirection.front,
            ],
          ) ??
          _cameras.first;
      await _startCamera(preferredCamera);
    } catch (e) {
      setState(() => _permissionError = 'Could not start the camera: $e');
    }
  }

  CameraDescription? _findCamera({
    required List<CameraLensDirection> preferredDirections,
  }) {
    for (final direction in preferredDirections) {
      for (var i = 0; i < _cameras.length; i++) {
        final camera = _cameras[i];
        if (camera.lensDirection == direction) {
          _cameraIndex = i;
          return camera;
        }
      }
    }
    return null;
  }

  Future<void> _startCamera(CameraDescription description) async {
    await _stopImageStream();
    final previous = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _permissionError = null;
      });
    }
    await previous?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await controller.initialize();
    _controller = controller;
    if (!mounted) return;
    setState(() {});
    await _startPoseStream();
  }

  Future<void> _startPoseStream() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isRecording ||
        _isStreaming) {
      return;
    }

    if (_poseService.isUnavailable) {
      _beginAutoDetectFallback();
      return;
    }

    try {
      await controller.startImageStream(_onCameraImage);
      _isStreaming = true;
    } catch (e) {
      debugPrint('Could not start pose stream: $e');
      _beginAutoDetectFallback();
    }
  }

  Future<void> _stopImageStream() async {
    final controller = _controller;
    if (controller == null || !_isStreaming) return;
    try {
      await controller.stopImageStream();
    } catch (_) {}
    _isStreaming = false;
  }

  Future<void> _disablePoseAndUseFallback() async {
    await _stopImageStream();
    if (!mounted) return;
    _beginAutoDetectFallback();
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (!mounted || _isRecording || _poseService.isUnavailable) return;
    final controller = _controller;
    if (controller == null) return;

    final orientation = _deviceOrientationDegrees();
    final result = await _poseService.processCameraImage(
      image,
      camera: controller.description,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      deviceOrientationDegrees: orientation,
    );

    if (_poseService.isUnavailable) {
      await _disablePoseAndUseFallback();
      return;
    }

    if (!mounted || result == null) return;

    _previewWidth = result.imageWidth;
    _previewHeight = result.imageHeight;
    final hasUsablePose =
        result.sample.landmarks.length >= 8 && result.sample.confidence >= 0.35;
    final nextJoints = hasUsablePose
        ? _smoothJoints(result.joints)
        : _smoothedJoints;

    // Keep a rolling window of recent samples for telemetry.
    _poseSamples.add(result.sample);
    if (_poseSamples.length > 120) {
      _poseSamples.removeRange(0, _poseSamples.length - 120);
    }

    setState(() {
      _autoDetectReady = hasUsablePose;
      if (hasUsablePose && nextJoints.isNotEmpty) {
        _joints = nextJoints;
      } else if (!_autoDetectReady) {
        _joints = const [];
      }
      if (!_didShowAlignmentTip) {
        _didShowAlignmentTip = true;
        _showAlignmentTip = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showAlignmentTip = false);
        });
      }
    });
  }

  List<Joint?> _smoothJoints(List<Joint?> next) {
    if (next.isEmpty) return _smoothedJoints;
    if (_smoothedJoints.length != next.length) {
      _smoothedJoints = List<Joint?>.from(next);
      return _smoothedJoints;
    }

    const alpha = 0.45;
    _smoothedJoints = List<Joint?>.generate(next.length, (index) {
      final curr = next[index];
      final prev = _smoothedJoints[index];
      if (curr == null) return null;
      if (prev == null) return curr;
      return Joint(
        prev.x + (curr.x - prev.x) * alpha,
        prev.y + (curr.y - prev.y) * alpha,
      );
    });
    return _smoothedJoints;
  }

  int _deviceOrientationDegrees() {
    switch (_controller?.value.deviceOrientation.name) {
      case 'landscapeLeft':
        return 90;
      case 'portraitDown':
        return 180;
      case 'landscapeRight':
        return 270;
      default:
        return 0;
    }
  }

  void _beginAutoDetectFallback() {
    _smoothedJoints = const [];
    setState(() {
      _autoDetectReady = false;
      _showAlignmentTip = false;
      _joints = const [];
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _autoDetectReady) return;
      setState(() {
        _showAlignmentTip = true;
        _joints = const [];
      });
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _showAlignmentTip = false);
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    final nextCamera = _isUsingFrontCamera
        ? _findCamera(
                preferredDirections: const [
                  CameraLensDirection.back,
                  CameraLensDirection.external,
                ],
              ) ??
              _cameras.first
        : _findCamera(preferredDirections: const [CameraLensDirection.front]) ??
              _cameras[(_cameraIndex + 1) % _cameras.length];
    await _startCamera(nextCamera);
  }

  Future<void> _pickFromGallery() async {
    if (_isRecording) return;

    final picked = await showModalBottomSheet<_PickedGalleryType>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('Choose Video'),
                subtitle: const Text('Upload a swing clip from your gallery'),
                onTap: () =>
                    Navigator.of(context).pop(_PickedGalleryType.video),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Choose Image'),
                subtitle: const Text('Open photos from your gallery'),
                onTap: () =>
                    Navigator.of(context).pop(_PickedGalleryType.image),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;

    try {
      if (picked == _PickedGalleryType.video) {
        final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
        if (file == null || !mounted) return;
        await _openPickedVideo(file);
        return;
      }

      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected image: ${file.name}. Swing upload currently supports video clips.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open gallery media: $e')),
      );
    }
  }

  Future<void> _openPickedVideo(XFile file) async {
    final allowedClubs = _categories.map((c) => c.name).toList();
    final clubName = CaptureFieldNormalizer.clubType(
      _selectedCategory?.name ?? 'Driver',
      allowedClubs: allowedClubs,
    );
    final session = CaptureSession(
      videoPath: file.path,
      clubType: clubName,
      cameraAngle: CaptureFieldNormalizer.cameraAngle(_selectedAngle),
      recordingMode: CaptureFieldNormalizer.recordingMode(_selectedMode),
      handedness: CaptureFieldNormalizer.handedness(_handedness),
      durationSeconds: 1,
      trimStart: 0,
      trimEnd: 1,
      poseSamples: const [],
      previewWidth: _previewWidth,
      previewHeight: _previewHeight,
      deviceModel: Platform.isIOS ? 'iOS' : 'Android',
    ).sanitized(allowedClubs: allowedClubs);

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReviewSwingScreen(session: session)),
    );
  }

  Future<void> _toggleRecord() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isRecording) {
      final elapsedMs =
          _recordStopwatch?.elapsedMilliseconds ?? _elapsed.inMilliseconds;
      if (elapsedMs < _minRecordDuration.inMilliseconds) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hold for at least 2 seconds to capture a swing.'),
          ),
        );
        return;
      }

      _recordTimer?.cancel();
      _recordStopwatch?.stop();
      final file = await controller.stopVideoRecording();
      final durationSec = (elapsedMs / 1000.0).clamp(1.0, 600.0);
      setState(() => _isRecording = false);

      // Resume pose stream for next take.
      await _startPoseStream();

      if (!mounted) return;

      final allowedClubs = _categories.map((c) => c.name).toList();
      final clubName = CaptureFieldNormalizer.clubType(
        _selectedCategory?.name ?? 'Driver',
        allowedClubs: allowedClubs,
      );
      final session = CaptureSession(
        videoPath: file.path,
        clubType: clubName,
        cameraAngle: CaptureFieldNormalizer.cameraAngle(_selectedAngle),
        recordingMode: CaptureFieldNormalizer.recordingMode(_selectedMode),
        handedness: CaptureFieldNormalizer.handedness(_handedness),
        durationSeconds: durationSec,
        trimStart: 0,
        trimEnd: durationSec,
        poseSamples: List<PoseSample>.from(_poseSamples),
        previewWidth: _previewWidth,
        previewHeight: _previewHeight,
        deviceModel: Platform.isIOS ? 'iOS' : 'Android',
      ).sanitized(allowedClubs: allowedClubs);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReviewSwingScreen(session: session)),
      );
    } else {
      await _stopImageStream();
      // Keep preview pose samples for upload telemetry (stream stops while recording).
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      _recordStopwatch = Stopwatch()..start();
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
      });
      _recordTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        final ms = _recordStopwatch?.elapsedMilliseconds ?? 0;
        setState(() => _elapsed = Duration(milliseconds: ms));
      });
    }
  }

  Future<void> _openClubPicker() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_categoriesError ?? 'No club categories available.'),
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<SwingCategory>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Club category',
                  style: AppTextStyles.sectionHeader,
                ),
              ),
              ..._categories.map((cat) {
                final selected = cat.id == _selectedCategory?.id;
                return ListTile(
                  title: Text(cat.name),
                  subtitle: Text(cat.difficulty),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColors.ctaBrightBlue)
                      : null,
                  onTap: () => Navigator.pop(context, cat),
                );
              }),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedCategory = picked;
      _applyCategoryDefaults(picked);
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _stopImageStream();
    _controller?.dispose();
    _poseService.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _modeLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'slow-mo':
      case 'slowmo':
      case 'slow_mo':
        return 'SLOW-MO';
      case 'video':
        return 'VIDEO';
      case 'swing':
      default:
        return 'SWING';
    }
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
          clubLabel: _selectedCategory?.name,
          onClose: () {
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          onClubTap: _openClubPicker,
        ),
        if (_loadingCategories)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.ctaBrightBlue,
              backgroundColor: Colors.white24,
            ),
          ),
        const SizedBox(height: 12),
        _AngleTabs(
          angles: _cameraAngles,
          selected: _selectedAngle,
          onSelect: (v) => setState(() {
            _selectedAngle = CaptureFieldNormalizer.cameraAngle(v);
          }),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: AppRadii.cardBorderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: KeyedSubtree(
                      key: ValueKey(
                        'camera-${controller.description.name}-${controller.description.lensDirection.name}',
                      ),
                      child: CameraPreview(controller),
                    ),
                  ),
                  CustomPaint(
                    painter: _autoDetectReady
                        ? AutoDetectFramePainter(
                            joints: _joints,
                            isMirrored: _isUsingFrontCamera,
                          )
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
                    child: _SideIconRail(
                      onFlip: _flipCamera,
                      onMenu: _openClubPicker,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _BottomControls(
          isRecording: _isRecording,
          onGalleryTap: _pickFromGallery,
          onRecord: _toggleRecord,
          onFlip: _flipCamera,
        ),
        const SizedBox(height: 14),
        _CaptureModeTabs(
          modes: _recordingModes,
          selected: _selectedMode,
          labelFor: _modeLabel,
          onSelect: (m) => setState(() {
            _selectedMode = CaptureFieldNormalizer.recordingMode(m);
          }),
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
  final String? clubLabel;
  final VoidCallback onClose;
  final VoidCallback onClubTap;

  const _TopBar({
    required this.isRecording,
    required this.elapsed,
    required this.onClose,
    required this.onClubTap,
    this.clubLabel,
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
              borderRadius: AppRadii.cardBorderRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isRecording
                      ? AppCaptureColors.recordButtonRed
                      : Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  elapsed,
                  style: AppTextStyles.type14.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClubTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppCaptureColors.scrimPillBg,
                borderRadius: AppRadii.cardBorderRadius,
              ),
              child: Text(
                clubLabel ?? 'Club',
                style: AppTextStyles.type13.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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

class _AngleTabs extends StatelessWidget {
  final List<String> angles;
  final String selected;
  final ValueChanged<String> onSelect;

  const _AngleTabs({
    required this.angles,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppCaptureColors.scrimPillBg,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Row(
        children: angles.map((label) {
          final isSelected = label == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppCaptureColors.modeTabSelectedBg
                      : Colors.transparent,
                  borderRadius: AppRadii.cardBorderRadius,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.type13.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppCaptureColors.modeTabSelectedText
                        : AppCaptureColors.modeTabUnselectedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'AUTO DETECT · READY',
            style: AppTextStyles.type11.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
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
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALIGNMENT',
            style: AppTextStyles.type11.copyWith(
              color: AppCaptureColors.autoDetectGreen,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Step back 40cm',
            style: AppTextStyles.type18.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
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
  final VoidCallback onMenu;
  const _SideIconRail({required this.onFlip, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _RoundIconButton(icon: icon, onTap: onTap),
    );
    return Column(
      children: [
        btn(Icons.menu, onMenu),
        btn(Icons.golf_course, onMenu),
        btn(Icons.cameraswitch, onFlip),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onGalleryTap;
  final VoidCallback onRecord;
  final VoidCallback onFlip;

  const _BottomControls({
    required this.isRecording,
    required this.onGalleryTap,
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
          GestureDetector(
            onTap: onGalleryTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
                color: Colors.white12,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white70,
                size: 20,
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
                  color: AppCaptureColors.recordButtonRing,
                  width: 4,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: AppCaptureColors.recordButtonRed,
                  borderRadius: BorderRadius.circular(isRecording ? 8 : 32),
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
  final List<String> modes;
  final String selected;
  final String Function(String) labelFor;
  final ValueChanged<String> onSelect;

  const _CaptureModeTabs({
    required this.modes,
    required this.selected,
    required this.labelFor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: modes.map((mode) {
        final isSelected = mode == selected;
        return GestureDetector(
          onTap: () => onSelect(mode),
          child: Column(
            children: [
              Text(
                labelFor(mode),
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
      }).toList(),
    );
  }
}

enum _PickedGalleryType { video, image }
