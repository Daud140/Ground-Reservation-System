import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/demo/demo_data.dart';
import '../../data/demo/fake_database.dart';
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
    try {
      await Hive.initFlutter();

      final boxNames = [
        HiveBoxes.usersBox,
        HiveBoxes.groundsBox,
        HiveBoxes.bookingsBox,
        HiveBoxes.reviewsBox,
        HiveBoxes.settingsBox,
        HiveBoxes.favoritesBox,
      ];

      for (final boxName in boxNames) {
        if (!Hive.isBoxOpen(boxName)) {
          await Hive.openBox(boxName);
        }
      }

      // Initialize in-memory fake database
      FakeDatabase.instance.init();

      // Check if initial demo data needs seeding
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      final isSeeded = settingsBox.get(_keySeeded, defaultValue: false) as bool;
      final usersBox = Hive.box(HiveBoxes.usersBox);
      final hasSportDemo = usersBox.containsKey('customer_sport_demo');
      if (!isSeeded || !hasSportDemo) {
        await seedDemoData();
      }

      printAllStoredUsers();
    } catch (e) {
      // Graceful fallback: do not crash main() if Hive storage has file lock contention
    }
  }

  /// Print all users currently stored in the Hive database to the debug console
  void printAllStoredUsers() {
    try {
      if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
        final usersBox = Hive.box(HiveBoxes.usersBox);
        debugPrint(
          '📦 =================== HIVE DATABASE: USERS ===================',
        );
        debugPrint(
          '📦 Total Users in "${HiveBoxes.usersBox}": ${usersBox.length}',
        );
        for (final key in usersBox.keys) {
          debugPrint('  🔑 Key: $key => ${usersBox.get(key)}');
        }
        debugPrint(
          '📦 =============================================================',
        );
      }
    } catch (e) {
      debugPrint('Error printing Hive users: $e');
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

    // 1. Seed Users (password: 123456 as requested for demo accounts)
    for (final user in DemoData.users) {
      final userMap = user.toJson();
      userMap['password'] = '123456';
      await usersBox.put(user.id, jsonEncode(userMap));
      FakeDatabase.instance.addUser(user: user, password: '123456');
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
    FakeDatabase.instance.reset();
    await seedDemoData();
  }

  // ---------------------------------------------------------------------------
  // AUTH SESSION MANAGEMENT
  // ---------------------------------------------------------------------------
  static const String _keyRememberMe = 'remember_me_preference';

  bool get isRememberMe {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      return settingsBox.get(_keyRememberMe, defaultValue: true) as bool;
    } catch (_) {
      return true;
    }
  }

  Future<void> setRememberMe(bool value) async {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      await settingsBox.put(_keyRememberMe, value);
    } catch (_) {}
  }

  UserModel? getCurrentUser() {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      final raw = settingsBox.get(_keyCurrentUser);
      if (raw == null) return null;
      return UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw as String)),
      );
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
    try {
      final box = Hive.box(HiveBoxes.favoritesBox);
      return box.keys.map((k) => k.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  bool isFavorite(String groundId) {
    try {
      final box = Hive.box(HiveBoxes.favoritesBox);
      return box.containsKey(groundId);
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleFavorite(String groundId) async {
    try {
      final box = Hive.box(HiveBoxes.favoritesBox);
      if (box.containsKey(groundId)) {
        await box.delete(groundId);
      } else {
        await box.put(groundId, true);
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS PERSISTENCE
  // ---------------------------------------------------------------------------
  static const String _keyNotifications = 'user_notifications_v1';

  List<Map<String, dynamic>> getRawNotifications() {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      final raw = settingsBox.get(_keyNotifications);
      if (raw == null) return [];
      final List<dynamic> list = jsonDecode(raw as String);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRawNotifications(List<Map<String, dynamic>> list) async {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      await settingsBox.put(_keyNotifications, jsonEncode(list));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // PAYMENT METHODS PERSISTENCE
  // ---------------------------------------------------------------------------
  static const String _keyPaymentMethods = 'user_payment_methods_v1';
  static const String _keySelectedPaymentId = 'selected_payment_method_id';

  List<Map<String, dynamic>> getRawPaymentMethods() {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      final raw = settingsBox.get(_keyPaymentMethods);
      if (raw == null) return [];
      final List<dynamic> list = jsonDecode(raw as String);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRawPaymentMethods(List<Map<String, dynamic>> list) async {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      await settingsBox.put(_keyPaymentMethods, jsonEncode(list));
    } catch (_) {}
  }

  String? getSelectedPaymentMethodId() {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      return settingsBox.get(_keySelectedPaymentId) as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setSelectedPaymentMethodId(String id) async {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      await settingsBox.put(_keySelectedPaymentId, id);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // THEME MODE PERSISTENCE
  // ---------------------------------------------------------------------------
  static const String _keyDarkMode = 'isDarkMode';

  bool get isDarkMode {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      return settingsBox.get(_keyDarkMode, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    try {
      final settingsBox = Hive.box(HiveBoxes.settingsBox);
      await settingsBox.put(_keyDarkMode, isDark);
    } catch (_) {}
  }
}
