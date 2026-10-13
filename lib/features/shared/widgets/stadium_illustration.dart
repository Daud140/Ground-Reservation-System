import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StadiumIllustrationWidget extends StatelessWidget {
  final double width;
  final double height;

  const StadiumIllustrationWidget({
    super.key,
    this.width = 240,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark navy night sky arena
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ambient floodlight beam gradient
            CustomPaint(
              size: Size(width, height),
              painter: _StadiumPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StadiumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Floodlight beams (angled down into pitch)
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          AppColors.lime.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final beamLeft = Path()
      ..moveTo(w * 0.15, 0)
      ..lineTo(w * 0.25, 0)
      ..lineTo(w * 0.55, h)
      ..lineTo(w * 0.35, h)
      ..close();
    canvas.drawPath(beamLeft, beamPaint);

    final beamRight = Path()
      ..moveTo(w * 0.75, 0)
      ..lineTo(w * 0.85, 0)
      ..lineTo(w * 0.65, h)
      ..lineTo(w * 0.45, h)
      ..close();
    canvas.drawPath(beamRight, beamPaint);

    // 2. Stadium Roof / Stands Curve
    final standsPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final standsPath = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.25, h * 0.2, w * 0.75, h * 0.2, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(standsPath, standsPaint);

    // 3. Floodlight towers with bright bulbs
    final towerPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.12, h * 0.35), Offset(w * 0.18, h * 0.08), towerPaint);
    canvas.drawLine(Offset(w * 0.88, h * 0.35), Offset(w * 0.82, h * 0.08), towerPaint);

    final bulbPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(w * 0.15 + i * 5, h * 0.08), 2.5, bulbPaint);
      canvas.drawCircle(Offset(w * 0.8 + i * 5, h * 0.08), 2.5, bulbPaint);
    }

    // 4. Emerald Green Turf Pitch (Perspective oval)
    final pitchPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF10B981)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.45, w * 0.8, h * 0.5));

    final pitchRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.78),
      width: w * 0.78,
      height: h * 0.44,
    );
    canvas.drawOval(pitchRect, pitchPaint);

    // 5. White Pitch Markings
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Pitch center line & center circle
    canvas.drawLine(Offset(w * 0.5, h * 0.58), Offset(w * 0.5, h * 0.98), markPaint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.78), width: w * 0.22, height: h * 0.18),
      markPaint,
    );

    // Outer boundary
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.78), width: w * 0.72, height: h * 0.38),
      markPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
