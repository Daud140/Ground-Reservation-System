import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = authState.user;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.navy),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // User Header Card
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.emerald, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (user?.name.isNotEmpty == true) ? user!.name[0] : 'A',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Ali Raza',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.phone ?? '+92 300 1234567',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.limeContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, color: AppColors.limeDark, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Pro Striker • Rank 4',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Player Stats Row
            Row(
              children: [
                _buildStatPill('16', 'Matches Played', Icons.sports_soccer),
                const SizedBox(width: 10),
                _buildStatPill('4', 'Favorite Pitches', Icons.favorite_border),
                const SizedBox(width: 10),
                _buildStatPill('4.9', 'Fair Play Score', Icons.star_border),
              ],
            ),

            const SizedBox(height: 20),

            // Switch to Ground Owner Mode Banner
            GestureDetector(
              onTap: () async {
                await ref.read(authProvider.notifier).quickDemoLogin(UserRole.owner);
                if (context.mounted) {
                  context.go(AppRoutes.ownerRoot);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stadium_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch to Ground Owner Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage Apex Arena slots & bookings',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Activity Group
            _buildSectionHeader('My Activity'),
            _buildProfileTile(
              Icons.calendar_month_outlined,
              'My Bookings',
              'View upcoming matches & digital passes',
              onTap: () {},
            ),
            _buildProfileTile(
              Icons.bookmark_outline,
              'Saved Pitches',
              'Quick access to your regular grounds',
              onTap: () {},
            ),
            _buildProfileTile(
              Icons.payment_outlined,
              'Payment Methods',
              'JazzCash, EasyPaisa, Visa / Mastercard',
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // Preferences Group
            _buildSectionHeader('Preferences & Settings'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dark_mode_outlined, color: AppColors.navy, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                  ),
                  Switch(
                    value: isDark,
                    activeThumbColor: AppColors.emerald,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            _buildProfileTile(
              Icons.notifications_none_outlined,
              'Notifications',
              'Match reminders & slot drop alerts',
              onTap: () {},
            ),
            _buildProfileTile(
              Icons.help_outline_rounded,
              'Help & Support',
              'WhatsApp 24/7 pitch support desk',
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // Log Out Button
            ListTile(
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFFFEE2E2),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.emerald),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.navy, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
      ),
    );
  }
}
