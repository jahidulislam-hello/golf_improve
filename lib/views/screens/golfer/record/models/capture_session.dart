import 'dart:convert';

/// Snapshot of AI Camera selections + recorded clip, passed to Review → Analyse.
class CaptureSession {
  const CaptureSession({
    required this.videoPath,
    required this.clubType,
    required this.cameraAngle,
    required this.recordingMode,
    required this.handedness,
    required this.durationSeconds,
    this.trimStart = 0,
    this.trimEnd,
    this.poseSamples = const [],
    this.previewWidth = 1920,
    this.previewHeight = 1080,
    this.deviceModel,
  });

  final String videoPath;
  final String clubType;
  final String cameraAngle;
  final String recordingMode;
  final String handedness;
  final double durationSeconds;
  final double trimStart;
  final double? trimEnd;
  final List<PoseSample> poseSamples;
  final int previewWidth;
  final int previewHeight;
  final String? deviceModel;

  double get effectiveTrimEnd => trimEnd ?? durationSeconds;

  /// Returns a copy with backend-safe club / angle / mode / duration values.
  CaptureSession sanitized({List<String> allowedClubs = const []}) {
    final duration = durationSeconds < 1 ? 1.0 : durationSeconds;
    final start = trimStart < 0 ? 0.0 : trimStart;
    var end = effectiveTrimEnd;
    if (end <= start) end = duration;

    return CaptureSession(
      videoPath: videoPath,
      clubType: CaptureFieldNormalizer.clubType(
        clubType,
        allowedClubs: allowedClubs,
      ),
      cameraAngle: CaptureFieldNormalizer.cameraAngle(cameraAngle),
      recordingMode: CaptureFieldNormalizer.recordingMode(recordingMode),
      handedness: CaptureFieldNormalizer.handedness(handedness),
      durationSeconds: duration,
      trimStart: start,
      trimEnd: end,
      poseSamples: poseSamples,
      previewWidth: previewWidth,
      previewHeight: previewHeight,
      deviceModel: deviceModel,
    );
  }
}

/// Maps UI / API aliases onto the exact values expected by `/swing/analyzer`.
class CaptureFieldNormalizer {
  static const preferredAngles = [
    'Face On',
    'Down The Line',
    // 'Side On', // deprecated — API returns 400
    // 'Overhead',
  ];

  static const preferredModes = ['slow-mo', 'swing', 'video'];

  static String cameraAngle(String raw) {
    final compact = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (compact.contains('face')) return 'Face On';
    if (compact.contains('down') ||
        compact.contains('dtl') ||
        compact.contains('line')) {
      return 'Down The Line';
    }
    // Side On / Overhead deprecated — fall back to Face On.
    // if (compact.contains('side')) return 'Side On';
    // if (compact.contains('over')) return 'Overhead';
    if (_looksLikeMode(compact)) return 'Face On';
    if (raw.trim().isEmpty) return 'Face On';
    return 'Face On';
  }

  static String recordingMode(String raw) {
    final compact = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (compact.contains('slow')) return 'slow-mo';
    if (compact.contains('video')) return 'video';
    if (compact.contains('swing')) return 'swing';
    if (_looksLikeAngle(compact)) return 'swing';
    return 'swing';
  }

  static String clubType(String raw, {List<String> allowedClubs = const []}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return allowedClubs.isNotEmpty ? allowedClubs.first : 'Driver';
    }

    for (final club in allowedClubs) {
      if (club.toLowerCase() == trimmed.toLowerCase()) return club;
    }

    final compact = trimmed.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (_looksLikeAngle(compact) || _looksLikeMode(compact)) {
      return allowedClubs.isNotEmpty ? allowedClubs.first : 'Driver';
    }

    if (compact.contains('driver')) return 'Driver';
    if (compact.contains('iron')) return 'Irons';
    if (compact.contains('wedge')) return 'Wedges';
    if (compact.contains('putt')) return 'Putter';
    if (compact.contains('wood')) return 'Woods';
    if (compact.contains('hybrid')) return 'Hybrid';

