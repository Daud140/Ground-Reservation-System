import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../shared/widgets/app_logo.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const OwnerDashboardScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bookingRepo = ref.watch(bookingRepositoryProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<List<BookingModel>>(
          future: bookingRepo.getAllBookings(),
          builder: (context, snapshot) {
            final bookings = snapshot.data ?? [];
            final ownerId = user?.id ?? 'owner_1';
            final ownerBookings = bookings.where((b) => b.ownerId == ownerId || (user?.isOwner ?? true)).toList();
            // Task 7: Revenue increases when confirmed, never increases for unconfirmed/cancelled, reduces if cancelled
            final confirmedRevenue = ownerBookings
                .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.completed)
                .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
            final todayBookings = ownerBookings.take(4).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const GroundZeroLogo(size: 24),
                            const SizedBox(width: 8),
                            // Owner Mode Pill
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield, color: AppColors.emeraldDark, size: 13),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Owner Mode',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.emeraldDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notifications
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 18),
                      ),
                      const SizedBox(width: 8),
                      // Switch to customer role quickly
                      InkWell(
                        onTap: () {
                          context.go(AppRoutes.customerRoot);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.sports_soccer, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Welcome Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${user?.name ?? 'Hamza'}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Apex Arena • Islamabad',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onNavigateTab?.call(2), // Manage Ground
                        icon: const Icon(Icons.settings_outlined, color: AppColors.navy),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Revenue / Earnings Card (Dark Emerald Gradient)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Total Revenue (Confirmed)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.lime,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${ownerBookings.where((b) => b.status == BookingStatus.confirmed).length} Confirmed',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PKR ${confirmedRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Total confirmed revenue is PKR ${confirmedRevenue.toInt()}')),
                                  );
                                },
                                icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                                label: const Text('View Payout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.navy,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => widget.onNavigateTab?.call(2),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Slot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Weekly Slot Utilization Chart Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Weekly Slot Utilization',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Peak: Fri (92%)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emeraldDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Bar Chart Row (Mon - Sun)
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBarColumn('Mon', 0.55),
                              _buildBarColumn('Tue', 0.62),
                              _buildBarColumn('Wed', 0.70),
                              _buildBarColumn('Thu', 0.85),
                              _buildBarColumn('Fri', 0.95, isPeak: true), // Peak Friday in Lime
                              _buildBarColumn('Sat', 0.90),
                              _buildBarColumn('Sun', 0.82),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // KPI Metric Pills Row: [Bookings Count] & [Occupancy]
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppColors.emerald, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${ownerBookings.length} Bookings', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy)),
                                    const Text('Total Bookings', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.pie_chart_outline_rounded, color: AppColors.limeDark, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('92% Occupancy', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy)),
                                    Text('Evening slots', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Today's Bookings Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Today's Bookings",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateTab?.call(1), // View all requests
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: AppColors.emeraldDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Today's Bookings List Cards
                  if (todayBookings.isNotEmpty) ...[
                    ...todayBookings.map((b) => _buildTodayBookingCard(b)),
                  ] else ...[
                    _buildSampleBookingCard('06:00 PM - 07:00 PM', 'Ali Raza (5v5)', 4500, true),
                    _buildSampleBookingCard('08:00 PM - 09:00 PM', 'Zain Malik (5v5)', 4500, false),
                  ],

                  const SizedBox(height: 90), // Bottom padding for navigation
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBarColumn(String day, double heightFactor, {bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPeak)
          const Text('92%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emeraldDark)),
        Container(
          width: 28,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.lime : AppColors.emeraldContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPeak ? AppColors.limeDark : AppColors.emerald,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
            color: isPeak ? AppColors.navy : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayBookingCard(BookingModel booking) {
    final isConfirmed = booking.status == BookingStatus.confirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  booking.timeSlot.split(' - ').first,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const Text('Start', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.timeSlot} • PKR ${booking.totalPrice.toInt()}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.emeraldContainer : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isConfirmed ? 'Confirmed' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isConfirmed ? AppColors.emeraldDark : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleBookingCard(String time, String client, int price, bool isConfirmed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  time.split(' - ').first,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const Text('Start', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time • PKR $price',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.emeraldContainer : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isConfirmed ? 'Confirmed' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isConfirmed ? AppColors.emeraldDark : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
