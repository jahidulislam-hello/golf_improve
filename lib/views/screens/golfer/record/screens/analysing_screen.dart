import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/views/base/golfer_navbar/golfer_navbar_controller.dart';
import 'package:golf_training_app/views/screens/golfer/library/screens/swing_analysis_screen.dart'
    as swing_analysis;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/capture_session.dart';

/// Uploads the clip to `/swing/analyzer`, runs `/swing/analyze/video/:id`,
/// then opens the Library Swing Analysis screen with AI diagnostic cards.
class AnalysingScreen extends StatefulWidget {
  const AnalysingScreen({super.key, required this.session});

  final CaptureSession session;

  @override
  State<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  double _progress = 0.08;
  String _statusText =
      'Examining body position, swing path, weight shift and grip.';
  String? _error;
  bool _running = true;
  bool _navigating = false;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _tickTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (!_running || !mounted || _error != null || _navigating) return;
      setState(() {
        _progress = (_progress + 0.015).clamp(0.0, 0.92);
      });
    });

    _runPipeline();
  }

  Future<void> _runPipeline() async {
    String stage = 'prepare';
    try {
      final session = widget.session.sanitized();
      final videoFile = File(session.videoPath);
      if (!await videoFile.exists()) {
        throw ApiError(
          message: 'Video file not found. Please record again.',
          statusCode: 0,
        );
      }
      final bytes = await videoFile.length();
      if (bytes <= 0) {
        throw ApiError(
          message: 'Recorded video is empty. Please record again.',
          statusCode: 0,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw ApiError(
          message: 'You are not signed in. Please sign in and try again.',
          statusCode: 401,
        );
      }

      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );

      if (!mounted) return;
      setState(() {
        _error = null;
        _running = true;
        _navigating = false;
        _statusText = 'Uploading your swing…';
        _progress = (_progress < 0.2) ? 0.2 : _progress;
      });

      stage = 'upload';
      final cameraData = SwingTelemetryBuilder.cameraData(
        cameraAngle: session.cameraAngle,
        width: session.previewWidth,
        height: session.previewHeight,
        deviceModel: session.deviceModel,
      );
      final calibration = SwingTelemetryBuilder.calibration();
      final swingPhases = SwingTelemetryBuilder.swingPhases(
        durationSeconds: session.durationSeconds,
        samples: session.poseSamples,
      );

      debugPrint(
        'Swing upload: path=${session.videoPath} size=$bytes '
        'club=${session.clubType} angle=${session.cameraAngle} '
        'mode=${session.recordingMode} duration=${session.durationSeconds}',
      );

      final upload = await service.uploadSwingForAnalysis(
        videoPath: session.videoPath,
        clubType: session.clubType,
        cameraAngle: session.cameraAngle,
        recordingMode: session.recordingMode,
        handedness: session.handedness,
        duration: session.durationSeconds,
        trimStart: session.trimStart,
        trimEnd: session.effectiveTrimEnd,
        cameraData: cameraData,
        calibration: calibration,
        swingPhases: swingPhases,
      );

      debugPrint('Swing upload response: $upload');

      final uploadData = _asMap(upload['data']) ?? _asMap(upload) ?? {};
      final swingId = _readId(uploadData) ?? _readId(_asMap(upload));
      if (swingId == null || swingId.isEmpty) {
        throw ApiError(
          message:
              'Upload succeeded but no swing id was returned. Please try again.',
          statusCode: 0,
        );
      }

      if (!mounted) return;
      setState(() {
        _statusText = 'Running AI swing analysis…';
        _progress = (_progress < 0.55) ? 0.55 : _progress;
      });

      stage = 'analyze';
      Map<String, dynamic> analyzeData = <String, dynamic>{};
      try {
        final analyze = await service.analyzeSwingVideo(swingId);
        debugPrint('Swing analyze response: $analyze');
        analyzeData =
            _asMap(analyze['data']) ?? _asMap(analyze) ?? <String, dynamic>{};
      } catch (analyzeError) {
        debugPrint('Analyze call failed, falling back to library: $analyzeError');
        // Upload already succeeded — try library detail so user still sees a result.
        try {
          final library = await service.getSwingLibraryById(swingId);
          analyzeData =
              _asMap(library['data']) ?? _asMap(library) ?? <String, dynamic>{};
        } catch (_) {
          rethrow;
        }
      }

      final resolvedId =
          _readId(analyzeData) ?? _readId(_asMap(upload)) ?? swingId;
      if (!analyzeData.containsKey('_id') && !analyzeData.containsKey('id')) {
        analyzeData['_id'] = resolvedId;
      }

      if (!mounted) return;
      setState(() {
        _running = false;
        _navigating = true;
        _progress = 1.0;
        _statusText = 'Analysis complete.';
      });

      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      if (Get.isRegistered<GolferNavbarController>()) {
        Get.find<GolferNavbarController>().changeIndex(1);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => swing_analysis.SwingAnalysisScreen(
            swingId: resolvedId,
            initialData: Map<String, dynamic>.from(analyzeData),
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e, st) {
      debugPrint('Analysing pipeline failed at $stage: $e\n$st');
      if (!mounted) return;
      final message = e is ApiError ? e.message : e.toString();
      final prefix = switch (stage) {
        'upload' => 'Upload failed',
        'analyze' => 'AI analysis failed',
        _ => 'Analysis failed',
      };
      setState(() {
        _running = false;
        _navigating = false;
        _error = '$prefix: $message';
        _statusText = 'Could not analyse this swing.';
      });
    }
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _readId(Map<String, dynamic>? data) {
    if (data == null) return null;

    for (final key in [
      '_id',
      'id',
      'swingId',
      'swingLibraryId',
      'swing_library_id',
      'videoId',
    ]) {
      final value = data[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty && text != 'null') return text;
      }
    }

    for (final key in [
      'swing',
      'swingLibrary',
      'result',
      'analysis',
      'video',
      'item',
    ]) {
      final nested = _asMap(data[key]);
      final nestedId = _readId(nested);
      if (nestedId != null) return nestedId;
    }

    return null;
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppCaptureColors.analysingIconBg,
                    borderRadius: AppRadii.cardBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _error == null
                      ? RotationTransition(
                          turns: _spinController,
                          child: const Icon(
                            Icons.autorenew,
                            color: AppCaptureColors.analysingSpinner,
                            size: 34,
                          ),
                        )
                      : const Icon(
                          Icons.error_outline,
                          color: AppColors.destructiveRed,
                          size: 34,
                        ),
                ),
                const SizedBox(height: 28),
                Text(
                  _error == null
                      ? 'Analysing your swing'
                      : 'Analysis failed',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),
                Text(
                  _error ?? _statusText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (_error == null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: AppCaptureColors.analysingProgressTrack,
                      color: AppCaptureColors.analysingProgressFill,
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ctaBrightBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.buttonBorderRadius,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _running = true;
                          _navigating = false;
                          _progress = 0.1;
                          _statusText = 'Retrying…';
                        });
                        _runPipeline();
                      },
                      child: Text('Try again', style: AppTextStyles.buttonLabel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to review'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
