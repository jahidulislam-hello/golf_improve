import 'dart:io';
import 'dart:math' as math;

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

      final avgConfidence = landmarks.isEmpty
          ? 0.0
          : landmarks.values.map((e) => e.confidence).reduce((a, b) => a + b) /
                landmarks.length;

      final sample = PoseSample(
        timestampMs: timestampMs,
        landmarks: landmarks,
        confidence: avgConfidence,
      );

      final joints = _toOverlayJoints(
        landmarks,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: input.metadata!.rotation,
      );
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

  /// Maps ML Kit points onto the upright preview.
  ///
  /// On Android the camera buffer is landscape. With a 90° or 270° rotation,
  /// landmark X spans the buffer height and Y spans the buffer width. Dividing
  /// by the raw width/height drops the skeleton below the head and shoulders.
  List<Joint?> _toOverlayJoints(
    Map<String, PoseLandmarkPoint> landmarks, {
    required Size imageSize,
    required InputImageRotation rotation,
  }) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return const [];
    if (landmarks.isEmpty) return const [];

    final swapped = !Platform.isIOS &&
        (rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg);
    final axisX = swapped ? imageSize.height : imageSize.width;
    final axisY = swapped ? imageSize.width : imageSize.height;

    Joint? j(String key) {
      final point = landmarks[key];
      if (point == null || point.confidence < 0.3) return null;
      var x = (point.x / axisX).clamp(0.0, 1.0);
      final y = (point.y / axisY).clamp(0.0, 1.0);
      if (rotation == InputImageRotation.rotation270deg) {
        x = 1 - x;
      }
      return Joint(x, y);
    }

    final leftElbow = j('left_elbow');
    final leftWrist = j('left_wrist');
    final rightElbow = j('right_elbow');
    final rightWrist = j('right_wrist');

    return [
      j('nose'),
      j('left_shoulder'),
      leftElbow,
      leftWrist,
      j('right_shoulder'),
      rightElbow,
      rightWrist,
      j('left_hip'),
      j('left_knee'),
      j('left_ankle'),
      j('right_hip'),
      j('right_knee'),
      j('right_ankle'),
      _clubHead(
        leftElbow: leftElbow,
        leftWrist: leftWrist,
        rightElbow: rightElbow,
        rightWrist: rightWrist,
      ),
    ];
  }

  /// Continues the more extended arm past the hand, toward the club.
  Joint? _clubHead({
    required Joint? leftElbow,
    required Joint? leftWrist,
    required Joint? rightElbow,
    required Joint? rightWrist,
  }) {
    Joint? extend(Joint? elbow, Joint? wrist) {
      if (elbow == null || wrist == null) return null;
      final dx = wrist.x - elbow.x;
      final dy = wrist.y - elbow.y;
      final length = math.sqrt(dx * dx + dy * dy);
      if (length < 0.02) return null;
      return Joint(
        (wrist.x + dx * 0.9).clamp(0.0, 1.0),
        (wrist.y + dy * 0.9).clamp(0.0, 1.0),
      );
    }

    final left = extend(leftElbow, leftWrist);
    final right = extend(rightElbow, rightWrist);
    if (left == null) return right;
    if (right == null) return left;
    final leftReach = (left.x - leftElbow!.x).abs() + (left.y - leftElbow.y).abs();
    final rightReach =
        (right.x - rightElbow!.x).abs() + (right.y - rightElbow.y).abs();
    return leftReach >= rightReach ? left : right;
  }

  InputImage? _toInputImage(
    CameraImage image, {
    required CameraDescription camera,
    required int deviceOrientationDegrees,
  }) {
    final rotation = _rotation(
      camera: camera,
      deviceOrientationDegrees: deviceOrientationDegrees,
    );
    if (rotation == null) return null;

    final Uint8List bytes;
    final InputImageFormat format;
    if (Platform.isAndroid) {
      if (image.planes.isEmpty) return null;
      bytes = image.planes.first.bytes;
      format = InputImageFormat.nv21;
    } else {
      final allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      bytes = allBytes.done().buffer.asUint8List();
      final parsed = InputImageFormatValue.fromRawValue(image.format.raw);
      if (parsed == null) return null;
      format = parsed;
    }

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
  final List<Joint?> joints;
  final int imageWidth;
  final int imageHeight;
}
