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

void _drawDashedPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dashWidth = 6,
  double gapWidth = 5,
}) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = (distance + dashWidth).clamp(0, metric.length).toDouble();
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance += dashWidth + gapWidth;
    }
  }
}

/// Before a swing is detected: faint 3x3 grid plus a framing guide.
///
/// * Face On — dashed "step here" guide (head circle, shoulder arch, stance box).
/// * Down The Line — side-view outline of a golfer at address with club, ball,
///   ground line and the swing-plane line, so the user can line up the camera
///   behind the hands.
class AlignmentGuidePainter extends CustomPainter {
  const AlignmentGuidePainter({
    this.downTheLine = false,
    this.leftHanded = false,
  });

  final bool downTheLine;

  /// Mirrors the Down The Line outline for left-handed golfers.
  final bool leftHanded;

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

    if (downTheLine) {
      _paintDownTheLine(canvas, size);
      return;
    }

    final dashPaint = Paint()
      ..color = AppCaptureColors.guideDashed
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    // Upper "head + shoulders" arch guide.
    final headCenter = Offset(cx, size.height * 0.24);
    canvas.drawCircle(
      headCenter,
      size.width * 0.12,
      dashPaint..style = PaintingStyle.stroke,
    );

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

  /// Side view of a right-handed golfer at address, filmed from behind the
  /// hands along the target line. Coordinates are fractions of a portrait box
  /// so the figure keeps human proportions on any preview size.
  void _paintDownTheLine(Canvas canvas, Size size) {
    final boxH = size.height * 0.86;
    final boxW = (boxH * 0.62).clamp(0.0, size.width * 0.92);
    final left = (size.width - boxW) / 2;
    final top = size.height * 0.07;

    Offset p(double x, double y) {
      final fx = leftHanded ? 1 - x : x;
      return Offset(left + fx * boxW, top + y * boxH);
    }

    void curve(Path path, Offset c, Offset end) =>
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);

    final outline = Paint()
      ..color = AppCaptureColors.guideDashed
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final guide = Paint()
      ..color = AppCaptureColors.guideDashed.withValues(alpha: 0.75)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Head with cap peak pointing at the ball.
    final head = p(0.60, 0.13);
    final headR = boxW * 0.075;
    final peakDir = leftHanded ? -1.0 : 1.0;
    canvas.drawCircle(head, headR, outline);
    canvas.drawLine(
      Offset(head.dx + peakDir * headR * 0.7, head.dy - headR * 0.6),
      Offset(head.dx + peakDir * headR * 1.6, head.dy - headR * 0.2),
      outline,
    );

    // Torso bent forward from the hips: back line and chest line.
    final torso = Path()..moveTo(p(0.53, 0.19).dx, p(0.53, 0.19).dy);
    curve(torso, p(0.36, 0.28), p(0.24, 0.42));
    curve(torso, p(0.16, 0.48), p(0.22, 0.54));
    torso.moveTo(p(0.66, 0.20).dx, p(0.66, 0.20).dy);
    curve(torso, p(0.66, 0.30), p(0.52, 0.41));
    curve(torso, p(0.44, 0.46), p(0.43, 0.51));
    canvas.drawPath(torso, outline);

    // Arms hanging from the shoulders to the grip.
    final hands = p(0.62, 0.52);
    final arms = Path()..moveTo(p(0.56, 0.22).dx, p(0.56, 0.22).dy);
    curve(arms, p(0.58, 0.38), hands);
    arms.moveTo(p(0.63, 0.23).dx, p(0.63, 0.23).dy);
    curve(arms, p(0.66, 0.38), hands);
    canvas.drawPath(arms, outline);
    canvas.drawCircle(hands, boxW * 0.028, outline);

    // Legs: flexed knees, weight over the balls of the feet.
    final legs = Path()..moveTo(p(0.22, 0.54).dx, p(0.22, 0.54).dy);
    curve(legs, p(0.25, 0.63), p(0.33, 0.71));
    legs.lineTo(p(0.27, 0.92).dx, p(0.27, 0.92).dy);
    legs.moveTo(p(0.43, 0.51).dx, p(0.43, 0.51).dy);
    curve(legs, p(0.45, 0.61), p(0.49, 0.70));
    legs.lineTo(p(0.44, 0.92).dx, p(0.44, 0.92).dy);
    legs.moveTo(p(0.32, 0.57).dx, p(0.32, 0.57).dy);
    curve(legs, p(0.37, 0.64), p(0.41, 0.71));
    legs.lineTo(p(0.36, 0.91).dx, p(0.36, 0.91).dy);
    canvas.drawPath(legs, outline);

    // Feet.
    canvas.drawLine(p(0.23, 0.94), p(0.53, 0.94), outline);

