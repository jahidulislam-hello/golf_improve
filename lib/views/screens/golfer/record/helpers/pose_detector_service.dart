import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/capture_session.dart';
import '../widgets/capture_overlays.dart';

/// Live pose detection for the AI Camera (preview + recording frame stream).
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

  /// Creates the native detector early so the first preview frames are analysed.
  Future<void> warmUp() async {
    if (_disposed || _unavailable) return;
    try {
      _ensureDetector;
    } on MissingPluginException catch (e) {
      _markUnavailable(e);
    } catch (e) {
      if (_isMissingPlugin(e)) {
        _markUnavailable(e);
      }
    }
  }

  PoseDetector get _ensureDetector {
    return _detector ??= PoseDetector(
      options: PoseDetectorOptions(
        // Stream + base model is the ML Kit-recommended live path on phones.
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
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

      return await _detect(
        input,
        imageWidth: image.width,
        imageHeight: image.height,
        timestampMs: timestampMs,
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

  /// Runs pose detection on a still photo from the gallery / disk.
  Future<PoseFrameResult?> processImageFile(
    String path, {
    int? timestampMs,
  }) async {
    if (_disposed || _unavailable) return null;
    if (_busy) {
      // Wait briefly so a live-stream frame can finish.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (_busy) return null;
    }
    _busy = true;
    try {
      await warmUp();
      if (_unavailable) return null;
      final input = InputImage.fromFilePath(path);
      return await _detect(
        input,
        imageWidth: 0,
        imageHeight: 0,
        timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
      );
    } on MissingPluginException catch (e) {
      _markUnavailable(e);
      return null;
    } catch (e, st) {
      if (_isMissingPlugin(e)) {
        _markUnavailable(e);
        return null;
      }
      debugPrint('PoseDetectorService file error: $e\n$st');
      return null;
    } finally {
      _busy = false;
    }
  }

  Future<PoseFrameResult?> _detect(
    InputImage input, {
    required int imageWidth,
    required int imageHeight,
    required int timestampMs,
  }) async {
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

    if (landmarks.isEmpty) return null;

    final avgConfidence =
        landmarks.values.map((e) => e.confidence).reduce((a, b) => a + b) /
            landmarks.length;

    final sample = PoseSample(
      timestampMs: timestampMs,
      landmarks: landmarks,
      confidence: avgConfidence,
    );

    final meta = input.metadata;
    final width = imageWidth > 0
        ? imageWidth
        : (meta?.size.width.toInt() ?? _estimateWidth(landmarks));
    final height = imageHeight > 0
        ? imageHeight
        : (meta?.size.height.toInt() ?? _estimateHeight(landmarks));
    final rotation = meta?.rotation ?? InputImageRotation.rotation0deg;

    final joints = _toOverlayJoints(
      landmarks,
      imageSize: Size(width.toDouble(), height.toDouble()),
      rotation: rotation,
    );
    return PoseFrameResult(
      sample: sample,
      joints: joints,
      imageWidth: width,
      imageHeight: height,
    );
  }

  int _estimateWidth(Map<String, PoseLandmarkPoint> landmarks) {
    final xs = landmarks.values.map((e) => e.x);
    return math.max(1, xs.reduce(math.max).ceil());
  }

  int _estimateHeight(Map<String, PoseLandmarkPoint> landmarks) {
    final ys = landmarks.values.map((e) => e.y);
    return math.max(1, ys.reduce(math.max).ceil());
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
    if (rotation == null || image.planes.isEmpty) return null;

    final rawFormat = InputImageFormatValue.fromRawValue(image.format.raw);

    if (Platform.isIOS) {
      if (rawFormat != InputImageFormat.bgra8888 || image.planes.length != 1) {
        return null;
      }
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }

    // Android: prefer true NV21 single-plane buffers. CameraX sometimes still
    // delivers YUV_420_888 (3 planes) — convert those so pose can run.
    final Uint8List bytes;
    final int bytesPerRow;
    if (rawFormat == InputImageFormat.nv21 && image.planes.length == 1) {
      bytes = image.planes.first.bytes;
      bytesPerRow = image.planes.first.bytesPerRow;
    } else if (image.planes.length == 1) {
      // Some devices report an unexpected format but still give NV21 bytes.
      bytes = image.planes.first.bytes;
      bytesPerRow = image.planes.first.bytesPerRow;
    } else if (image.planes.length >= 3) {
      bytes = _yuv420ToNv21(image);
      bytesPerRow = image.width;
    } else {
      return null;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  /// Converts Android YUV_420_888 camera frames into NV21 for ML Kit.
  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final ySize = width * height;
    final nv21 = Uint8List(ySize + ySize ~/ 2);

    final yRowStride = yPlane.bytesPerRow;
    final yBytes = yPlane.bytes;
    var out = 0;
    for (var row = 0; row < height; row++) {
      final start = row * yRowStride;
      nv21.setRange(out, out + width, yBytes, start);
      out += width;
    }

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;
    for (var row = 0; row < height ~/ 2; row++) {
      for (var col = 0; col < width ~/ 2; col++) {
        final uvIndex = row * uvRowStride + col * uvPixelStride;
        nv21[out++] = vBytes[uvIndex];
        nv21[out++] = uBytes[uvIndex];
      }
    }
    return nv21;
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
