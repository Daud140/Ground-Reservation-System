import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../shared/widgets/runner_illustration.dart';
import '../../shared/widgets/stadium_illustration.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.customer;

  Future<void> _proceedWithRole() async {
    await ref.read(authProvider.notifier).quickDemoLogin(_selectedRole);
    if (!mounted) return;

    if (_selectedRole == UserRole.owner) {
      context.go(AppRoutes.ownerRoot);
    } else {
      context.go(AppRoutes.customerRoot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = _selectedRole == UserRole.customer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Step 2 of 2',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How will you use GroundZero?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your primary goal to customize your experience',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Option 1: I want to play
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.customer,
                  isSelected: isCustomer,
                  title: 'I want to play',
                  description: 'Book grounds near you, find open slots, play with friends',
                  illustration: const RunnerIllustrationWidget(
                    width: double.infinity,
                    height: 120,
                  ),
                  bullets: [
                    'Instant booking confirmation',
                    'Split bills with your squad',
                    'Verified astroturf & floodlit arenas',
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Option 2: I own a ground
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.owner,
                  isSelected: !isCustomer,
                  title: 'I own a ground',
                  description: 'List your venue, manage bookings, boost revenue with analytics',
                  illustration: const StadiumIllustrationWidget(
                    width: double.infinity,
                    height: 120,
                  ),
                  bullets: [
                    'Real-time slot calendar management',
                    'Prevent double booking automatically',
                    'Revenue & occupancy analytics',
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _proceedWithRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.emerald.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCustomer ? 'Continue as Player' : 'Continue as Ground Owner',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required bool isSelected,
    required String title,
    required String description,
    required Widget illustration,
    required List<String> bullets,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.emerald : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.emeraldDark : AppColors.navy,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.emerald : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.emerald : AppColors.borderLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondaryLight,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(child: illustration),
            ),
          ],
        ),
      ),
    );
  }
}
