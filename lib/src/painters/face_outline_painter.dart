import 'package:flutter/material.dart';

class FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    /// ========================
    /// LEFT SIDE PATH
    /// ========================
    final left = Path();

    left.moveTo(w * 0.50, h * 0.06);

    left.cubicTo(w * 0.28, h * 0.07, w * 0.16, h * 0.19, w * 0.17, h * 0.35);
    left.cubicTo(w * 0.17, h * 0.38, w * 0.19, h * 0.42, w * 0.17, h * 0.46);
    left.cubicTo(w * 0.15, h * 0.54, w * 0.18, h * 0.66, w * 0.24, h * 0.74);
    left.cubicTo(w * 0.26, h * 0.78, w * 0.26, h * 0.86, w * 0.28, h * 0.92);
    left.quadraticBezierTo(w * 0.26, h * 0.96, w * 0.20, h * 0.98);

    canvas.drawPath(left, paintLine);

    /// ========================
    /// RIGHT SIDE MIRRORED
    /// ========================
    canvas.save();

    // mirror horizontal terhadap center
    canvas.translate(w, 0);
    canvas.scale(-1, 1);

    canvas.drawPath(left, paintLine);

    canvas.restore();

    /// ========================
    /// EYE GUIDE
    /// ========================
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.3;

    canvas.drawLine(
      Offset(w * 0.25, h * 0.42),
      Offset(w * 0.75, h * 0.42),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
