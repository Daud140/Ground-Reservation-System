import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../booking/models/booking_model.dart';

class CustomerBookingsScreen extends ConsumerStatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  ConsumerState<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends ConsumerState<CustomerBookingsScreen> {
  int _activeTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  @override
  Widget build(BuildContext context) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Match Passes',
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
          final bookings = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTab('Upcoming', 0),
                    const SizedBox(width: 8),
                    _buildTab('Completed', 1),
                    const SizedBox(width: 8),
                    _buildTab('Cancelled', 2),
                  ],
                ),
              ),
              Expanded(
                child: bookings.isEmpty
                    ? const Center(child: Text('No bookings recorded yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.groundName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navy,
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
                                const SizedBox(height: 6),
                                Text(
                                  '${booking.date} • ${booking.timeSlot}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PKR ${booking.totalPrice.toInt()} Paid',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.emeraldDark),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => context.push('/customer/ticket/${booking.id}', extra: booking),
                                      icon: const Icon(Icons.qr_code, size: 16),
                                      label: const Text('View Pass', style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.navy,
                                        side: const BorderSide(color: AppColors.borderLight),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      ),
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

  Widget _buildTab(String label, int index) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : AppColors.surfaceSecondaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
