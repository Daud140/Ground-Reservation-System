import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/runner_illustration.dart';
import '../../shared/widgets/stadium_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      titlePrefix: 'Find',
      description: 'Discover and reserve elite turfs, connect and spend recreation time with friends.',
      chips: [
        _SlideChip(label: 'Find nearby turf', icon: Icons.location_on_rounded),
        _SlideChip(label: 'Verified ratings', icon: Icons.star_rounded),
      ],
      type: _SlideType.find,
    ),
    _OnboardingSlideData(
      titlePrefix: 'Book',
      description: 'Instant slot reservation with real-time ground availability and instant confirmation.',
      chips: [
        _SlideChip(label: 'Instant confirmation', icon: Icons.bolt_rounded),
        _SlideChip(label: 'Flexible payment', icon: Icons.credit_card_rounded),
      ],
      type: _SlideType.book,
    ),
    _OnboardingSlideData(
      titlePrefix: 'Manage',
      description: 'Coordinate squads, split booking expenses, and elevate your match day performance.',
      chips: [
        _SlideChip(label: 'Squad splitting', icon: Icons.groups_rounded),
        _SlideChip(label: 'Player analytics', icon: Icons.insights_rounded),
      ],
      type: _SlideType.manage,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(AppRoutes.roleSelection);
    }
  }

  void _onSkip() {
    context.go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navy;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Brand Logo and Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(child: GroundZeroLogo(size: 28)),
                  TextButton(
                    onPressed: _onSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: subtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Swipeable Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Center dynamic illustration card
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(
                                AppTheme.cardRadius + 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.emerald.withValues(
                                    alpha: isDark ? 0.05 : 0.12,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _buildSlideIllustration(slide.type),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title with Emerald Plus Badge
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: slide.titlePrefix,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: textColor,
                                ),
                              ),
                              const TextSpan(
                                text: '+',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.emerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          slide.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: subtextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Feature Pills
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: slide.chips
                              .map(
                                (chip) => _buildFeaturePill(
                                  chip.label,
                                  chip.icon,
                                  isDark,
                                  textColor,
                                  borderColor,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Bar: Page Indicator (01/03) & Gradient Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator Row (01/03) + Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active Dots Indicator
                      Row(
                        children: List.generate(_slides.length, (idx) {
                          final isActive = idx == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.emerald
                                  : (isDark
                                        ? AppColors.borderDark
                                        : AppTheme.borderLight),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Text Page Indicator: "01/03"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceSecondaryDark
                              : AppColors.surfaceSecondaryLight,
                          borderRadius: BorderRadius.circular(
                            AppTheme.pillRadius,
                          ),
                        ),
                        child: Text(
                          '0${_currentPage + 1}/0${_slides.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // "Continue" Gradient Button
                  GradientButton(
                    text: 'Continue',
                    trailingIcon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.go(
                      '${AppRoutes.login}?role=customer&tab=login',
                    ),
                    child: Text(
                      'Already have an account? Log In / Sign Up',
                      style: TextStyle(
                        color: subtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(
    String title,
    IconData icon,
    bool isDark,
    Color textColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSecondaryDark
            : AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.emerald),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIllustration(_SlideType type) {
    switch (type) {
      case _SlideType.find:
        return const RunnerIllustrationWidget(width: 280, height: 220);
      case _SlideType.book:
        return _buildBookingPitchIllustration();
      case _SlideType.manage:
        return const StadiumIllustrationWidget(width: 280, height: 220);
    }
  }

  Widget _buildBookingPitchIllustration() {
    return Container(
      width: 280,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.emerald.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Apex Arena • 7-a-side',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emeraldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Date row simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDateChip('MON', '24', false),
              _buildDateChip('TUE', '25', true),
              _buildDateChip('WED', '26', false),
              _buildDateChip('THU', '27', false),
            ],
          ),
          const SizedBox(height: 16),

          // Time Slot pills simulation
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '08:00 PM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'PKR 4,500',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '09:00 PM',
                        style: TextStyle(
                          color: AppTheme.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'PKR 4,500',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String day, String num, bool isSelected) {
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.navy : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.navy : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            num,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}

enum _SlideType { find, book, manage }

class _OnboardingSlideData {
  final String titlePrefix;
  final String description;
  final List<_SlideChip> chips;
  final _SlideType type;

  const _OnboardingSlideData({
    required this.titlePrefix,
    required this.description,
    required this.chips,
    required this.type,
  });
}

class _SlideChip {
  final String label;
  final IconData icon;

  const _SlideChip({required this.label, required this.icon});
}
