import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../../shared/widgets/runner_illustration.dart';
import '../../shared/widgets/stadium_illustration.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.customer;

  void _proceedWithRole() {
    // Pass selected role to Login/SignUp screen via query parameter
    final roleParam = _selectedRole == UserRole.owner ? 'owner' : 'customer';
    context.go('${AppRoutes.login}?role=$roleParam&tab=signup');
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = _selectedRole == UserRole.customer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.navy,
            size: 20,
          ),
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Text(
              'Step 1 of 3',
              style: TextStyle(
                color: AppTheme.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How will you use GroundZero?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose your primary goal to customize your experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Option 1: Customer Card ("I want to play")
                    _buildRoleCard(
                      role: UserRole.customer,
                      isSelected: isCustomer,
                      title: 'I want to play',
                      roleSubtitle: 'Customer / Player',
                      description:
                          'Book grounds near you, find open slots, play with friends',
                      illustration: const RunnerIllustrationWidget(
                        width: double.infinity,
                        height: 110,
                      ),
                      chips: [
                        'Instant Booking',
                        'Split Bills',
                        'Verified Arenas',
                        'Match Squads',
                      ],
                      onTap: () => setState(() => _selectedRole = UserRole.customer),
                    ),

                    const SizedBox(height: 18),

                    // Option 2: Owner Card ("I own a ground")
                    _buildRoleCard(
                      role: UserRole.owner,
                      isSelected: !isCustomer,
                      title: 'I own a ground',
                      roleSubtitle: 'Ground Owner',
                      description:
                          'List your venue, manage bookings, boost revenue with analytics',
                      illustration: const StadiumIllustrationWidget(
                        width: double.infinity,
                        height: 110,
                      ),
                      chips: [
                        'Slot Calendar',
                        'Revenue Analytics',
                        'Booking Approvals',
                        'Dynamic Pricing',
                      ],
                      onTap: () => setState(() => _selectedRole = UserRole.owner),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: GradientButton(
                text: isCustomer ? 'Continue as Player' : 'Continue as Owner',
                trailingIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _proceedWithRole,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required bool isSelected,
    required String title,
    required String roleSubtitle,
    required String description,
    required Widget illustration,
    required List<String> chips,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? AppTheme.selectedCardDecoration
            : AppTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header of the card with title, role tag and check indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.emeraldContainer
                                  : AppColors.surfaceSecondaryLight,
                              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                            ),
                            child: Text(
                              roleSubtitle,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppTheme.emeraldDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Check Indicator Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.emerald : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.emerald : AppTheme.borderLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Illustration container
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: illustration,
            ),
            const SizedBox(height: 12),

            // Feature chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((chipText) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF0FDF4)
                        : AppColors.surfaceSecondaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.emerald.withValues(alpha: 0.25)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: isSelected
                            ? AppTheme.emeraldDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        chipText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.navy
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
