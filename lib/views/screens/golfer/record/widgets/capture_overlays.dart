import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_capture_colors.dart';


/// Draws a dashed line between two points. Small local helper so we don't
/// need an extra package just for dashed strokes.
void _drawDashedLine(
  Canvas canvas,
  Offset start,
  Offset end,
  Paint paint, {
  double dashWidth = 6,
  double gapWidth = 5,
}) {
  final total = (end - start).distance;
  if (total == 0) return;
  final direction = (end - start) / total;
  var covered = 0.0;
  while (covered < total) {
    final segEnd = (covered + dashWidth).clamp(0, total).toDouble();
    canvas.drawLine(
      start + direction * covered,
      start + direction * segEnd,
      paint,
    );
    covered += dashWidth + gapWidth;
  }
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint,
    {double dashWidth = 6, double gapWidth = 5}) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = (distance + dashWidth).clamp(0, metric.length).toDouble();
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance += dashWidth + gapWidth;
    }
  }
}

/// Screenshot 1 — before a swing is detected: faint 3x3 grid + a dashed
/// "step here" silhouette guide (upper arch for shoulders, lower box for
/// stance) drawn over a plain dark viewfinder.
class AlignmentGuidePainter extends CustomPainter {
  const AlignmentGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppCaptureColors.guideGridLine
      ..strokeWidth = 1;

    // 3x3 grid.
    for (var i = 1; i < 3; i++) {
      final x = size.width / 3 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dashPaint = Paint()
      ..color = AppCaptureColors.guideDashed
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    // Upper "head + shoulders" arch guide.
    final headCenter = Offset(cx, size.height * 0.24);
    canvas.drawCircle(
        headCenter, size.width * 0.12, dashPaint..style = PaintingStyle.stroke);

    final archPath = Path()
      ..moveTo(cx, size.height * 0.36)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.30,
        size.width * 0.12,
        size.height * 0.55,
        size.width * 0.30,
        size.height * 0.72,
      )
      ..moveTo(cx, size.height * 0.36)
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.30,
        size.width * 0.88,
        size.height * 0.55,
        size.width * 0.70,
        size.height * 0.72,
      );
    _drawDashedPath(canvas, archPath, dashPaint);

    // Lower stance guide box (where the tripod / body should stand).
    final boxRect = Rect.fromCenter(
      center: Offset(cx, size.height * 0.58),
      width: size.width * 0.28,
      height: size.height * 0.26,
    );
    final boxPath = Path()
      ..addRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)));
    _drawDashedPath(canvas, boxPath, dashPaint);

    canvas.drawCircle(boxRect.center, size.width * 0.045, dashPaint);
    _drawDashedLine(
      canvas,
      Offset(boxRect.center.dx, boxRect.top + 8),
      Offset(boxRect.center.dx, boxRect.center.dy - size.width * 0.045 - 4),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(boxRect.left + 10, boxRect.center.dy),
      Offset(boxRect.center.dx - size.width * 0.045 - 4, boxRect.center.dy),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A single normalized (0..1) joint position relative to the preview box.
class Joint {
  final double x;
  final double y;
  const Joint(this.x, this.y);
  Offset toOffset(Size size) => Offset(x * size.width, y * size.height);
}

/// Screenshots 2 & 3 — green "AUTO DETECT · READY" frame with rounded
/// corner brackets plus a dashed pose skeleton over the live feed. Joint
/// positions are supplied so a real pose-estimation model can drive this
/// painter later — swap [joints] each frame and it updates live.
class AutoDetectFramePainter extends CustomPainter {
  final List<Joint> joints; // shoulder-elbow-wrist(L/R), hip-knee-ankle(L/R)
  final double cornerInset;

  const AutoDetectFramePainter({
    required this.joints,
    this.cornerInset = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameRect = Rect.fromLTWH(
      cornerInset,
      cornerInset,
      size.width - cornerInset * 2,
      size.height - cornerInset * 2,
    );

    final cornerPaint = Paint()
      ..color = AppCaptureColors.autoDetectGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const armLen = 26.0;
    void corner(Offset origin, Offset dx, Offset dy) {
      canvas.drawLine(origin, origin + dx * armLen, cornerPaint);
      canvas.drawLine(origin, origin + dy * armLen, cornerPaint);
    }

    corner(frameRect.topLeft, const Offset(1, 0), const Offset(0, 1));
    corner(frameRect.topRight, const Offset(-1, 0), const Offset(0, 1));
    corner(frameRect.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    corner(frameRect.bottomRight, const Offset(-1, 0), const Offset(0, -1));

    // Faint full outline so the frame reads even between corner brackets.
    final outlinePaint = Paint()
      ..color = AppCaptureColors.autoDetectGreen.withOpacity(0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(frameRect, outlinePaint);

    if (joints.isEmpty) return;

    final skeletonPaint = Paint()
      ..color = AppCaptureColors.skeletonLine
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // joints: [0 shoulderL,1 elbowL,2 wristL, 3 shoulderR,4 hipL,5 kneeL,
    //          6 ankleL, 7 hipR, 8 kneeR, 9 ankleR]
    final pts = joints.map((j) => j.toOffset(size)).toList();
    if (pts.length >= 10) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..lineTo(pts[4].dx, pts[4].dy)
        ..lineTo(pts[5].dx, pts[5].dy)
        ..lineTo(pts[6].dx, pts[6].dy)
        ..moveTo(pts[3].dx, pts[3].dy)
        ..lineTo(pts[7].dx, pts[7].dy)
        ..lineTo(pts[8].dx, pts[8].dy)
        ..lineTo(pts[9].dx, pts[9].dy)
        ..moveTo(pts[4].dx, pts[4].dy)
        ..lineTo(pts[7].dx, pts[7].dy);
      _drawDashedPath(canvas, path, skeletonPaint, dashWidth: 5, gapWidth: 4);

      final jointPaint = Paint()..color = AppCaptureColors.skeletonJoint;
      for (final p in pts) {
        canvas.drawCircle(p, 5, jointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AutoDetectFramePainter oldDelegate) =>
      oldDelegate.joints != joints;
}

/// Default joint layout approximating the top-of-backswing pose seen in the
/// mocks (weight loaded on the trail leg, arms raised). Values are fractions
/// of the preview size — replace with live model output when available.
const defaultSwingJoints = [
  Joint(0.34, 0.16), // shoulder L
  Joint(0.22, 0.10), // elbow L
  Joint(0.14, 0.05), // wrist L (club end)
  Joint(0.52, 0.18), // shoulder R
  Joint(0.36, 0.46), // hip L
  Joint(0.30, 0.66), // knee L
  Joint(0.26, 0.86), // ankle L
  Joint(0.54, 0.46), // hip R
  Joint(0.60, 0.66), // knee R
  Joint(0.62, 0.86), // ankle R
];