    // Club shaft from the grip to the ball, then the club head.
    final clubHead = p(0.88, 0.935);
    canvas.drawLine(hands, clubHead, outline);
    canvas.drawLine(
      p(0.86, 0.925),
      p(0.93, 0.94),
      Paint()
        ..color = AppCaptureColors.guideDashed
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    // Ball.
    canvas.drawCircle(p(0.97, 0.935), boxW * 0.022, outline);

    // Ground line.
    final groundY = p(0, 0.955).dy;
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.06, groundY),
      Offset(size.width * 0.94, groundY),
      guide,
    );

    // Swing-plane line: ball through the hands, extended past the shoulders.
    final ball = p(0.97, 0.935);
    _drawDashedLine(canvas, ball, ball + (hands - ball) * 2.1, guide);

    // Stance box around the lower body for camera framing.
    _drawDashedPath(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(p(0.14, 0.45), p(0.56, 0.955)),
            const Radius.circular(14),
          ),
        ),
      guide,
    );
  }

  @override
  bool shouldRepaint(covariant AlignmentGuidePainter oldDelegate) =>
      oldDelegate.downTheLine != downTheLine ||
      oldDelegate.leftHanded != leftHanded;
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
  final List<Joint?> joints;
  final double cornerInset;
  final bool isMirrored;

  const AutoDetectFramePainter({
    required this.joints,
    this.cornerInset = 24,
    this.isMirrored = false,
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
      ..color = AppCaptureColors.autoDetectGreen.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(frameRect, outlinePaint);

    if (joints.isEmpty) return;

    final skeletonPaint = Paint()
      ..color = AppCaptureColors.skeletonLine
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    Offset? pointAt(int index) {
      if (index < 0 || index >= joints.length) return null;
      final joint = joints[index];
      if (joint == null) return null;
      final x = isMirrored ? (1 - joint.x) : joint.x;
      return Offset(x * size.width, joint.y * size.height);
    }

    // 0 nose, 1 shoulderL, 2 elbowL, 3 wristL, 4 shoulderR, 5 elbowR,
    // 6 wristR, 7 hipL, 8 kneeL, 9 ankleL, 10 hipR, 11 kneeR, 12 ankleR, 13 club
    final pts = List<Offset?>.generate(14, pointAt);
    final path = Path();
    void link(int a, int b) {
      final start = pts[a];
      final end = pts[b];
      if (start == null || end == null) return;
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
    }

    link(0, 1);
    link(0, 4);
    link(1, 4);
    link(1, 2);
    link(2, 3);
    link(4, 5);
    link(5, 6);
    final club = pts[13];
    if (club != null) {
      final leftHand = pts[3];
      final rightHand = pts[6];
      Offset? hand;
      if (leftHand != null && rightHand != null) {
        hand = (leftHand - club).distance <= (rightHand - club).distance
            ? leftHand
            : rightHand;
      } else {
        hand = leftHand ?? rightHand;
      }
      if (hand != null) {
        path.moveTo(hand.dx, hand.dy);
        path.lineTo(club.dx, club.dy);
      }
    }
    link(1, 7);
    link(7, 8);
    link(8, 9);
    link(4, 10);
    link(10, 11);
    link(11, 12);
    link(7, 10);
    if (path.computeMetrics().isNotEmpty) {
      _drawDashedPath(canvas, path, skeletonPaint, dashWidth: 5, gapWidth: 4);
    }

    final nose = pts[0];
    final shoulderL = pts[1];
    final shoulderR = pts[4];
    if (nose != null) {
      final shoulderSpan = shoulderL != null && shoulderR != null
          ? (shoulderL.dx - shoulderR.dx).abs()
          : 48.0;
      final headRadius = (shoulderSpan * 0.42).clamp(12.0, 28.0);
      final headPaint = Paint()
        ..color = AppCaptureColors.skeletonJoint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(nose, headRadius, headPaint);
    }

    final jointPaint = Paint()..color = AppCaptureColors.skeletonJoint;
    for (var i = 0; i < pts.length; i++) {
      final point = pts[i];
      if (point == null || i == 13) continue;
      canvas.drawCircle(point, 5, jointPaint);
    }

    final handPaint = Paint()..color = Colors.white;
    for (final index in const [3, 6, 13]) {
      final point = pts[index];
      if (point == null) continue;
      canvas.drawCircle(point, index == 13 ? 6 : 7, handPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AutoDetectFramePainter oldDelegate) =>
      oldDelegate.joints != joints || oldDelegate.isMirrored != isMirrored;
}

/// Default joint layout approximating the top-of-backswing pose seen in the
/// mocks (weight loaded on the trail leg, arms raised). Values are fractions
/// of the preview size — replace with live model output when available.
const defaultSwingJoints = [
  Joint(0.43, 0.10), // nose
  Joint(0.34, 0.16), // shoulder L
  Joint(0.22, 0.10), // elbow L
  Joint(0.14, 0.05), // wrist L
  Joint(0.52, 0.18), // shoulder R
  Joint(0.60, 0.12), // elbow R
  Joint(0.70, 0.07), // wrist R
  Joint(0.36, 0.46), // hip L
  Joint(0.30, 0.66), // knee L
  Joint(0.26, 0.86), // ankle L
  Joint(0.54, 0.46), // hip R
  Joint(0.60, 0.66), // knee R
  Joint(0.62, 0.86), // ankle R
  Joint(0.10, 0.03), // club head
];