    return trimmed;
  }

  static String handedness(String raw) {
    final n = raw.trim().toLowerCase();
    if (n.contains('left')) return 'left';
    return 'right';
  }

  static bool looksLikeClubName(String raw) {
    final compact = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (compact.isEmpty) return false;
    if (_looksLikeAngle(compact) || _looksLikeMode(compact)) return false;
    return true;
  }

  static bool _looksLikeAngle(String compact) {
    return compact.contains('face') ||
        compact.contains('down') ||
        compact.contains('dtl') ||
        compact.contains('line') ||
        compact.contains('side') ||
        compact.contains('over');
  }

  static bool _looksLikeMode(String compact) {
    return compact.contains('slow') ||
        compact == 'swing' ||
        compact == 'video' ||
        compact.contains('slowmo') ||
        compact.contains('slowmotion');
  }

  /// Separates mixed angle/mode lists from a loose API payload.
  static ({List<String> angles, List<String> modes}) classifyLists({
    required List<String> cameraAngles,
    required List<String> recordingModes,
  }) {
    final angles = <String>[];
    final modes = <String>[];

    void ingest(String raw) {
      final compact =
          raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
      if (compact.isEmpty) return;
      if (_looksLikeMode(compact)) {
        final mode = recordingMode(raw);
        if (!modes.contains(mode)) modes.add(mode);
      } else if (_looksLikeAngle(compact)) {
        final angle = cameraAngle(raw);
        if (!angles.contains(angle)) angles.add(angle);
      }
    }

    for (final value in cameraAngles) {
      ingest(value);
    }
    for (final value in recordingModes) {
      ingest(value);
    }

    final safeAngles = angles
        .where((a) {
          final n = a.toLowerCase();
          return !n.contains('side') && !n.contains('over');
        })
        .toList();
    return (
      angles: safeAngles.isNotEmpty
          ? safeAngles
          : List<String>.from(preferredAngles),
      modes: modes.isNotEmpty ? modes : List<String>.from(preferredModes),
    );
  }
}

/// One pose sample captured during live preview / recording.
class PoseSample {
  const PoseSample({
    required this.timestampMs,
    required this.landmarks,
    this.confidence = 0.9,
  });

  final int timestampMs;
  final Map<String, PoseLandmarkPoint> landmarks;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'confidence': confidence,
        'landmarks': {
          for (final e in landmarks.entries) e.key: e.value.toJson(),
        },
      };
}

class PoseLandmarkPoint {
  const PoseLandmarkPoint({
    required this.x,
    required this.y,
    this.confidence = 0.9,
  });

  final double x;
  final double y;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'x': x.round(),
        'y': y.round(),
        'confidence': double.parse(confidence.toStringAsFixed(2)),
      };
}

/// Builds multipart telemetry payloads for POST `/swing/analyzer`.
class SwingTelemetryBuilder {
  static Map<String, dynamic> cameraData({
    required String cameraAngle,
    required int width,
    required int height,
    String? deviceModel,
    double fps = 30,
    double heightCm = 115,
    double distanceToGolferCm = 280,
  }) {
    return {
      'view': _angleToViewKey(cameraAngle),
      'heightCm': heightCm,
      'distanceToGolferCm': distanceToGolferCm,
      'orientation': {'pitch': -2.5, 'yaw': 0, 'roll': 0},
      'focalLengthPx': 1420,
      'horizontalFovDeg': 68,
      'verticalFovDeg': 52,
      'width': width,
      'height': height,
      'fps': fps,
      if (deviceModel != null && deviceModel.isNotEmpty)
        'deviceModel': deviceModel,
    };
  }

  static Map<String, dynamic> calibration({
    double golferDistanceCm = 280,
    double cameraToGroundHeightCm = 115,
  }) {
    return {
      'groundPlane': {'detected': true, 'confidence': 0.95},
      'horizon': {'y': 420, 'confidence': 0.92},
      'golferDistanceCm': golferDistanceCm,
      'cameraToGroundHeightCm': cameraToGroundHeightCm,
      'calibrationConfidence': 0.94,
    };
  }

  static Map<String, dynamic> swingPhases({
    required double durationSeconds,
    required List<PoseSample> samples,
    double fps = 30,
  }) {
    final durationMs = (durationSeconds * 1000).clamp(1, 600000).toDouble();
    final totalFrames = (durationSeconds * fps).round().clamp(1, 100000);

    final phaseDefs = <String, double>{
      'address': 0.10,
      'takeaway': 0.18,
      'top_of_backswing': 0.45,
      'impact': 0.62,
      'finish': 0.90,
    };

    final fallbackLandmarks = _defaultLandmarks(width: 1920, height: 1080);
    final result = <String, dynamic>{};

    for (final entry in phaseDefs.entries) {
      final tMs = (durationMs * entry.value).round();
      final frame = (totalFrames * entry.value).round();
      final sample = _nearestSample(samples, tMs);
      final landmarks = sample?.landmarks.isNotEmpty == true
          ? {
              for (final e in sample!.landmarks.entries) e.key: e.value.toJson(),
            }
          : fallbackLandmarks;

      result[entry.key] = {
        'frame': frame,
        'timestampMs': tMs,
        'confidence': sample?.confidence ?? 0.9,
        'landmarks': landmarks,
      };
    }

    return result;
  }

