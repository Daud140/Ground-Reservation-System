import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class RunnerIllustrationWidget extends StatelessWidget {
  final double width;
  final double height;

  const RunnerIllustrationWidget({
    super.key,
    this.width = 240,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ambient glow rings
            CustomPaint(
              size: Size(width, height),
              painter: _RunnerAuraPainter(),
            ),
            // Custom Painter for energetic runner & speed lines
            CustomPaint(
              size: Size(width * 0.85, height * 0.85),
              painter: _RunnerFigurePainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunnerAuraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.48);
    final paintAura = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.lime.withValues(alpha: 0.35),
              AppColors.emeraldLight.withValues(alpha: 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.45),
          );

    canvas.drawCircle(center, size.width * 0.45, paintAura);

    // Subtle curved speed streaks in background
    final streakPaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.3,
        size.width * 0.7,
        size.height * 0.25,
      );
    canvas.drawPath(path1, streakPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.58,
        size.width * 0.85,
        size.height * 0.5,
      );
    canvas.drawPath(path2, streakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RunnerFigurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dynamic speed ribbons / swooshes behind the athlete
    final ribbonPaint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.lime.withValues(alpha: 0.6),
          AppColors.emerald,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final ribbonPaint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.emeraldLight.withValues(alpha: 0.7),
          AppColors.emeraldDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Swoosh 1
    final swoosh1 = Path()
      ..moveTo(w * 0.15, h * 0.55)
      ..cubicTo(w * 0.3, h * 0.48, w * 0.4, h * 0.62, w * 0.65, h * 0.42);
    canvas.drawPath(swoosh1, ribbonPaint1);

    // Swoosh 2
    final swoosh2 = Path()
      ..moveTo(w * 0.22, h * 0.7)
      ..cubicTo(w * 0.35, h * 0.65, w * 0.45, h * 0.78, w * 0.72, h * 0.6);
    canvas.drawPath(swoosh2, ribbonPaint2);

    // Swoosh 3 (top)
    final swoosh3 = Path()
      ..moveTo(w * 0.28, h * 0.35)
      ..cubicTo(w * 0.42, h * 0.28, w * 0.52, h * 0.38, w * 0.75, h * 0.28);
    canvas.drawPath(swoosh3, ribbonPaint2);

    // 2. Stylized athlete figure (solid emerald silhouette with motion)
    final bodyPaint = Paint()
      ..color =
          const Color(0xFF047857) // Deep energetic forest emerald
      ..style = PaintingStyle.fill;

    final limbPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head
    canvas.drawCircle(Offset(w * 0.58, h * 0.26), w * 0.08, bodyPaint);

    // Torso (forward lean)
    final torsoPath = Path()
      ..moveTo(w * 0.55, h * 0.35)
      ..lineTo(w * 0.64, h * 0.4)
      ..lineTo(w * 0.56, h * 0.6)
      ..lineTo(w * 0.48, h * 0.55)
      ..close();
    canvas.drawPath(torsoPath, bodyPaint);

    // Front arm (reaching forward)
    final frontArm = Path()
      ..moveTo(w * 0.6, h * 0.4)
      ..lineTo(w * 0.72, h * 0.36)
      ..lineTo(w * 0.8, h * 0.44);
    canvas.drawPath(frontArm, limbPaint);

    // Back arm (pumping back)
    final backArm = Path()
      ..moveTo(w * 0.52, h * 0.42)
      ..lineTo(w * 0.42, h * 0.46)
      ..lineTo(w * 0.36, h * 0.56);
    canvas.drawPath(backArm, limbPaint);

    // Lead Leg (lifted forward/knee high)
    final leadLeg = Path()
      ..moveTo(w * 0.55, h * 0.58)
      ..lineTo(w * 0.68, h * 0.65)
      ..lineTo(w * 0.62, h * 0.82);
    canvas.drawPath(leadLeg, limbPaint);

    // Trailing Leg (extended back in full stride)
    final trailingLeg = Path()
      ..moveTo(w * 0.49, h * 0.56)
      ..lineTo(w * 0.38, h * 0.7)
      ..lineTo(w * 0.28, h * 0.8);
    canvas.drawPath(trailingLeg, limbPaint);

    // 3. Dynamic soccer ball near foot
    final ballCenter = Offset(w * 0.78, h * 0.76);
    final ballRadius = w * 0.07;
    final ballPaint = Paint()..color = Colors.white;
    final ballBorder = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(ballCenter, ballRadius, ballPaint);
    canvas.drawCircle(ballCenter, ballRadius, ballBorder);

    // Ball pentagon pattern
    final patchPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(ballCenter, ballRadius * 0.38, patchPaint);

    // Speed particle dots
    final dotPaint = Paint()..color = AppColors.limeDark;
    canvas.drawCircle(Offset(w * 0.84, h * 0.35), 3, dotPaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.42), 2.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.62), 3.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.18, h * 0.4), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
