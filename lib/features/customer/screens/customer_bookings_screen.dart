import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/map_launcher.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notification_provider.dart';

class CustomerBookingsScreen extends ConsumerStatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  ConsumerState<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState
    extends ConsumerState<CustomerBookingsScreen> {
  int _activeTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  @override
  Widget build(BuildContext context) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);
    final authState = ref.watch(authProvider);
    final currentCustomerId = authState.user?.id ?? 'customer_sport_demo';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;
    final tabBgColor = isDark
        ? const Color(0xFF0F172A)
        : AppColors.surfaceSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'My Match Passes',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: bookingRepo.getAllBookings(),
        builder: (context, snapshot) {
          final allBookings = snapshot.data ?? [];
          final customerBookings = allBookings
              .where(
                (b) =>
                    b.customerId == currentCustomerId ||
                    b.customerId == 'customer_sport_demo',
              )
              .toList();

          final filteredBookings = customerBookings.where((b) {
            if (_activeTab == 0) {
              return b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending;
            } else if (_activeTab == 1) {
              return b.status == BookingStatus.completed;
            } else {
              return b.status == BookingStatus.cancelled ||
                  b.status == BookingStatus.rejected;
            }
          }).toList();

          return Column(
            children: [
              Container(
                color: bgColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildTab('Upcoming', 0, isDark, tabBgColor, subtextColor),
                    const SizedBox(width: 8),
                    _buildTab('Completed', 1, isDark, tabBgColor, subtextColor),
                    const SizedBox(width: 8),
                    _buildTab('Cancelled', 2, isDark, tabBgColor, subtextColor),
                  ],
                ),
              ),
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings in this tab',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          final canCancel =
                              booking.status == BookingStatus.confirmed ||
                              booking.status == BookingStatus.pending;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking.groundName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: booking.status.containerColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        booking.status.displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: booking.status.statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${booking.date} • ${booking.timeSlot}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtextColor,
                                  ),
                                ),
                                if (booking.groundLocation.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                        color: AppColors.emerald,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          booking.groundLocation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subtextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PKR ${booking.totalPrice.toInt()} Paid',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.emeraldDark,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Directions Button
                                        IconButton(
                                          tooltip: 'Open in Google Maps',
                                          icon: const Icon(
                                            Icons.directions_outlined,
                                            size: 20,
                                            color: AppColors.emerald,
                                          ),
                                          onPressed: () {
                                            MapLauncher.openCoordinates(
                                              context: context,
                                              latitude: 33.7215,
                                              longitude: 73.0560,
                                              title: booking.groundName,
                                            );
                                          },
                                        ),
                                        if (canCancel) ...[
                                          TextButton.icon(
                                            onPressed: () async {
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  title: const Text(
                                                    'Cancel Booking?',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to cancel this booking (${booking.groundName} - PKR ${booking.totalPrice.toInt()})?\n\nIf confirmed, this will reduce owner revenue accordingly.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Keep Booking',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors.error,
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Confirm Cancel',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                await bookingRepo.cancelBooking(
                                                  booking.id,
                                                );

                                                // Trigger notification
                                                ref
                                                    .read(
                                                      notificationsProvider
                                                          .notifier,
                                                    )
                                                    .addNotification(
                                                      title:
                                                          'Booking Cancelled',
                                                      body:
                                                          'Your reservation for ${booking.groundName} on ${booking.date} (${booking.timeSlot}) has been cancelled.',
                                                      type: NotificationType
                                                          .bookingCancelled,
                                                      bookingId: booking.id,
                                                    );

                                                setState(() {});
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Booking cancelled. Owner revenue reduced accordingly.',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.error,
                                                        ),
                                                      );
                                                }
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              size: 14,
                                              color: AppColors.error,
                                            ),
                                            label: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: AppColors.error,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        OutlinedButton.icon(
                                          onPressed: () => context.push(
                                            '/customer/ticket/${booking.id}',
                                            extra: booking,
                                          ),
                                          icon: Icon(
                                            Icons.qr_code,
                                            size: 16,
                                            color: textColor,
                                          ),
                                          label: Text(
                                            'View Pass',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textColor,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: borderColor,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(
    String label,
    int index,
    bool isDark,
    Color tabBgColor,
    Color subtextColor,
  ) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : tabBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : subtextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