  static Map<String, dynamic> clientKinematics({
    required double durationSeconds,
    double fps = 30,
  }) {
    final durationMs = durationSeconds * 1000;
    final addressFrame = (durationSeconds * fps * 0.10).round();
    final takeawayFrame = (durationSeconds * fps * 0.18).round();
    final topFrame = (durationSeconds * fps * 0.45).round();
    final impactFrame = (durationSeconds * fps * 0.62).round();
    final finishFrame = (durationSeconds * fps * 0.90).round();

    final backswingMs =
        ((topFrame - addressFrame) / fps * 1000).clamp(1, durationMs);
    final downswingMs =
        ((impactFrame - topFrame) / fps * 1000).clamp(1, durationMs);
    final followThroughMs =
        ((finishFrame - impactFrame) / fps * 1000).clamp(1, durationMs);
    final tempoRatio = downswingMs > 0 ? backswingMs / downswingMs : 0.0;

    return {
      'swing': {
        'addressFrame': addressFrame,
        'takeawayFrame': takeawayFrame,
        'topFrame': topFrame,
        'impactFrame': impactFrame,
        'finishFrame': finishFrame,
      },
      'timing': {
        'backswingMs': double.parse(backswingMs.toStringAsFixed(1)),
        'downswingMs': double.parse(downswingMs.toStringAsFixed(1)),
        'followThroughMs': double.parse(followThroughMs.toStringAsFixed(1)),
        'tempoRatio': double.parse(tempoRatio.toStringAsFixed(2)),
      },
      'body': {
        'headMovement': {'lateralPx': 42, 'verticalPx': 18},
        'shoulderRotation': {
          'addressDeg': 0,
          'topDeg': 86,
          'impactDeg': 38,
        },
        'hipRotation': {
          'addressDeg': 0,
          'topDeg': 45,
          'impactDeg': 32,
        },
      },
      'club': {
        'shaftAngleAtTop': 72.4,
        'shaftAngleAtImpact': 18.3,
        'clubPath': 'INSIDE_TO_OUT',
      },
      'confidence': {
        'pose': 0.96,
        'club': 0.91,
        'impact': 0.88,
      },
    };
  }

  static String encode(Map<String, dynamic> map) => jsonEncode(map);

  static String _angleToViewKey(String angle) {
    final normalized = angle.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (normalized.contains('face')) return 'face_on';
    if (normalized.contains('down')) return 'down_the_line';
    if (normalized.contains('side')) return 'side_on';
    if (normalized.contains('over')) return 'overhead';
    return normalized.isEmpty ? 'face_on' : normalized;
  }

  static PoseSample? _nearestSample(List<PoseSample> samples, int targetMs) {
    if (samples.isEmpty) return null;
    PoseSample best = samples.first;
    var bestDelta = (best.timestampMs - targetMs).abs();
    for (final s in samples.skip(1)) {
      final d = (s.timestampMs - targetMs).abs();
      if (d < bestDelta) {
        best = s;
        bestDelta = d;
      }
    }
    return best;
  }

  static Map<String, dynamic> _defaultLandmarks({
    required int width,
    required int height,
  }) {
    const norms = <String, List<double>>{
      'nose': [0.48, 0.17],
      'left_shoulder': [0.40, 0.22],
      'right_shoulder': [0.56, 0.22],
      'left_elbow': [0.36, 0.31],
      'right_elbow': [0.60, 0.31],
      'left_wrist': [0.34, 0.38],
      'right_wrist': [0.62, 0.38],
      'left_hip': [0.42, 0.45],
      'right_hip': [0.54, 0.45],
      'left_knee': [0.42, 0.59],
      'right_knee': [0.54, 0.59],
      'left_ankle': [0.42, 0.72],
      'right_ankle': [0.54, 0.72],
      'club_head': [0.49, 0.76],
    };

    return {
      for (final e in norms.entries)
        e.key: {
          'x': (e.value[0] * width).round(),
          'y': (e.value[1] * height).round(),
          'confidence': 0.92,
        },
    };
  }
}
