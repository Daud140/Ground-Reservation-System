import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../customer/models/ground_model.dart';
import '../models/booking_model.dart';

class SlotBookingScreen extends ConsumerStatefulWidget {
  final String groundId;

  const SlotBookingScreen({super.key, required this.groundId});

  @override
  ConsumerState<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends ConsumerState<SlotBookingScreen> {
  late DateTime _selectedDate;
  String _selectedCourt = 'Pitch A (5v5)';
  String? _selectedTimeSlot;
  bool _isBookingLoading = false;

  final List<String> _morningSlots = [
    '07:00 AM - 08:00 AM',
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
  ];

  final List<String> _afternoonSlots = [
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
  ];

  final List<String> _eveningSlots = [
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
    '08:00 PM - 09:00 PM', // Default match in screenshot
    '09:00 PM - 10:00 PM',
    '10:00 PM - 11:00 PM',
    '11:00 PM - 12:00 AM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTimeSlot = '08:00 PM - 09:00 PM'; // Pre-selected as shown in UI
  }

  Future<void> _handleConfirmBooking(GroundModel ground) async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available time slot')),
      );
      return;
    }

    setState(() => _isBookingLoading = true);

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      final bookingRepo = ref.read(bookingRepositoryProvider);

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final bookingId = 'GZ-${const Uuid().v4().substring(0, 6).toUpperCase()}';

      final newBooking = BookingModel(
        id: bookingId,
        groundId: ground.id,
        groundName: ground.name,
        groundLocation: ground.location,
        sportType: ground.sportType,
        customerId: user?.id ?? 'customer_1',
        customerName: user?.name ?? 'Ali Raza',
        customerPhone: user?.phone ?? '+92 300 1234567',
        ownerId: ground.ownerId,
        date: dateStr,
        timeSlot: _selectedTimeSlot!,
        totalPrice: ground.pricePerHour,
        status: BookingStatus.confirmed,
        paymentMethod: 'JazzCash / EasyPaisa',
        qrCodeData: 'GROUNDZERO-$bookingId-${ground.id}-$dateStr',
        createdAt: DateTime.now(),
      );

      await bookingRepo.createBooking(newBooking);

      if (!mounted) return;
      // Navigate to confirmation screen
      context.pushReplacement('/customer/ticket/$bookingId', extra: newBooking);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBookingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);

    return FutureBuilder<GroundModel?>(
      future: groundRepo.getGroundById(widget.groundId),
      builder: (context, snapshot) {
        final ground = snapshot.data;

        if (ground == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.emerald)),
          );
        }

        final double baseRate = ground.pricePerHour;
        const double serviceFee = 200.0;
        const double platformDiscount = 500.0;
        final double totalPayable = (baseRate + serviceFee - platformDiscount).clamp(0, 99999);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              ground.name,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.navy, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selector Header & Day Cards
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalDatePicker(),

                    const SizedBox(height: 20),

                    // Court / Pitch Selector
                    const Text(
                      'Select Court',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildCourtPill('Pitch A (5v5)'),
                        const SizedBox(width: 10),
                        _buildCourtPill('Pitch B (7v7)'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Slot Legend
                    Row(
                      children: [
                        _buildLegendItem(AppColors.emerald, 'Selected'),
                        const SizedBox(width: 16),
                        _buildLegendItem(AppColors.borderLight, 'Available', isBorder: true),
                        const SizedBox(width: 16),
                        _buildLegendItem(const Color(0xFFE2E8F0), 'Booked'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Slot Category: Afternoon
                    _buildSlotSection('Afternoon Slots', _afternoonSlots),
                    const SizedBox(height: 16),

                    // Slot Category: Evening / Night (Peak)
                    _buildSlotSection('Evening & Night Slots (Floodlit)', _eveningSlots),
                    const SizedBox(height: 16),

                    // Slot Category: Morning
                    _buildSlotSection('Morning Slots', _morningSlots),

                    const SizedBox(height: 24),

                    // Booking Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Breakdown',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCostRow('Hourly Pitch Rate', 'PKR ${baseRate.toInt()}'),
                          const SizedBox(height: 6),
                          _buildCostRow('Lighting & Service Fee', 'PKR ${serviceFee.toInt()}'),
                          const SizedBox(height: 6),
                          _buildCostRow('App Welcome Voucher', '- PKR ${platformDiscount.toInt()}', isDiscount: true),
                          const Divider(height: 20, color: AppColors.borderLight),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Payable',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              Text(
                                'PKR ${totalPayable.toInt()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emeraldDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 120), // Bottom padding for sticky button
                  ],
                ),
              ),

              // Sticky Bottom Payment Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                            Text(
                              'PKR ${totalPayable.toInt()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                          width: 180,
                          child: ElevatedButton(
                            onPressed: _isBookingLoading ? null : () => _handleConfirmBooking(ground),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: AppColors.emerald.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isBookingLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Proceed to Pay',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizontalDatePicker() {
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.day == _selectedDate.day &&
              day.month == _selectedDate.month &&
              day.year == _selectedDate.year;

          final weekDay = DateFormat('EEE').format(day);
          final dayNum = DateFormat('dd').format(day);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF064E3B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF064E3B) : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourtPill(String courtName) {
    final isSelected = _selectedCourt == courtName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCourt = courtName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emeraldContainer : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.emerald : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              courtName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.emeraldDark : AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  Widget _buildSlotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            // Mark 09:00 AM as already booked for demonstration
            final isBooked = slot == '09:00 AM - 10:00 AM';

            return GestureDetector(
              onTap: isBooked ? null : () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.emerald
                      : isBooked
                          ? const Color(0xFFF1F5F9)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.emerald
                        : isBooked
                            ? const Color(0xFFE2E8F0)
                            : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check_circle, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isBooked
                                ? AppColors.textMutedLight
                                : AppColors.navy,
                        decoration: isBooked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, String amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? AppColors.emeraldDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.emeraldDark : AppColors.navy,
          ),
        ),
      ],
    );
  }
}
