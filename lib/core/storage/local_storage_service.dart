import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/demo/demo_data.dart';
import '../../features/auth/models/user_model.dart';
import 'hive_boxes.dart';

/// Central local storage service using Hive
/// Handles local persistence, database seeding, and demo data reset.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _keySeeded = 'is_seeded_v1';
  static const String _keyCurrentUser = 'current_session_user';

  /// Initialize Hive and open all necessary boxes
  Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox(HiveBoxes.usersBox),
      Hive.openBox(HiveBoxes.groundsBox),
      Hive.openBox(HiveBoxes.bookingsBox),
      Hive.openBox(HiveBoxes.reviewsBox),
      Hive.openBox(HiveBoxes.settingsBox),
      Hive.openBox(HiveBoxes.favoritesBox),
    ]);

    // Check if initial demo data needs seeding
    final settingsBox = Hive.box(HiveBoxes.settingsBox);
    final isSeeded = settingsBox.get(_keySeeded, defaultValue: false) as bool;
    if (!isSeeded) {
      await seedDemoData();
    }
  }

  /// Populate Hive boxes with initial demo records
  Future<void> seedDemoData() async {
    final usersBox = Hive.box(HiveBoxes.usersBox);
    final groundsBox = Hive.box(HiveBoxes.groundsBox);
    final bookingsBox = Hive.box(HiveBoxes.bookingsBox);
    final reviewsBox = Hive.box(HiveBoxes.reviewsBox);
    final settingsBox = Hive.box(HiveBoxes.settingsBox);

    await usersBox.clear();
    await groundsBox.clear();
    await bookingsBox.clear();
    await reviewsBox.clear();

    // 1. Seed Users
    for (final user in DemoData.users) {
      await usersBox.put(user.id, jsonEncode(user.toJson()));
    }

    // 2. Seed Grounds
    for (final ground in DemoData.grounds) {
      await groundsBox.put(ground.id, jsonEncode(ground.toJson()));
    }

    // 3. Seed Bookings
    for (final booking in DemoData.bookings) {
      await bookingsBox.put(booking.id, jsonEncode(booking.toJson()));
    }

    // 4. Seed Reviews
    for (final review in DemoData.reviews) {
      await reviewsBox.put(review.id, jsonEncode(review.toJson()));
    }

    // Mark as seeded
    await settingsBox.put(_keySeeded, true);
  }

  /// Reset all local records to initial pristine demo state
  Future<void> resetDemoData() async {
    final favoritesBox = Hive.box(HiveBoxes.favoritesBox);
    await favoritesBox.clear();
    await seedDemoData();
  }

  // ---------------------------------------------------------------------------
  // AUTH SESSION MANAGEMENT
  // ---------------------------------------------------------------------------
  UserModel? getCurrentUser() {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      final raw = settingsBox.get(_keyCurrentUser);
      if (raw == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentUser(UserModel user) async {
    final settingsBox = Hive.box(HiveBoxes.settingsBox);
    await settingsBox.put(_keyCurrentUser, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    final settingsBox = Hive.box(HiveBoxes.settingsBox);
    await settingsBox.delete(_keyCurrentUser);
  }

  // ---------------------------------------------------------------------------
  // FAVORITES MANAGEMENT
  // ---------------------------------------------------------------------------
  List<String> getFavoriteGroundIds() {
    final box = Hive.box(HiveBoxes.favoritesBox);
    return box.keys.map((k) => k.toString()).toList();
  }

  bool isFavorite(String groundId) {
    final box = Hive.box(HiveBoxes.favoritesBox);
    return box.containsKey(groundId);
  }

  Future<void> toggleFavorite(String groundId) async {
    final box = Hive.box(HiveBoxes.favoritesBox);
    if (box.containsKey(groundId)) {
      await box.delete(groundId);
    } else {
      await box.put(groundId, true);
    }
  }
}
