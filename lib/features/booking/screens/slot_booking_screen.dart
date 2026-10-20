import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/demo/fake_database.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../customer/models/ground_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../payment/models/payment_method_model.dart';
import '../../payment/providers/payment_provider.dart';
import '../../payment/widgets/payment_methods_sheet.dart';
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
    '11:00 AM - 12:00 PM',
  ];

  final List<String> _afternoonSlots = [
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
  ];

  final List<String> _eveningSlots = [
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
    '08:00 PM - 09:00 PM',
    '09:00 PM - 10:00 PM',
    '10:00 PM - 11:00 PM',
    '11:00 PM - 12:00 AM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _handleConfirmBooking(
    GroundModel ground,
    PaymentMethodModel paymentMethod,
  ) async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot first'),
          backgroundColor: AppColors.error,
        ),
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
        customerId: user?.id ?? 'customer_sport_demo',
        customerName: user?.name ?? 'Ali Raza',
        customerPhone: user?.phone ?? '+92 300 1234567',
        ownerId: ground.ownerId,
        date: dateStr,
        timeSlot: _selectedTimeSlot!,
        totalPrice: ground.pricePerHour,
        status: BookingStatus.confirmed,
        paymentMethod: '${paymentMethod.title} (${paymentMethod.subtitle})',
        qrCodeData: 'GROUNDZERO-$bookingId-${ground.id}-$dateStr',
        createdAt: DateTime.now(),
      );

      await bookingRepo.createBooking(newBooking);

      // Trigger real notification and persist
      ref
          .read(notificationsProvider.notifier)
          .addNotification(
            title: 'Booking Confirmed! ⚽',
            body:
                'Your slot at ${ground.name} is confirmed for $dateStr ($_selectedTimeSlot).',
            type: NotificationType.bookingConfirmed,
            bookingId: bookingId,
          );

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
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final secondaryCardColor = isDark
        ? const Color(0xFF0F172A)
        : AppColors.surfaceSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return FutureBuilder<GroundModel?>(
      future: groundRepo.getGroundById(widget.groundId),
      builder: (context, snapshot) {
        final ground = snapshot.data;

        if (ground == null) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            ),
          );
        }

        final double baseRate = ground.pricePerHour;
        const double serviceFee = 200.0;
        const double platformDiscount = 500.0;
        final double totalPayable = (baseRate + serviceFee - platformDiscount)
            .clamp(0, 99999);

        // Dynamically identify booked slots for selected date
        final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
        final bookedSlots = FakeDatabase.instance
            .getBookingsForGroundAndDate(widget.groundId, dateFormatted)
            .where(
              (b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending,
            )
            .map((b) => b.timeSlot)
            .toSet();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              ground.name,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Section: Select Date
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalDatePicker(isDark, textColor, subtextColor),

                    const SizedBox(height: 20),

                    // Section: Select Court/Pitch
                    Text(
                      'Select Court',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCourtPill(
                          'Pitch A (5v5)',
                          isDark,
                          textColor,
                          cardColor,
                        ),
                        const SizedBox(width: 12),
                        _buildCourtPill(
                          'Pitch B (7v7)',
                          isDark,
                          textColor,
                          cardColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section: Slot Availability
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Time Slots',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _buildLegendItem(AppColors.emerald, 'Selected'),
                            _buildLegendItem(
                              borderColor,
                              'Available',
                              isBorder: true,
                            ),
                            _buildLegendItem(
                              isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                              'Booked',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Slot Category: Afternoon
                    _buildSlotSection(
                      'Afternoon Slots',
                      _afternoonSlots,
                      bookedSlots,
                      isDark,
                      textColor,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 16),

                    // Slot Category: Evening / Night (Peak)
                    _buildSlotSection(
                      'Evening & Night Slots (Floodlit)',
                      _eveningSlots,
                      bookedSlots,
                      isDark,
                      textColor,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 16),

                    // Slot Category: Morning
                    _buildSlotSection(
                      'Morning Slots',
                      _morningSlots,
                      bookedSlots,
                      isDark,
                      textColor,
                      cardColor,
                      borderColor,
                    ),

                    const SizedBox(height: 24),

                    // SECTION: PAYMENT METHOD SELECTOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () => showPaymentMethodsSheet(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.emerald,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () => showPaymentMethodsSheet(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.payment_rounded,
                                color: AppColors.emerald,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPayment.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedPayment.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.emerald,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Booking Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryCardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Breakdown',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCostRow(
                            'Hourly Pitch Rate',
                            'PKR ${baseRate.toInt()}',
                            textColor: textColor,
                            subtextColor: subtextColor,
                          ),
                          const SizedBox(height: 6),
                          _buildCostRow(
                            'Lighting & Service Fee',
                            'PKR ${serviceFee.toInt()}',
                            textColor: textColor,
                            subtextColor: subtextColor,
                          ),
                          const SizedBox(height: 6),
                          _buildCostRow(
                            'App Welcome Voucher',
                            '- PKR ${platformDiscount.toInt()}',
                            isDiscount: true,
                            textColor: textColor,
                            subtextColor: subtextColor,
                          ),
                          Divider(height: 20, color: borderColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Total Payable',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
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

                    const SizedBox(height: 120),
                  ],
                ),
              ),

              // Sticky Bottom Payment Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(top: BorderSide(color: borderColor)),
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
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subtextColor,
                                ),
                              ),
                              Text(
                                'PKR ${totalPayable.toInt()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140,
                            maxWidth: 190,
                            minHeight: 48,
                            maxHeight: 50,
                          ),
                          child: ElevatedButton(
                            onPressed: _isBookingLoading
                                ? null
                                : () => _handleConfirmBooking(
                                    ground,
                                    selectedPayment,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: AppColors.emerald.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isBookingLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Confirm Booking',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
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

  Widget _buildHorizontalDatePicker(
    bool isDark,
    Color textColor,
    Color subtextColor,
  ) {
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected =
              day.day == _selectedDate.day &&
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
                color: isSelected
                    ? AppColors.emerald
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.emerald
                      : (isDark
                            ? const Color(0xFF334155)
                            : AppColors.borderLight),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.35),
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
                      color: isSelected ? Colors.white70 : subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : textColor,
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

  Widget _buildCourtPill(
    String courtName,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    final isSelected = _selectedCourt == courtName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCourt = courtName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? AppColors.emerald.withValues(alpha: 0.2)
                      : AppColors.emeraldContainer)
                : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.emerald
                  : (isDark ? const Color(0xFF334155) : AppColors.borderLight),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              courtName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.emeraldLight : AppColors.emeraldDark)
                    : textColor,
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
            color: isBorder ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotSection(
    String title,
    List<String> slots,
    Set<String> bookedSlots,
    bool isDark,
    Color textColor,
    Color cardColor,
    Color borderColor,
  ) {
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
            final isBooked =
                bookedSlots.contains(slot) || slot == '09:00 AM - 10:00 AM';

            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.emerald
                      : isBooked
                      ? (isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                            : const Color(0xFFF1F5F9))
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.emerald
                        : isBooked
                        ? (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0))
                        : borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isBooked
                            ? (isDark
                                  ? Colors.white24
                                  : AppColors.textMutedLight)
                            : textColor,
                        decoration: isBooked
                            ? TextDecoration.lineThrough
                            : null,
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

  Widget _buildCostRow(
    String title,
    String amount, {
    bool isDiscount = false,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDiscount ? AppColors.emeraldDark : subtextColor,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.emeraldDark : textColor,
          ),
        ),
      ],
    );
  }
}
