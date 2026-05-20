import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Define AuthState
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Global Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final authService = ref.watch(authServiceProvider);
    return AuthState(user: authService.currentUser);
  }

  Future<bool> loginWithEmail(String email, String password, UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await ref.read(authServiceProvider).loginWithEmail(
        email: email,
        password: password,
        expectedRole: role,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> loginWithBiometrics(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await ref.read(authServiceProvider).loginWithBiometrics(role);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await ref.read(authServiceProvider).signOut();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
