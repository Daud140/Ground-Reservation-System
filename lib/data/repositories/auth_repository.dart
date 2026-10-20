import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_storage_service.dart';
import '../../features/auth/models/user_model.dart';
import '../demo/demo_data.dart';

import '../demo/fake_database.dart';

/// Abstract contract for Authentication operations
abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });
  Future<void> signOut();
  Future<UserModel> quickDemoLogin(UserRole role);
}

/// Offline Hive-persisted and FakeDatabase-backed implementation
class MockAuthRepository implements AuthRepository {
  final LocalStorageService _storage = LocalStorageService.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _storage.getCurrentUser();
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate async latency
    final cleanEmail = email.trim().toLowerCase();

    // 1. Check in-memory FakeDatabase first (covers customer@groundzero.sport & owner@groundzero.sport)
    try {
      final fakeUser = FakeDatabase.instance.authenticate(cleanEmail, password);
      if (fakeUser != null) {
        await _storage.saveCurrentUser(fakeUser);
        return fakeUser;
      }
    } catch (e) {
      // If password incorrect, propagate error
      rethrow;
    }

    // 2. Check persistent Hive database
    if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
      final usersBox = Hive.box(HiveBoxes.usersBox);
      for (final key in usersBox.keys) {
        final raw = usersBox.get(key);
        if (raw != null) {
          final map = Map<String, dynamic>.from(jsonDecode(raw as String));
          final user = UserModel.fromJson(map);
          if (user.email.toLowerCase() == cleanEmail) {
            final savedPassword = map['password'] as String?;
            if (savedPassword != null && savedPassword != password) {
              throw Exception(
                'Incorrect password. Please verify and try again.',
              );
            }
            await _storage.saveCurrentUser(user);
            return user;
          }
        }
      }
    }

    throw Exception(
      'No account found with this email ($email). Please register first.',
    );
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final cleanEmail = email.trim().toLowerCase();

    // Prevent duplicate accounts: check FakeDatabase & Hive
    if (FakeDatabase.instance.findByEmail(cleanEmail) != null) {
      throw Exception(
        'An account with this email already exists. Please sign in instead.',
      );
    }

    if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
      final usersBox = Hive.box(HiveBoxes.usersBox);
      for (final key in usersBox.keys) {
        final raw = usersBox.get(key);
        if (raw != null) {
          final existing = UserModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw as String)),
          );
          if (existing.email.toLowerCase() == cleanEmail) {
            throw Exception(
              'An account with this email already exists. Please sign in instead.',
            );
          }
        }
      }
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = UserModel(
      id: newId,
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: role,
    );

    // Save account in in-memory FakeDatabase
    FakeDatabase.instance.addUser(user: newUser, password: password);

    // Save account in Hive database
    if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
      final usersBox = Hive.box(HiveBoxes.usersBox);
      final userMap = newUser.toJson();
      userMap['password'] = password;
      await usersBox.put(newId, jsonEncode(userMap));
      debugPrint(
        '📦 [HIVE DATABASE] SAVED NEW ACCOUNT: $newId ($cleanEmail, role: ${role.name})',
      );
    }

    await _storage.saveCurrentUser(newUser);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    await _storage.clearSession();
  }

  @override
  Future<UserModel> quickDemoLogin(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final targetEmail = role == UserRole.customer
        ? 'customer@groundzero.sport'
        : 'owner@groundzero.sport';

    final user =
        FakeDatabase.instance.findByEmail(targetEmail) ??
        (role == UserRole.customer ? DemoData.users[0] : DemoData.users[1]);

    await _storage.saveCurrentUser(user);
    return user;
  }
}
