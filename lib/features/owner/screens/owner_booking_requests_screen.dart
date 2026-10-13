import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../booking/models/booking_model.dart';

class OwnerBookingRequestsScreen extends ConsumerStatefulWidget {
  const OwnerBookingRequestsScreen({super.key});

  @override
  ConsumerState<OwnerBookingRequestsScreen> createState() => _OwnerBookingRequestsScreenState();
}

class _OwnerBookingRequestsScreenState extends ConsumerState<OwnerBookingRequestsScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: Confirmed, 3: Completed

  Future<void> _updateStatus(String bookingId, BookingStatus newStatus) async {
    final bookingRepo = ref.read(bookingRepositoryProvider);
    await bookingRepo.updateBookingStatus(bookingId, newStatus);
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus == BookingStatus.confirmed ? 'Booking request accepted!' : 'Booking rejected.'),
        backgroundColor: newStatus == BookingStatus.confirmed ? AppColors.emerald : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: bookingRepo.getAllBookings(),
        builder: (context, snapshot) {
          final allBookings = snapshot.data ?? [];

          final pendingList = allBookings.where((b) => b.status == BookingStatus.pending).toList();
          final confirmedList = allBookings.where((b) => b.status == BookingStatus.confirmed).toList();
          final completedList = allBookings.where((b) => b.status == BookingStatus.completed).toList();

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
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterTab('All', 0, allBookings.length),
                    const SizedBox(width: 8),
                    _buildFilterTab('Pending', 1, pendingList.length),
                    const SizedBox(width: 8),
                    _buildFilterTab('Confirmed', 2, confirmedList.length),
                    const SizedBox(width: 8),
                    _buildFilterTab('Completed', 3, completedList.length),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.borderLight),

              // Booking Requests List
              Expanded(
                child: displayedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'No bookings in this category',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = displayedBookings[index];
                          return _buildRequestCard(booking);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String label, int index, int count) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : AppColors.surfaceSecondaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BookingModel booking) {
    final isPending = booking.status == BookingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Header: Customer name & phone
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.emeraldContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    booking.customerName.isNotEmpty ? booking.customerName[0] : 'U',
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      booking.customerPhone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
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
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 8),

          // Match Slot Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.date} • ${booking.timeSlot}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              Text(
                'PKR ${booking.totalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emeraldDark,
                ),
              ),
            ],
          ),

          // Advance status
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: AppColors.emerald),
              const SizedBox(width: 6),
              Text(
                'Payment: ${booking.paymentMethod}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
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
                    onPressed: () => _updateStatus(booking.id, BookingStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(booking.id, BookingStatus.confirmed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accept Request', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
