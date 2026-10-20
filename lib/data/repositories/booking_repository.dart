import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import '../../features/booking/models/booking_model.dart';
import '../demo/fake_database.dart';

/// Abstract contract for Bookings and Reservations
abstract class BookingRepository {
  Future<List<BookingModel>> getAllBookings();
  Future<List<BookingModel>> getBookingsForCustomer(String customerId);
  Future<List<BookingModel>> getBookingsForOwner(String ownerId);
  Future<List<BookingModel>> getBookingsForGroundAndDate(
    String groundId,
    String date,
  );
  Future<bool> isSlotAvailable({
    required String groundId,
    required String date,
    required String timeSlot,
  });
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<void> cancelBooking(String bookingId);
  Future<double> getOwnerRevenue(String ownerId);
}

/// In-memory FakeDatabase backed with Hive persistence sync
class MockBookingRepository implements BookingRepository {
  @override
  Future<List<BookingModel>> getAllBookings() async {
    // 1. Try Hive if available
    try {
      if (Hive.isBoxOpen(HiveBoxes.bookingsBox)) {
        final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
        if (bookingsBox.isNotEmpty) {
          final List<BookingModel> list = [];
          for (final key in bookingsBox.keys) {
            final raw = bookingsBox.get(key);
            if (raw != null) {
              list.add(
                BookingModel.fromJson(
                  Map<String, dynamic>.from(jsonDecode(raw as String)),
                ),
              );
            }
          }
          if (list.isNotEmpty) {
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to FakeDatabase
    final list = FakeDatabase.instance.getAllBookings().toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<BookingModel>> getBookingsForCustomer(String customerId) async {
    final all = await getAllBookings();
    return all.where((b) => b.customerId == customerId).toList();
  }

  @override
  Future<List<BookingModel>> getBookingsForOwner(String ownerId) async {
    final all = await getAllBookings();
    return all.where((b) => b.ownerId == ownerId).toList();
  }

  @override
  Future<List<BookingModel>> getBookingsForGroundAndDate(
    String groundId,
    String date,
  ) async {
    final all = await getAllBookings();
    return all.where((b) => b.groundId == groundId && b.date == date).toList();
  }

  @override
  Future<bool> isSlotAvailable({
    required String groundId,
    required String date,
    required String timeSlot,
  }) async {
    final bookings = await getBookingsForGroundAndDate(groundId, date);
    // Any active booking (pending or confirmed) blocks the slot
    final conflict = bookings.any(
      (b) =>
          b.timeSlot == timeSlot &&
          (b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed),
    );
    return !conflict;
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    // 1. Strict Double Booking Validation Check
    final available = await isSlotAvailable(
      groundId: booking.groundId,
      date: booking.date,
      timeSlot: booking.timeSlot,
    );

    if (!available) {
      throw Exception(
        'Double-booking prevented: This slot (${booking.timeSlot}) is already reserved.',
      );
    }

    // 2. Persist in FakeDatabase
    FakeDatabase.instance.createBooking(booking);

    // 3. Persist to Hive if open
    try {
      if (Hive.isBoxOpen(HiveBoxes.bookingsBox)) {
        final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
        await bookingsBox.put(booking.id, jsonEncode(booking.toJson()));
      }
    } catch (_) {}

    return booking;
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    FakeDatabase.instance.updateBookingStatus(bookingId, newStatus);
    try {
      if (Hive.isBoxOpen(HiveBoxes.bookingsBox)) {
        final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
        final raw = bookingsBox.get(bookingId);
        if (raw != null) {
          final current = BookingModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw as String)),
          );
          final updated = current.copyWith(status: newStatus);
          await bookingsBox.put(bookingId, jsonEncode(updated.toJson()));
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  @override
  Future<double> getOwnerRevenue(String ownerId) async {
    final all = await getAllBookings();
    // Rule: When a booking is confirmed, increase owner's revenue by the booking amount.
    // Revenue must not increase for unconfirmed or cancelled bookings.
    // Cancelled bookings reduce it if they were already confirmed.
    return all
        .where(
          (b) =>
              (ownerId.isEmpty || b.ownerId == ownerId) &&
              (b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.completed),
        )
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
  }
}
