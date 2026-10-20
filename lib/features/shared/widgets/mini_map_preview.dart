import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class MiniMapPreviewWidget extends StatelessWidget {
  final String address;
  final String venueName;
  final VoidCallback? onDirectionsTap;
  final double height;

  const MiniMapPreviewWidget({
    super.key,
    required this.address,
    required this.venueName,
    this.onDirectionsTap,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Custom Painter rendering styled map roads, blocks, water & green parks
            CustomPaint(
              size: Size(double.infinity, height),
              painter: _MapStylingPainter(),
            ),
            // Center pin with marker and pulsing ring
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.emerald,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          venueName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_soccer,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom floating action "Get Directions"
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                onTap: onDirectionsTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions,
                        color: AppColors.emerald,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Directions',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStylingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background terrain
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Green parks/open areas
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.1, w * 0.25, h * 0.5),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.4, w * 0.3, h * 0.5),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Minor roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final roadPath1 = Path()
      ..moveTo(0, h * 0.45)
      ..lineTo(w * 0.4, h * 0.48)
      ..lineTo(w, h * 0.35);
    canvas.drawPath(roadPath1, roadPaint);

    final roadPath2 = Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(w * 0.38, h * 0.5)
      ..lineTo(w * 0.45, h);
    canvas.drawPath(roadPath2, roadPaint);

    final roadPath3 = Path()
      ..moveTo(w * 0.7, 0)
      ..lineTo(w * 0.65, h);
    canvas.drawPath(roadPath3, roadPaint);

    // Main highway (light orange)
    final highwayPaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final highwayPath = Path()
      ..moveTo(0, h * 0.8)
      ..cubicTo(w * 0.3, h * 0.75, w * 0.7, h * 0.85, w, h * 0.7);
    canvas.drawPath(highwayPath, highwayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
