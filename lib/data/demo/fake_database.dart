import 'package:flutter/foundation.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/customer/models/ground_model.dart';
import '../../features/booking/models/booking_model.dart';
import 'demo_data.dart';

/// In-memory FakeDatabase holding static Lists of users, grounds, and bookings
/// pre-loaded with requested demo accounts and demo grounds.
/// New signups, grounds, and bookings are added to these lists during the session.
class FakeDatabase {
  FakeDatabase._();
  static final FakeDatabase instance = FakeDatabase._();

  // Static Lists holding in-memory session records
  static final List<UserModel> users = [];
  static final List<GroundModel> grounds = [];
  static final List<BookingModel> bookings = [];

  // In-memory credential store: email -> { 'user': UserModel, 'password': String }
  final Map<String, Map<String, dynamic>> _userStore = {};
  bool _initialized = false;

  void init() {
    if (_initialized) return;

    // Reset lists
    users.clear();
    grounds.clear();
    bookings.clear();
    _userStore.clear();

    // 1. Mandatory demo accounts requested by the user:
    // customer@groundzero.sport and owner@groundzero.sport (password 123456)
    const customerSportDemo = UserModel(
      id: 'customer_sport_demo',
      name: 'Ali Raza',
      email: 'customer@groundzero.sport',
      phone: '+92 300 1234567',
      role: UserRole.customer,
    );
    addUser(user: customerSportDemo, password: '123456');

    const ownerSportDemo = UserModel(
      id: 'owner_sport_demo',
      name: 'Hamza Malik',
      email: 'owner@groundzero.sport',
      phone: '+92 333 5123456',
      role: UserRole.owner,
    );
    addUser(user: ownerSportDemo, password: '123456');

    // 2. Pre-load all demo users
    for (final demoUser in DemoData.users) {
      if (!_userStore.containsKey(demoUser.email.toLowerCase())) {
        addUser(user: demoUser, password: '123456');
      }
    }

    // 3. Pre-load demo grounds
    grounds.addAll(DemoData.grounds);

    // 4. Pre-load demo bookings
    bookings.addAll(DemoData.bookings);

    _initialized = true;
    debugPrint(
      '⚡ [FakeDatabase] Initialized with ${users.length} users, ${grounds.length} grounds, ${bookings.length} bookings',
    );
  }

  // ---------------------------------------------------------------------------
  // USER OPERATIONS
  // ---------------------------------------------------------------------------

  void addUser({required UserModel user, required String password}) {
    final key = user.email.trim().toLowerCase();
    _userStore[key] = {'user': user, 'password': password};
    final index = users.indexWhere((u) => u.email.toLowerCase() == key);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
  }

  UserModel? authenticate(String email, String password) {
    init();
    final key = email.trim().toLowerCase();
    final record = _userStore[key];
    if (record == null) return null;

    final storedPassword = record['password'] as String;
    if (storedPassword != password) {
      throw Exception('Incorrect password. Please verify and try again.');
    }

    return record['user'] as UserModel;
  }

  UserModel? findByEmail(String email) {
    init();
    final key = email.trim().toLowerCase();
    final record = _userStore[key];
    return record?['user'] as UserModel?;
  }

  List<UserModel> getAllUsers() {
    init();
    return List.unmodifiable(users);
  }

  // ---------------------------------------------------------------------------
  // GROUND OPERATIONS
  // ---------------------------------------------------------------------------

  List<GroundModel> getAllGrounds() {
    init();
    return List.unmodifiable(grounds);
  }

  GroundModel? getGroundById(String id) {
    init();
    try {
      return grounds.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<GroundModel> getGroundsByOwner(String ownerId) {
    init();
    return grounds.where((g) => g.ownerId == ownerId).toList();
  }

  void addGround(GroundModel ground) {
    init();
    grounds.insert(0, ground);
  }

  void updateGround(GroundModel updated) {
    init();
    final index = grounds.indexWhere((g) => g.id == updated.id);
    if (index >= 0) {
      grounds[index] = updated;
    } else {
      grounds.add(updated);
    }
  }

  void deleteGround(String id) {
    init();
    grounds.removeWhere((g) => g.id == id);
  }

  // ---------------------------------------------------------------------------
  // BOOKING OPERATIONS
  // ---------------------------------------------------------------------------

  List<BookingModel> getAllBookings() {
    init();
    return List.unmodifiable(bookings);
  }

  List<BookingModel> getBookingsForCustomer(String customerId) {
    init();
    return bookings.where((b) => b.customerId == customerId).toList();
  }

  List<BookingModel> getBookingsForOwner(String ownerId) {
    init();
    return bookings.where((b) => b.ownerId == ownerId).toList();
  }

  List<BookingModel> getBookingsForGroundAndDate(String groundId, String date) {
    init();
    return bookings
        .where((b) => b.groundId == groundId && b.date == date)
        .toList();
  }

  bool isSlotAvailable({
    required String groundId,
    required String date,
    required String timeSlot,
  }) {
    init();
    final existing = getBookingsForGroundAndDate(groundId, date);
    final conflict = existing.any(
      (b) =>
          b.timeSlot == timeSlot &&
          (b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed),
    );
    return !conflict;
  }

  BookingModel createBooking(BookingModel newBooking) {
    init();
    if (!isSlotAvailable(
      groundId: newBooking.groundId,
      date: newBooking.date,
      timeSlot: newBooking.timeSlot,
    )) {
      throw Exception(
        'Double-booking prevented: This slot (${newBooking.timeSlot}) is already reserved.',
      );
    }
    bookings.insert(0, newBooking);
    return newBooking;
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    init();
    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      bookings[index] = bookings[index].copyWith(status: newStatus);
    }
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  double getOwnerRevenue(String ownerId) {
    init();
    return bookings
        .where(
          (b) =>
              (ownerId.isEmpty || b.ownerId == ownerId) &&
              (b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.completed),
        )
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
  }

  void reset() {
    _initialized = false;
    init();
  }
}
