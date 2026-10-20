import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/demo/demo_data.dart';
import '../../../data/demo/fake_database.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payment/providers/payment_provider.dart';
import '../../payment/widgets/payment_methods_sheet.dart';
import '../models/ground_model.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  final void Function(int)? onNavigateTab;

  const CustomerProfileScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  // Local state for interactive features
  String _rankBadge = 'Pro Striker • Rank 4';
  String _selectedAvatarEmoji = '⚽';
  final int _matchesCount = 16;
  final double _fairPlayScore = 4.9;

  // Saved pitches list
  late List<GroundModel> _savedPitches;

  @override
  void initState() {
    super.initState();
    // Default 4 favorite grounds from DemoData
    _savedPitches = DemoData.grounds.take(4).toList();
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.emeraldDark : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    final user = authState.user;
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardColor = isDark
        ? const Color(0xFF1E293B)
        : AppColors.surfaceSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings & Security',
            icon: Icon(Icons.settings_outlined, color: textColor),
            onPressed: () => _openSettingsSheet(isDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // User Header Card (Interactive: tap to edit profile)
            InkWell(
              onTap: () => _openEditProfileDialog(user, isDark),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF064E3B)
                                : AppColors.emeraldContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.emerald,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _selectedAvatarEmoji.isNotEmpty
                                  ? _selectedAvatarEmoji
                                  : (user?.name.isNotEmpty == true
                                        ? user!.name[0]
                                        : '⚽'),
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _openAvatarPickerSheet(isDark),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                                border: Border.all(color: bgColor, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'Hamza Malik',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: subtextColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.phone ?? '+92 333 5123456',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF365314)
                            : AppColors.limeContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: AppColors.limeDark,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _rankBadge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Player Stats Row (Interactive pills)
            Row(
              children: [
                _buildStatPill(
                  '$_matchesCount',
                  'Matches Played',
                  Icons.sports_soccer,
                  cardColor,
                  textColor,
                  subtextColor,
                  borderColor,
                  onTap: () => _openMatchHistorySheet(isDark),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  '${_savedPitches.length}',
                  'Favorite Pitches',
                  Icons.favorite_rounded,
                  cardColor,
                  textColor,
                  subtextColor,
                  borderColor,
                  onTap: () => _openSavedPitchesSheet(isDark),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  _fairPlayScore.toStringAsFixed(1),
                  'Fair Play Score',
                  Icons.star_rounded,
                  cardColor,
                  textColor,
                  subtextColor,
                  borderColor,
                  onTap: () => _openFairPlaySheet(isDark),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dynamic Switch Role Mode Banner (Player vs Ground Owner)
            Builder(
              builder: (ctx) {
                final isCurrentOwner = ref.watch(authProvider).isOwner;
                return GestureDetector(
                  onTap: () async {
                    if (isCurrentOwner) {
                      _showSnackBar('Switching to Player Mode...');
                      await ref
                          .read(authProvider.notifier)
                          .quickDemoLogin(UserRole.customer);
                      if (context.mounted) {
                        context.go(AppRoutes.customerRoot);
                      }
                    } else {
                      _showSnackBar('Switching to Ground Owner Mode...');
                      await ref
                          .read(authProvider.notifier)
                          .quickDemoLogin(UserRole.owner);
                      if (context.mounted) {
                        context.go(AppRoutes.ownerRoot);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isCurrentOwner
                          ? const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF065F46), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isCurrentOwner
                                      ? AppColors.navy
                                      : AppColors.emerald)
                                  .withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isCurrentOwner
                                ? Icons.sports_soccer_rounded
                                : Icons.stadium_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCurrentOwner
                                    ? 'Switch to Player Mode'
                                    : 'Switch to Ground Owner Mode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCurrentOwner
                                    ? 'Explore sports turfs & book match slots'
                                    : 'Manage arenas, slots & incoming bookings',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Activity Group
            _buildSectionHeader('My Activity', textColor),
            _buildProfileTile(
              Icons.calendar_month_outlined,
              'My Bookings',
              'View upcoming matches & digital passes',
              cardColor,
              textColor,
              subtextColor,
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(2);
                } else {
                  _showSnackBar('Opening Bookings tab');
                }
              },
            ),
            _buildProfileTile(
              Icons.bookmark_outline_rounded,
              'Saved Pitches',
              'Quick access to your ${_savedPitches.length} favorite grounds',
              cardColor,
              textColor,
              subtextColor,
              onTap: () => _openSavedPitchesSheet(isDark),
            ),
            _buildProfileTile(
              Icons.payment_outlined,
              'Payment Methods',
              '${selectedPayment.title} (${selectedPayment.subtitle})',
              cardColor,
              textColor,
              subtextColor,
              onTap: () => showPaymentMethodsSheet(context),
            ),

            const SizedBox(height: 16),

            // Preferences Group
            _buildSectionHeader('Preferences & Settings', textColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.dark_mode_outlined, color: textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          isDark ? 'Dark theme active' : 'Light theme active',
                          style: TextStyle(fontSize: 11, color: subtextColor),
                        ),
                      ],
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
              cardColor,
              textColor,
              subtextColor,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _buildProfileTile(
              Icons.help_outline_rounded,
              'Help & Support',
              'WhatsApp 24/7 pitch support desk',
              cardColor,
              textColor,
              subtextColor,
              onTap: () => _openHelpSupportSheet(isDark),
            ),

            const SizedBox(height: 16),

            // Log Out Button (Interactive confirmation)
            ListTile(
              onTap: () => _openLogoutDialog(context, ref, isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: isDark
                  ? const Color(0xFF450A0A)
                  : const Color(0xFFFEE2E2),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE SHEETS & DIALOGS
  // ---------------------------------------------------------------------------

  /// 1. Settings Sheet
  void _openSettingsSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sheetText = isDark ? Colors.white : AppColors.navy;
            final sheetSubtext = isDark
                ? const Color(0xFF94A3B8)
                : AppColors.textSecondaryLight;
            final tileBg = isDark
                ? const Color(0xFF0F172A)
                : AppColors.surfaceSecondaryLight;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Settings & Security',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: sheetText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biometrics toggle
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fingerprint_rounded,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Biometric Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: sheetText,
                                  ),
                                ),
                                Text(
                                  'Use FaceID / Fingerprint for quick checkouts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: sheetSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: true,
                            activeThumbColor: AppColors.emerald,
                            onChanged: (val) {
                              _showSnackBar(
                                val
                                    ? 'Biometric login enabled'
                                    : 'Biometric login disabled',
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Language Selector
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Language',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: sheetText,
                                  ),
                                ),
                                Text(
                                  'English (Default)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: sheetSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _showSnackBar(
                                'اردو زبان جلد دستیاب ہوگی (Urdu coming soon)',
                                isSuccess: false,
                              );
                            },
                            child: const Text(
                              'اردو',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.emerald,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Clear Cache / Reset Data
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cleaning_services_rounded,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Storage & Cache',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: sheetText,
                                  ),
                                ),
                                Text(
                                  'App cached data: 14.8 MB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: sheetSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _showSnackBar(
                                'Cache cleared successfully! (0 MB)',
                              );
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reset Demo Data
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tileColor: tileBg,
                      leading: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.navy,
                      ),
                      title: Text(
                        'Reset Demo Data',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: sheetText,
                        ),
                      ),
                      subtitle: Text(
                        'Restore pristine university mid-term database',
                        style: TextStyle(fontSize: 11, color: sheetSubtext),
                      ),
                      onTap: () {
                        FakeDatabase.instance.reset();
                        _showSnackBar('Demo database reset to default state');
                        Navigator.pop(ctx);
                      },
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'GroundZero v1.0.0 (Mid-Term Edition)\nMade for Islamabad & Rawalpindi Arenas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: sheetSubtext),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 2. Avatar Picker Sheet
  void _openAvatarPickerSheet(bool isDark) {
    final emojis = ['⚽', '🧤', '🏏', '🎾', '🏀', '⚡', '🏆', '🎯'];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetText = isDark ? Colors.white : AppColors.navy;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Player Avatar',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: sheetText,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: emojis.map((e) {
                  final isSelected = _selectedAvatarEmoji == e;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedAvatarEmoji = e);
                      Navigator.pop(ctx);
                      _showSnackBar('Player avatar updated to $e');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.emeraldContainer
                            : (isDark
                                  ? const Color(0xFF0F172A)
                                  : AppColors.surfaceSecondaryLight),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.emerald
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.emerald),
                  ),
                  icon: const Icon(
                    Icons.add_a_photo_rounded,
                    color: AppColors.emerald,
                  ),
                  label: const Text(
                    'Simulate Camera Upload',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedAvatarEmoji = '🌟');
                    Navigator.pop(ctx);
                    _showSnackBar('Photo uploaded and set as player avatar!');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 3. Edit Profile Dialog
  void _openEditProfileDialog(UserModel? user, bool isDark) {
    final nameController = TextEditingController(
      text: user?.name ?? 'Hamza Malik',
    );
    final phoneController = TextEditingController(
      text: user?.phone ?? '+92 333 5123456',
    );
    String selectedRank = _rankBadge;

    showDialog(
      context: context,
      builder: (ctx) {
        final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final dialogText = isDark ? Colors.white : AppColors.navy;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Player Profile',
            style: TextStyle(fontWeight: FontWeight.w800, color: dialogText),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: dialogText),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: dialogText),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Position / Skill Badge',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dialogText,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedRank,
                  dropdownColor: dialogBg,
                  style: TextStyle(
                    color: dialogText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Pro Striker • Rank 4',
                      child: Text('⚽ Pro Striker • Rank 4'),
                    ),
                    DropdownMenuItem(
                      value: 'Safe Hands Goalkeeper',
                      child: Text('🧤 Safe Hands Goalkeeper'),
                    ),
                    DropdownMenuItem(
                      value: 'Elite Playmaker • Rank 5',
                      child: Text('⚡ Elite Playmaker • Rank 5'),
                    ),
                    DropdownMenuItem(
                      value: 'All-Rounder Captain',
                      child: Text('🏏 All-Rounder Captain'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedRank = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newPhone = phoneController.text.trim();
                if (newName.isNotEmpty) {
                  final updated =
                      (user ??
                              const UserModel(
                                id: 'customer_sport_demo',
                                name: '',
                                email: '',
                                phone: '',
                                role: UserRole.customer,
                              ))
                          .copyWith(name: newName, phone: newPhone);
                  await ref.read(authProvider.notifier).updateUser(updated);
                  setState(() {
                    _rankBadge = selectedRank;
                  });
                  _showSnackBar('Profile updated for $newName');
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 4. Match History Breakdown Sheet
  void _openMatchHistorySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetText = isDark ? Colors.white : AppColors.navy;
        final sheetSubtext = isDark
            ? const Color(0xFF94A3B8)
            : AppColors.textSecondaryLight;
        final cardBg = isDark
            ? const Color(0xFF0F172A)
            : AppColors.surfaceSecondaryLight;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Player Match Record',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: sheetText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '16 Matches',
                      style: TextStyle(
                        color: AppColors.emeraldDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Win/Draw/Loss Pills
              Row(
                children: [
                  _buildMatchRecordPill('10 Won', Colors.green, cardBg),
                  const SizedBox(width: 8),
                  _buildMatchRecordPill('4 Drawn', Colors.orange, cardBg),
                  const SizedBox(width: 8),
                  _buildMatchRecordPill('2 Lost', Colors.red, cardBg),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Recent Pitch Appearances',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: sheetText,
                ),
              ),
              const SizedBox(height: 8),
              _buildRecentMatchItem(
                'Rawal Sports Arena (F-7)',
                '5-a-side vs F-7 Wolves',
                'Won 7 - 4',
                'Yesterday',
                sheetText,
                sheetSubtext,
                cardBg,
              ),
              _buildRecentMatchItem(
                'Margalla Turf Club (E-11)',
                '7-a-side Friendly',
                'Draw 3 - 3',
                '3 days ago',
                sheetText,
                sheetSubtext,
                cardBg,
              ),
              _buildRecentMatchItem(
                'Capital Padel Club (F-10)',
                'Padel Doubles Match',
                'Won 2 - 0 sets',
                'Last weekend',
                sheetText,
                sheetSubtext,
                cardBg,
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'View All Bookings & Passes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigateTab?.call(2);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchRecordPill(String title, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMatchItem(
    String arena,
    String desc,
    String result,
    String time,
    Color textColor,
    Color subtextColor,
    Color bg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arena,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                Text(
                  '$desc • $time',
                  style: TextStyle(fontSize: 10, color: subtextColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: result.startsWith('Won')
                  ? AppColors.emeraldContainer
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: result.startsWith('Won')
                    ? AppColors.emeraldDark
                    : textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Saved Pitches Sheet
  void _openSavedPitchesSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sheetText = isDark ? Colors.white : AppColors.navy;
            final sheetSubtext = isDark
                ? const Color(0xFF94A3B8)
                : AppColors.textSecondaryLight;
            final cardBg = isDark
                ? const Color(0xFF0F172A)
                : AppColors.surfaceSecondaryLight;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Pitches (${_savedPitches.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: sheetText,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.explore_rounded,
                            size: 16,
                            color: AppColors.emerald,
                          ),
                          label: const Text(
                            'Explore More',
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onNavigateTab?.call(1);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_savedPitches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'No saved pitches yet.\nExplore grounds to bookmark your favorites!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: sheetSubtext, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ..._savedPitches.map((ground) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  ground.primaryImage,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 60,
                                        height: 60,
                                        color: AppColors.emeraldContainer,
                                        child: const Icon(
                                          Icons.sports_soccer,
                                          color: AppColors.emerald,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ground.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: sheetText,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ground.location,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sheetSubtext,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        Text(
                                          ' ${ground.rating}  •  ',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: sheetText,
                                          ),
                                        ),
                                        Text(
                                          'PKR ${ground.pricePerHour.toInt()}/hr',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.emerald,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    tooltip: 'Remove from Favorites',
                                    onPressed: () {
                                      setSheetState(() {
                                        _savedPitches.removeWhere(
                                          (g) => g.id == ground.id,
                                        );
                                      });
                                      setState(() {});
                                      _showSnackBar(
                                        'Removed ${ground.name} from saved pitches',
                                      );
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.push(
                                        '/customer/book/${ground.id}',
                                      );
                                    },
                                    child: const Text(
                                      'Book',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 6. Fair Play Score Sheet
  void _openFairPlaySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetText = isDark ? Colors.white : AppColors.navy;
        final sheetSubtext = isDark
            ? const Color(0xFF94A3B8)
            : AppColors.textSecondaryLight;
        final cardBg = isDark
            ? const Color(0xFF0F172A)
            : AppColors.surfaceSecondaryLight;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.emerald,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fair Play Score Rating',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: sheetText,
                          ),
                        ),
                        Text(
                          'Sportsmanship score across all bookings',
                          style: TextStyle(fontSize: 11, color: sheetSubtext),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_fairPlayScore',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.emeraldDark,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildScoreBar(
                'Punctuality (Arrives 10m early)',
                5.0,
                Colors.green,
                sheetText,
                cardBg,
              ),
              _buildScoreBar(
                'Pitch Etiquette & Conduct',
                4.9,
                AppColors.emerald,
                sheetText,
                cardBg,
              ),
              _buildScoreBar(
                'Zero Disciplinary Violations',
                5.0,
                Colors.blue,
                sheetText,
                cardBg,
              ),
              _buildScoreBar(
                'Prompt Payment Clearance',
                4.8,
                Colors.orange,
                sheetText,
                cardBg,
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B)
                      : AppColors.limeContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.limeDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verified Elite Sportsman: You get priority booking rights during prime 8 PM - 11 PM slots!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBar(
    String title,
    double score,
    Color color,
    Color textColor,
    Color bg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Text(
            '$score / 5.0',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 9. Help & Support Sheet
  void _openHelpSupportSheet(bool isDark) {
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetText = isDark ? Colors.white : AppColors.navy;
        final sheetSubtext = isDark
            ? const Color(0xFF94A3B8)
            : AppColors.textSecondaryLight;
        final cardBg = isDark
            ? const Color(0xFF0F172A)
            : AppColors.surfaceSecondaryLight;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Help & Pitch Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetText,
                  ),
                ),
                Text(
                  '24/7 assistance for match slots in Islamabad & Rawalpindi',
                  style: TextStyle(fontSize: 11, color: sheetSubtext),
                ),
                const SizedBox(height: 16),

                // WhatsApp Support Action
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: const Color(0xFFDCFCE7),
                  leading: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF15803D),
                  ),
                  title: const Text(
                    'WhatsApp 24/7 Concierge',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  subtitle: const Text(
                    '+92 333 5123456 • Instant response for slot queries',
                    style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF15803D),
                  ),
                  onTap: () {
                    _showSnackBar(
                      'Connecting to GroundZero WhatsApp concierge...',
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Direct Call Helpline
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: cardBg,
                  leading: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: AppColors.emerald,
                  ),
                  title: Text(
                    'Helpline: +92 (51) 8899000',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: sheetText,
                    ),
                  ),
                  subtitle: Text(
                    'Call GroundZero operational desk',
                    style: TextStyle(fontSize: 11, color: sheetSubtext),
                  ),
                  onTap: () {
                    _showSnackBar(
                      'Dialing GroundZero Hotline: +92 (51) 8899000',
                    );
                  },
                ),

                const SizedBox(height: 14),

                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: sheetText,
                  ),
                ),
                const SizedBox(height: 6),
                _buildFaqItem(
                  'Can I cancel or reschedule a booking?',
                  'Yes, cancellations made up to 6 hours before kickoff receive a 100% wallet credit or refund.',
                  sheetText,
                  sheetSubtext,
                  cardBg,
                ),
                _buildFaqItem(
                  'What if it rains on an outdoor pitch?',
                  'Ground owners notify players 2 hours prior and issue an automatic rain-check rescheduling token.',
                  sheetText,
                  sheetSubtext,
                  cardBg,
                ),

                const SizedBox(height: 14),
                Text(
                  'Send Feedback / Report an Issue',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: sheetText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: feedbackController,
                  maxLines: 2,
                  style: TextStyle(color: sheetText, fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Type your issue, pitch recommendation, or complaint...',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final text = feedbackController.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(ctx);
                        _showSnackBar(
                          'Thank you! Your feedback has been sent to our desk.',
                        );
                      } else {
                        _showSnackBar(
                          'Please enter your feedback first',
                          isSuccess: false,
                        );
                      }
                    },
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(
    String q,
    String a,
    Color textColor,
    Color subtextColor,
    Color bg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          q,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Text(
              a,
              style: TextStyle(fontSize: 11, color: subtextColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 10. Logout Confirmation Dialog
  void _openLogoutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final dialogText = isDark ? Colors.white : AppColors.navy;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              Text(
                'Log Out?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: dialogText,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out of GroundZero? You will need to log back in to access your digital passes and pitch reservations.',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                _showSnackBar('Logging out of GroundZero...');
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildStatPill(
    String value,
    String label,
    IconData icon,
    Color bg,
    Color textColor,
    Color subtextColor,
    Color borderColor, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: AppColors.emerald),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    IconData icon,
    String title,
    String subtitle,
    Color bg,
    Color textColor,
    Color subtextColor, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: AppColors.emerald, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: subtextColor),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: subtextColor,
        ),
      ),
    );
  }
}
