import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/storage/hive_boxes.dart';
import '../../features/booking/models/booking_model.dart';

/// Abstract contract for Bookings and Reservations
abstract class BookingRepository {
  Future<List<BookingModel>> getAllBookings();
  Future<List<BookingModel>> getBookingsForCustomer(String customerId);
  Future<List<BookingModel>> getBookingsForOwner(String ownerId);
  Future<List<BookingModel>> getBookingsForGroundAndDate(String groundId, String date);
  Future<bool> isSlotAvailable({
    required String groundId,
    required String date,
    required String timeSlot,
  });
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<void> cancelBooking(String bookingId);
}

/// Offline Hive-persisted Mock implementation for Mid-Term
class MockBookingRepository implements BookingRepository {
  @override
  Future<List<BookingModel>> getAllBookings() async {
    final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
    final List<BookingModel> list = [];

    for (final key in bookingsBox.keys) {
      final raw = bookingsBox.get(key);
      if (raw != null) {
        list.add(BookingModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String))));
      }
    }

    // Sort by createdAt descending (most recent first)
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
  Future<List<BookingModel>> getBookingsForGroundAndDate(String groundId, String date) async {
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
    final conflict = bookings.any((b) =>
      b.timeSlot == timeSlot &&
      (b.status == BookingStatus.pending || b.status == BookingStatus.confirmed)
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
      throw Exception('Double-booking prevented: This slot (${booking.timeSlot}) is already reserved.');
    }

    // 2. Persist to Hive
    final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
    await bookingsBox.put(booking.id, jsonEncode(booking.toJson()));
    return booking;
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
    final raw = bookingsBox.get(bookingId);
    if (raw == null) {
      throw Exception('Booking with ID $bookingId not found.');
    }

    final current = BookingModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
    final updated = current.copyWith(status: newStatus);
    await bookingsBox.put(bookingId, jsonEncode(updated.toJson()));
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }
}
