import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import 'demo_data.dart';

/// In-memory FakeDatabase pre-loaded with requested demo accounts
/// and supporting runtime registration during the session.
class FakeDatabase {
  FakeDatabase._();
  static final FakeDatabase instance = FakeDatabase._();

  // In-memory store: email -> { 'user': UserModel, 'password': String }
  final Map<String, Map<String, dynamic>> _userStore = {};
  bool _initialized = false;

  void init() {
    if (_initialized) return;

    // 1. Mandatory demo accounts requested by the user
    // customer@groundzero.sport and owner@groundzero.sport (password 123456)
    addUser(
      user: const UserModel(
        id: 'customer_sport_demo',
        name: 'Ali Raza',
        email: 'customer@groundzero.sport',
        phone: '+92 300 1234567',
        role: UserRole.customer,
      ),
      password: '123456',
    );

    addUser(
      user: const UserModel(
        id: 'owner_sport_demo',
        name: 'Hamza Malik',
        email: 'owner@groundzero.sport',
        phone: '+92 333 5123456',
        role: UserRole.owner,
      ),
      password: '123456',
    );

    // 2. Also register all existing demo users with password '123456' for seamless compatibility
    for (final demoUser in DemoData.users) {
      if (!_userStore.containsKey(demoUser.email.toLowerCase())) {
        addUser(user: demoUser, password: '123456');
      }
    }

    _initialized = true;
    debugPrint('⚡ [FakeDatabase] Initialized with ${_userStore.length} accounts');
  }

  void addUser({required UserModel user, required String password}) {
    final key = user.email.trim().toLowerCase();
    _userStore[key] = {
      'user': user,
      'password': password,
    };
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
    return _userStore.values.map((e) => e['user'] as UserModel).toList();
  }

  void reset() {
    _userStore.clear();
    _initialized = false;
    init();
  }
}
