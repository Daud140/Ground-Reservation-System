import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_storage_service.dart';
import '../../features/auth/models/user_model.dart';
import '../demo/demo_data.dart';

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

/// Offline Hive-persisted Mock implementation for Mid-Term
class MockAuthRepository implements AuthRepository {
  final LocalStorageService _storage = LocalStorageService.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _storage.getCurrentUser();
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async latency
    final usersBox = Hive.box(HiveBoxes.usersBox);

    for (final key in usersBox.keys) {
      final raw = usersBox.get(key);
      if (raw != null) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
        if (user.email.toLowerCase() == email.trim().toLowerCase()) {
          await _storage.saveCurrentUser(user);
          return user;
        }
      }
    }

    throw Exception('User not found with this email. Please check your credentials or use Demo Login.');
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
    final usersBox = Hive.box(HiveBoxes.usersBox);

    // Check if email already exists
    for (final key in usersBox.keys) {
      final raw = usersBox.get(key);
      if (raw != null) {
        final existing = UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
        if (existing.email.toLowerCase() == email.trim().toLowerCase()) {
          throw Exception('An account with this email already exists.');
        }
      }
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = UserModel(
      id: newId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: role,
    );

    await usersBox.put(newId, jsonEncode(newUser.toJson()));
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
    final user = role == UserRole.customer ? DemoData.users[2] : DemoData.users[0];
    await _storage.saveCurrentUser(user);
    return user;
  }
}
