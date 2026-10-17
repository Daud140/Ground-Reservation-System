import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GroundZeroLogo extends StatelessWidget {
  final double size;
  final bool isDark;
  final bool showText;
  final Color? textColor;

  const GroundZeroLogo({
    super.key,
    this.size = 32,
    this.isDark = false,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.emeraldGradient,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.35),
                blurRadius: size * 0.3,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.sports_soccer_rounded,
              color: Colors.white,
              size: size * 0.62,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.3),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'GROUND',
                      style: TextStyle(
                        fontSize: size * 0.58,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: textColor ?? (isDark ? Colors.white : AppColors.navy),
                      ),
                    ),
                    TextSpan(
                      text: 'ZERO',
                      style: TextStyle(
                        fontSize: size * 0.58,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
