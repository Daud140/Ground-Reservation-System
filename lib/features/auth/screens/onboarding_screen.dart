import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/runner_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedFeatureIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Brand Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(child: GroundZeroLogo(size: 28)),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Runner Illustration Card with glowing dynamic strokes
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const RunnerIllustrationWidget(
                    width: 280,
                    height: 240,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Main Headline & Description
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Find',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.navy,
                      ),
                    ),
                    TextSpan(
                      text: '+',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Discover and book turf grounds, connect and spend recreation time with friends.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Feature Selector Pills
              Row(
                children: [
                  _buildFeaturePill(
                    index: 0,
                    title: 'Find nearby turf',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(width: 12),
                  _buildFeaturePill(
                    index: 1,
                    title: 'Easy online booking',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Vivid Emerald "Continue" Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.emerald.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedFeatureIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFeatureIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emeraldContainer : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.emerald : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : icon,
                size: 16,
                color: isSelected ? AppColors.emeraldDark : AppColors.textMutedLight,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.emeraldDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
