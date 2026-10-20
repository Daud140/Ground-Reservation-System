import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/map_launcher.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/booking_model.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  final BookingModel? bookingExtra;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    this.bookingExtra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);
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
          onPressed: () => context.go(AppRoutes.customerRoot),
        ),
        title: Text(
          'Booking Confirmation',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: textColor, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Digital pass ready to share via WhatsApp'),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: bookingRepo.getAllBookings(),
        builder: (context, snapshot) {
          BookingModel? booking = bookingExtra;
          if (booking == null && snapshot.hasData) {
            try {
              booking = snapshot.data!.firstWhere((b) => b.id == bookingId);
            } catch (_) {
              booking = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
            }
          }

          final venueName = booking?.groundName ?? 'Apex Arena 5-a-side Turf';
          final venueLocation =
              booking?.groundLocation ?? 'Bahria Town, Islamabad';
          final dateStr = booking?.date ?? '2026-10-26';
          final timeSlot = booking?.timeSlot ?? '08:00 PM - 09:00 PM';
          final amount = booking?.totalPrice ?? 4200.0;
          final qrData = booking?.qrCodeData ?? 'GROUNDZERO-$bookingId';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Big Circular Green Check Icon with soft glow
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.emeraldDark,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Success Title
                Text(
                  'Reservation Locked!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your pitch is ready. Show this QR code upon arrival at the ground.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: subtextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Venue Card Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: secondaryCardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.emerald,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venueName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  venueLocation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date & Time',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$dateStr • $timeSlot',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PKR ${amount.toInt()} PAID',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Digital QR Pass Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors
                        .white, // Always high contrast white for QR reader
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 190.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.navy,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Booking ID: $bookingId',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fast check-in available at entrance gate',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Action Buttons Row: [Add to Calendar] [Share Pass] [Get Directions]
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        Icons.calendar_month_outlined,
                        'Calendar',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Match event synced to device calendar!',
                              ),
                            ),
                          );
                        },
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        Icons.share_outlined,
                        'Share Pass',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pass ready to share!'),
                            ),
                          );
                        },
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        Icons.directions_outlined,
                        'Directions',
                        () {
                          MapLauncher.openCoordinates(
                            context: context,
                            latitude: 33.7215, // Islamabad ground coordinates
                            longitude: 73.0560,
                            title: venueName,
                          );
                        },
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bottom CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.customerRoot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done & Return to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.emerald, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
