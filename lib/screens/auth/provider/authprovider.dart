import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/model/userModel.dart';
import 'package:rescueeats/screens/auth/provider/authstate.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    // 1. Validation Guard
    if (emailOrPhone.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please fill in all fields',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 2));

      // 2. MOCK ROLE LOGIC
      // We simulate the role based on the email text
      UserRole mockRole = UserRole.user; // Default

      if (emailOrPhone.toLowerCase().contains('rest')) {
        mockRole = UserRole.restaurant; // Set as Restaurant
      } else if (emailOrPhone.toLowerCase().contains('del')) {
        mockRole = UserRole.delivery; // Set as Delivery
      }

      final user = UserModel(
        id: '1',
        name: 'Test User',
        email: emailOrPhone,
        role: mockRole, // 3. PASS THE ROLE HERE
        createdAt: DateTime.now(),
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please fill in all fields',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = UserModel(
        id: '1',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: role, // Use the selected role from Sign Up
        createdAt: DateTime.now(),
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});
