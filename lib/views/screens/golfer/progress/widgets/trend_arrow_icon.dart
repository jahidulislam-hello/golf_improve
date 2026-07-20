import 'package:flutter/material.dart';

/// Faint jagged up-trend sketch icon in the top-right corner of the
/// "This Week" card. Drawn manually rather than a stock icon to match the
/// hand-drawn look in the mock.
class TrendArrowIcon extends StatelessWidget {
  const TrendArrowIcon({super.key, this.size = 44, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrendArrowPainter(color ?? const Color(0xFFE2E8F0)),
      ),
    );
  }
}

class _TrendArrowPainter extends CustomPainter {
  _TrendArrowPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.85)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.55, size.height * 0.7)
      ..lineTo(size.width * 0.95, size.height * 0.1);
    canvas.drawPath(path, paint);

    final headPath = Path()
      ..moveTo(size.width * 0.62, size.height * 0.1)
      ..lineTo(size.width * 0.95, size.height * 0.1)
      ..lineTo(size.width * 0.95, size.height * 0.43);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendArrowPainter oldDelegate) => false;
}
