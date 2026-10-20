import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'customer_home_screen.dart';
import 'customer_explore_screen.dart';
import 'customer_bookings_screen.dart';
import '../../ai/screens/ai_assistant_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainShell extends StatefulWidget {
  final int initialTab;

  const CustomerMainShell({super.key, this.initialTab = 0});

  @override
  State<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends State<CustomerMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.borderLight;

    final List<Widget> screens = [
      CustomerHomeScreen(onNavigateTab: _onTabSelected),
      const CustomerExploreScreen(),
      const CustomerBookingsScreen(),
      const AiAssistantScreen(),
      CustomerProfileScreen(onNavigateTab: _onTabSelected),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.sports_soccer_rounded, 'Home', isDark),
                _buildNavItem(1, Icons.explore_outlined, 'Explore', isDark),
                _buildNavItem(
                  2,
                  Icons.confirmation_number_outlined,
                  'Bookings',
                  isDark,
                ),
                _buildNavItem(3, Icons.smart_toy_outlined, 'GroundBot', isDark),
                _buildNavItem(
                  4,
                  Icons.person_outline_rounded,
                  'Profile',
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final selectedBg = isDark
        ? AppColors.emerald.withValues(alpha: 0.2)
        : AppColors.emeraldContainer;
    final selectedFg = isDark ? AppColors.emeraldLight : AppColors.emeraldDark;
    final unselectedFg = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isSelected ? selectedFg : unselectedFg),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? selectedFg : unselectedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
