import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// A CustomPainter that draws an editorial "stamp seal" — a circular seal
/// with a botanical/geometric pattern. Used for the press-and-hold booking
/// confirmation and the punch card credit circles.
class StampSealPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0 for animation
  final Color color;
  final bool isFilled;

  StampSealPainter({
    this.progress = 1.0,
    this.color = bbAccent,
    this.isFilled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Outer ring
    final ringPaint = Paint()
      ..color = color.withOpacity(progress * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 0.92, ringPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..color = color.withOpacity(progress * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, radius * 0.75, innerRingPaint);

    // Fill (when stamped / booked)
    if (isFilled) {
      final fillPaint = Paint()
        ..color = color.withOpacity(progress * 0.12)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius * 0.75, fillPaint);
    }

    // Cross-hatch lines (botanical texture) — 4 lines radiating from center
    final linePaint = Paint()
      ..color = color.withOpacity(progress * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final innerRadius = radius * 0.35;
      final outerRadius = radius * 0.7;
      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * innerRadius,
          center.dy + sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + cos(angle) * outerRadius,
          center.dy + sin(angle) * outerRadius,
        ),
        linePaint,
      );
    }

    // Center dot
    final dotPaint = Paint()
      ..color = color.withOpacity(progress * 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.08, dotPaint);

    // Small decorative dots around inner ring
    final decorDotPaint = Paint()
      ..color = color.withOpacity(progress * 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6);
      final dotCenter = Offset(
        center.dx + cos(angle) * radius * 0.83,
        center.dy + sin(angle) * radius * 0.83,
      );
      canvas.drawCircle(dotCenter, 1.2, decorDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StampSealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isFilled != isFilled ||
        oldDelegate.color != color;
  }
}

/// A widget that renders the stamp seal with an optional animation.
class StampSeal extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  final bool isFilled;

  const StampSeal({
    Key? key,
    this.size = 48,
    this.progress = 1.0,
    this.color = bbAccent,
    this.isFilled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: StampSealPainter(
        progress: progress,
        color: color,
        isFilled: isFilled,
      ),
    );
  }
}
