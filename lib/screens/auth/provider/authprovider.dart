import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/model/userModel.dart';
import 'package:rescueeats/screens/auth/provider/authstate.dart';

import 'package:rescueeats/core/services/api_service.dart';
import 'package:rescueeats/core/services/google_auth_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final GoogleAuthService _googleAuthService;

  AuthNotifier(this._apiService, this._googleAuthService) : super(const AuthState());

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
      final user = await _apiService.login(emailOrPhone, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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
      final user = await _apiService.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final idToken = await _googleAuthService.signInWithGoogle();
      
      if (idToken == null) {
        // User cancelled
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      // Default to user role for login
      final user = await _apiService.googleAuth(idToken, UserRole.user);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> registerWithGoogle(UserRole role) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final idToken = await _googleAuthService.signInWithGoogle();
      
      if (idToken == null) {
        // User cancelled
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final user = await _apiService.googleAuth(idToken, role);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _googleAuthService.signOut();
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
  return AuthNotifier(ApiService(), GoogleAuthService());
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});
