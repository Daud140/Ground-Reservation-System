import 'package:flutter/material.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw Google 4-color 'G' icon
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);
    final blue = Paint()..color = const Color(0xFF4285F4);

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue horizontal bar
    final blueBar = Rect.fromLTWH(w * 0.45, h * 0.4, w * 0.55, h * 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(blueBar, const Radius.circular(2)), blue);

    // Blue arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.78,
      1.57,
      false,
      blue..style = PaintingStyle.stroke..strokeWidth = w * 0.2,
    );

    // Green arc (bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.79,
      1.57,
      false,
      green..style = PaintingStyle.stroke..strokeWidth = w * 0.2,
    );

    // Yellow arc (left bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.36,
      1.57,
      false,
      yellow..style = PaintingStyle.stroke..strokeWidth = w * 0.2,
    );

    // Red arc (top)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.93,
      1.57,
      false,
      red..style = PaintingStyle.stroke..strokeWidth = w * 0.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
