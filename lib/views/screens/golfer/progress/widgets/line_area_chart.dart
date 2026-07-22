import 'package:flutter/material.dart';

/// A lightweight, dependency-free smoothed line + gradient-fill area chart.
/// Used for both the Handicap Progress trend and the Weekly Swings chart so
/// we don't have to pull in an external charting package.
class LineAreaChart extends StatelessWidget {
  const LineAreaChart({
    super.key,
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.fillTopColor,
    this.height = 130,
    this.dotAtEndOnly = false,
    this.showAllDots = false,
  });

  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color fillTopColor;
  final double height;

  /// Only draw a single dot at the last data point (Handicap Progress card).
  final bool dotAtEndOnly;

  /// Draw a dot at every data point (Weekly Swings card).
  final bool showAllDots;

  @override
  Widget build(BuildContext context) {
    // Chart area + gap + label row (label line-height needs ~18px).
    return SizedBox(
      height: height + 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomPaint(
              painter: _LineAreaPainter(
                values: values,
                lineColor: lineColor,
                fillTopColor: fillTopColor,
                dotAtEndOnly: dotAtEndOnly,
                showAllDots: showAllDots,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (l) => Text(
                    l,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LineAreaPainter extends CustomPainter {
  _LineAreaPainter({
    required this.values,
    required this.lineColor,
    required this.fillTopColor,
    required this.dotAtEndOnly,
    required this.showAllDots,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillTopColor;
  final bool dotAtEndOnly;
  final bool showAllDots;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1 : (maxV - minV);

    // Leave a little headroom so dots/peaks aren't clipped.
    const topPad = 12.0;
    const bottomPad = 6.0;
    final usableHeight = size.height - topPad - bottomPad;

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final normalized = (values[i] - minV) / range;
      final y = topPad + usableHeight - (normalized * usableHeight);
      points.add(Offset(x, y));
    }

    final linePath = _smoothPath(points);

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillTopColor.withOpacity(0.55), fillTopColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    if (dotAtEndOnly) {
      _drawDot(canvas, points.last, lineColor);
    } else if (showAllDots) {
      for (final p in points) {
        _drawDot(canvas, p, lineColor, radius: 4);
      }
    }
  }

  void _drawDot(Canvas canvas, Offset center, Color color, {double radius = 5}) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawCircle(center, radius - 2.2, Paint()..color = color);
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillTopColor != fillTopColor;
  }
}
