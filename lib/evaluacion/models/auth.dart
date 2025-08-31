import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacionlensys/auth/auth_service.dart';

class AuthState {
  final bool loading;
  final String? error;
  final bool isLogged;
  AuthState({this.loading = false, this.error, this.isLogged = false});

  AuthState copyWith({bool? loading, String? error, bool? isLogged}) =>
      AuthState(
        loading: loading ?? this.loading,
        error: error,
        isLogged: isLogged ?? this.isLogged,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service = AuthService();
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    final res = await _service.login(email, password);
    state = state.copyWith(
      loading: false,
      isLogged: res['success'] == true,
      error: res['success'] == true ? null : res['message'],
    );
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    final res = await _service.register(email, password, state.isLogged as String);
    state = state.copyWith(
      loading: false,
      isLogged: res['success'] == true,
      error: res['success'] == true ? null : res['message'],
    );
  }

  Future<void> logout() async {
    await _service.signOut();
    state = AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);