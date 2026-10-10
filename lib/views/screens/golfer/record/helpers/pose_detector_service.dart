import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/capture_session.dart';
import '../widgets/capture_overlays.dart';

/// Live pose detection for the AI Camera preview (stopped while recording).
///
/// If the native ML Kit plugin is missing (hot-reload after `pub add`, or
/// incomplete rebuild), [isUnavailable] becomes true and callers should stop
/// the camera image stream and use the visual fallback.
class PoseDetectorService {
  PoseDetectorService();

  PoseDetector? _detector;
  bool _busy = false;
  bool _disposed = false;
  bool _unavailable = false;
  bool _loggedUnavailable = false;

  bool get isUnavailable => _unavailable;
  bool get isReady => !_unavailable && !_disposed;

  PoseDetector get _ensureDetector {
    return _detector ??= PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  /// Processes one camera image into overlay joints + a telemetry sample.
  Future<PoseFrameResult?> processCameraImage(
    CameraImage image, {
    required CameraDescription camera,
    required int timestampMs,
    required int deviceOrientationDegrees,
  }) async {
    if (_disposed || _busy || _unavailable) return null;
    _busy = true;
    try {
      final input = _toInputImage(
        image,
        camera: camera,
        deviceOrientationDegrees: deviceOrientationDegrees,
      );
      if (input == null) return null;

      final poses = await _ensureDetector.processImage(input);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      final landmarks = <String, PoseLandmarkPoint>{};
      void put(String key, PoseLandmarkType type) {
        final lm = pose.landmarks[type];
        if (lm == null) return;
        landmarks[key] = PoseLandmarkPoint(
          x: lm.x,
          y: lm.y,
          confidence: lm.likelihood.clamp(0.0, 1.0),
        );
      }

      put('nose', PoseLandmarkType.nose);
      put('left_shoulder', PoseLandmarkType.leftShoulder);
      put('right_shoulder', PoseLandmarkType.rightShoulder);
      put('left_elbow', PoseLandmarkType.leftElbow);
      put('right_elbow', PoseLandmarkType.rightElbow);
      put('left_wrist', PoseLandmarkType.leftWrist);
      put('right_wrist', PoseLandmarkType.rightWrist);
      put('left_hip', PoseLandmarkType.leftHip);
      put('right_hip', PoseLandmarkType.rightHip);
      put('left_knee', PoseLandmarkType.leftKnee);
      put('right_knee', PoseLandmarkType.rightKnee);
      put('left_ankle', PoseLandmarkType.leftAnkle);
      put('right_ankle', PoseLandmarkType.rightAnkle);

      final leadWrist = landmarks['left_wrist'] ?? landmarks['right_wrist'];
      if (leadWrist != null) {
        landmarks['club_head'] = PoseLandmarkPoint(
          x: leadWrist.x,
          y: leadWrist.y + 40,
          confidence: leadWrist.confidence * 0.9,
        );
      }

      final avgConfidence = landmarks.isEmpty
          ? 0.0
          : landmarks.values.map((e) => e.confidence).reduce((a, b) => a + b) /
                landmarks.length;

      final sample = PoseSample(
        timestampMs: timestampMs,
        landmarks: landmarks,
        confidence: avgConfidence,
      );

      final joints = _toOverlayJoints(landmarks, image.width, image.height);
      return PoseFrameResult(
        sample: sample,
        joints: joints,
        imageWidth: image.width,
        imageHeight: image.height,
      );
    } on MissingPluginException catch (e) {
      _markUnavailable(e);
      return null;
    } catch (e, st) {
      if (_isMissingPlugin(e)) {
        _markUnavailable(e);
        return null;
      }
      debugPrint('PoseDetectorService error: $e\n$st');
      return null;
    } finally {
      _busy = false;
    }
  }

  void _markUnavailable(Object e) {
    _unavailable = true;
    if (_loggedUnavailable) return;
    _loggedUnavailable = true;
    debugPrint(
      'ML Kit pose detector unavailable ($e). '
      'Stop the app fully and run a fresh rebuild '
      '(`flutter clean` then `flutter run`). Using alignment fallback.',
    );
  }

  bool _isMissingPlugin(Object e) {
    if (e is MissingPluginException) return true;
    final text = e.toString();
    return text.contains('MissingPluginException') ||
        text.contains('vision#startPoseDetector');
  }

  List<Joint> _toOverlayJoints(
    Map<String, PoseLandmarkPoint> landmarks,
    int width,
    int height,
  ) {
    if (width <= 0 || height <= 0) return const [];

    Joint j(String key, int fallbackIndex) {
      final p = landmarks[key];
      if (p != null) {
        return Joint(
          (p.x / width).clamp(0.0, 1.0),
          (p.y / height).clamp(0.0, 1.0),
        );
      }
      return defaultSwingJoints[fallbackIndex];
    }

    if (landmarks.isEmpty) return const [];

    return [
      j('nose', 0),
      j('left_shoulder', 1),
      j('left_elbow', 2),
      j('left_wrist', 3),
      j('right_shoulder', 4),
      j('right_elbow', 5),
      j('right_wrist', 6),
      j('left_hip', 7),
      j('left_knee', 8),
      j('left_ankle', 9),
      j('right_hip', 10),
      j('right_knee', 11),
      j('right_ankle', 12),
      j('club_head', 13),
    ];
  }

  InputImage? _toInputImage(
    CameraImage image, {
    required CameraDescription camera,
    required int deviceOrientationDegrees,
  }) {
    final allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final rotation = _rotation(
      camera: camera,
      deviceOrientationDegrees: deviceOrientationDegrees,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotation({
    required CameraDescription camera,
    required int deviceOrientationDegrees,
  }) {
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    }

    var rotationCompensation = deviceOrientationDegrees;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation =
          (camera.sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (camera.sensorOrientation - rotationCompensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }

  Future<void> dispose() async {
    _disposed = true;
    final detector = _detector;
    _detector = null;
    if (detector != null) {
      try {
        await detector.close();
      } catch (_) {}
    }
  }
}

class PoseFrameResult {
  const PoseFrameResult({
    required this.sample,
    required this.joints,
    required this.imageWidth,
    required this.imageHeight,
  });

  final PoseSample sample;
  final List<Joint> joints;
  final int imageWidth;
  final int imageHeight;
}
