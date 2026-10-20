import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notification_provider.dart';

class OwnerBookingRequestsScreen extends ConsumerStatefulWidget {
  const OwnerBookingRequestsScreen({super.key});

  @override
  ConsumerState<OwnerBookingRequestsScreen> createState() =>
      _OwnerBookingRequestsScreenState();
}

class _OwnerBookingRequestsScreenState
    extends ConsumerState<OwnerBookingRequestsScreen> {
  int _selectedFilterIndex =
      0; // 0: All, 1: Pending, 2: Confirmed, 3: Completed

  Future<void> _updateStatus(
    String bookingId,
    BookingStatus newStatus, [
    double? price,
  ]) async {
    final bookingRepo = ref.read(bookingRepositoryProvider);
    await bookingRepo.updateBookingStatus(bookingId, newStatus);

    // Trigger persistent notification
    if (newStatus == BookingStatus.confirmed) {
      ref
          .read(notificationsProvider.notifier)
          .addNotification(
            title: 'Booking Confirmed!',
            body: 'Slot #$bookingId confirmed. Customer has been alerted.',
            type: NotificationType.bookingConfirmed,
            bookingId: bookingId,
          );
    } else if (newStatus == BookingStatus.cancelled) {
      ref
          .read(notificationsProvider.notifier)
          .addNotification(
            title: 'Booking Cancelled',
            body: 'Booking #$bookingId was cancelled. Schedule reopened.',
            type: NotificationType.bookingCancelled,
            bookingId: bookingId,
          );
    }

    setState(() {});
    if (!mounted) return;
    String message;
    if (newStatus == BookingStatus.confirmed) {
      message = price != null
          ? 'Booking confirmed! Owner revenue increased by PKR ${price.toInt()}.'
          : 'Booking request accepted!';
    } else if (newStatus == BookingStatus.cancelled) {
      message = price != null
          ? 'Booking cancelled. Owner revenue reduced by PKR ${price.toInt()}.'
          : 'Booking cancelled.';
    } else {
      message = 'Booking rejected. Revenue unaffected.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newStatus == BookingStatus.confirmed
            ? AppColors.emerald
            : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);
    final authState = ref.watch(authProvider);
    final ownerId = authState.user?.id ?? 'owner_sport_demo';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Booking Requests',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: bookingRepo.getAllBookings(),
        builder: (context, snapshot) {
          final allBookings = (snapshot.data ?? [])
              .where((b) => b.ownerId == ownerId)
              .toList();

          final pendingList = allBookings
              .where((b) => b.status == BookingStatus.pending)
              .toList();
          final confirmedList = allBookings
              .where((b) => b.status == BookingStatus.confirmed)
              .toList();
          final completedList = allBookings
              .where((b) => b.status == BookingStatus.completed)
              .toList();

          List<BookingModel> displayedBookings;
          switch (_selectedFilterIndex) {
            case 1:
              displayedBookings = pendingList;
              break;
            case 2:
              displayedBookings = confirmedList;
              break;
            case 3:
              displayedBookings = completedList;
              break;
            default:
              displayedBookings = allBookings;
              break;
          }

          return Column(
            children: [
              // Filter Tabs Header
              Container(
                color: cardColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _buildFilterTab('All', 0, allBookings.length, isDark),
                    const SizedBox(width: 8),
                    _buildFilterTab('Pending', 1, pendingList.length, isDark),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      'Confirmed',
                      2,
                      confirmedList.length,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      'Completed',
                      3,
                      completedList.length,
                      isDark,
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: borderColor),

              // Booking Requests List
              Expanded(
                child: displayedBookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings in this category',
                          style: TextStyle(color: subtextColor),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = displayedBookings[index];
                          return _buildRequestCard(
                            booking,
                            isDark: isDark,
                            cardColor: cardColor,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
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

  Widget _buildFilterTab(String label, int index, int count, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.emerald
                : (isDark
                      ? AppColors.surfaceSecondaryDark
                      : AppColors.surfaceSecondaryLight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BookingModel booking, {
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    final isPending = booking.status == BookingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer name & phone
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    booking.customerName.isNotEmpty
                        ? booking.customerName[0]
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.emeraldDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
                      booking.customerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      booking.customerPhone,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          const SizedBox(height: 12),
          Divider(color: borderColor),
          const SizedBox(height: 8),

          // Match Slot Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: subtextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.date} • ${booking.timeSlot}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                'PKR ${booking.totalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),

          // Advance status
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 14,
                color: AppColors.emerald,
              ),
              const SizedBox(width: 6),
              Text(
                'Payment: ${booking.paymentMethod}',
                style: TextStyle(fontSize: 11, color: subtextColor),
              ),
            ],
          ),

          // Action Buttons if pending
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                      booking.id,
                      BookingStatus.rejected,
                      booking.totalPrice,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(
                      booking.id,
                      BookingStatus.confirmed,
                      booking.totalPrice,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Accept Request',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action Button if confirmed (allow cancelling to test revenue decrease)
          if (booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(
                  booking.id,
                  BookingStatus.cancelled,
                  booking.totalPrice,
                ),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text(
                  'Cancel Booking (Reduces Revenue)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
