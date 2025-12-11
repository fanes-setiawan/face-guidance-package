
import 'package:flutter/material.dart';

class CircleRingPainter extends CustomPainter {
  final Color color;
  CircleRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final inner = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(center, radius, border);
    canvas.drawCircle(center, radius - 10, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
