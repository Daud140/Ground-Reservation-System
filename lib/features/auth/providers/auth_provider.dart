import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  bool get isCustomer => user?.isCustomer ?? false;
  bool get isOwner => user?.isOwner ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check for stored active session on startup
    Future.microtask(() => checkCurrentUser());
    return const AuthState();
  }

  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> quickDemoLogin(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.quickDemoLogin(role);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AuthState();
    } catch (_) {
      state = const AuthState();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
