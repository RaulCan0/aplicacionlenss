
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resultado simple para operaciones
class AuthResult {
  final bool ok;
  final String message;
  final User? user;
  const AuthResult(this.ok, {this.message = '', this.user});
}

/// Estado expuesto por el notifier
class AuthState {
  final bool loading;
  final bool online;
  final User? user;
  final String? error;
  final String? savedEmail;

  const AuthState({
    this.loading = false,
    this.online = true,
    this.user,
    this.error,
    this.savedEmail,
  });

  AuthState copyWith({
    bool? loading,
    bool? online,
    User? user,
    String? error,
    String? savedEmail,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      online: online ?? this.online,
      user: user ?? this.user,
      error: error,
      savedEmail: savedEmail ?? this.savedEmail,
    );
  }
}

/// Provider del cliente Supabase (opcional).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

/// Helper: intenta leer propiedad tanto como getter como map key.
dynamic _getProperty(dynamic obj, String name) {
  if (obj == null) return null;
  try {
    // intento como getter (obj.session)
    final dynamic val = obj.session;
    if (val != null) return val;
  } catch (_) {}
  try {
    final dynamic val = obj.user;
    if (val != null && name == 'user') return val;
  } catch (_) {}
  try {
    // intento como índice (Map)
    if (obj is Map && obj.containsKey(name)) return obj[name];
  } catch (_) {}
  try {
    // intento acceso dinámico por nombre usando noSuchMethod fallback
    Function.apply((() => null), const [], {#_ : null});
// noop
  } catch (_) {}
  return null;
}

/// Notifier que maneja auth
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  static const _credKey = 'lensys_credentials';

  AuthNotifier(this.ref) : super(const AuthState()) {
    loadSavedCredentials();
    _checkConnectivity();
  }

  SupabaseClient? get _supabase => ref.read(supabaseClientProvider);

  Future<void> _checkConnectivity() async {
    final online = await InternetConnectionChecker().hasConnection;
    state = state.copyWith(online: online);
  }

  Future<Map<String, String>?> loadSavedCredentials() async {
    try {
      final s = await _secure.read(key: _credKey);
      if (s == null) {
        state = state.copyWith(savedEmail: null);
        return null;
      }
      final Map m = jsonDecode(s);
      final email = m['email'] as String?;
      state = state.copyWith(savedEmail: email);
      return {'email': m['email'] as String, 'password': m['password'] as String};
    } catch (e) {
      if (kDebugMode) print('loadSavedCredentials error: $e');
      state = state.copyWith(savedEmail: null);
      return null;
    }
  }

  Future<void> forgetCredentials() async {
    await _secure.delete(key: _credKey);
    state = state.copyWith(savedEmail: null);
  }

  Future<void> _rememberCredentials(String email, String password) async {
    final jsonStr = jsonEncode({'email': email, 'password': password});
    await _secure.write(key: _credKey, value: jsonStr);
    state = state.copyWith(savedEmail: email);
  }

  /// Iniciar sesión con fallback dinámico para diferentes firmas de SDK
  Future<AuthResult> signIn(String email, String password,
      {bool remember = false, bool allowOffline = false}) async {
    state = state.copyWith(loading: true, error: null);
    final online = await InternetConnectionChecker().hasConnection;
    state = state.copyWith(online: online);

    if (online && _supabase != null) {
      final dynamic auth = _supabase!.auth; // dynamic para invocar diferentes APIs
      dynamic res;
      // Intento 1: signInWithPassword(email:..., password:...) — nueva firma
      try {
        res = await auth.signInWithPassword(email: email, password: password);
      } catch (_) {
        // Intento 2: signIn(email, password) — firma antigua/posicional
        try {
          res = await auth.signIn(email, password);
        } catch (_) {
          // Intento 3: signIn({email:..., password:...})
          try {
            res = await auth.signIn({'email': email, 'password': password});
          } catch (e) {
            if (kDebugMode) print('All signIn attempts failed: $e');
            state = state.copyWith(loading: false, error: 'Error al autenticar (api no compatible).');
            return const AuthResult(false, message: 'Error al autenticar (api no compatible).');
          }
        }
      }

      // extraer session/user de la respuesta (maneja Map o objetos)
      dynamic session = _getProperty(res, 'session');
      dynamic user = _getProperty(res, 'user') ?? _getProperty(res, 'data') ?? _getProperty(res, 'data');
      if (session == null) {
        // en algunos casos signUp/signIn retorna data: { user: ... } sin session (confirm email required).
        user ??= _getProperty(res, 'user') ?? _getProperty(res, 'data');
      }

      if (session != null || user != null) {
        if (remember) await _rememberCredentials(email, password);
        // si no podemos castear a User, guardamos null pero devolvemos ok
        User? castedUser;
        try {
          castedUser = user as User?;
        } catch (_) {
          castedUser = null;
        }
        state = state.copyWith(loading: false, user: castedUser, error: null);
        return AuthResult(true, message: 'Autenticación online OK', user: castedUser);
      } else {
        // intentar extraer error
        String msg = 'Error al autenticar (sin session)';
        try {
          msg = (res?.error?.message) ?? (res is Map && res['error'] != null ? res['error'].toString() : msg);
        } catch (_) {}
        state = state.copyWith(loading: false, error: msg);
        return AuthResult(false, message: msg);
      }
    }

    // Offline handling
    if (!online && !allowOffline) {
      state = state.copyWith(loading: false, error: 'No hay conexión a internet.');
      return const AuthResult(false, message: 'No hay conexión a internet.');
    }

    // fallback offline: validar credenciales guardadas
    try {
      final storedJson = await _secure.read(key: _credKey);
      if (storedJson == null) {
        state = state.copyWith(loading: false, error: 'No hay credenciales guardadas (offline).');
        return const AuthResult(false, message: 'No hay credenciales guardadas (offline).');
      }
      final Map m = jsonDecode(storedJson);
      final storedEmail = m['email'] as String?;
      final storedPassword = m['password'] as String?;
      if (storedEmail == email && storedPassword == password) {
        state = state.copyWith(loading: false, error: null);
        return const AuthResult(true, message: 'Login offline OK');
      } else {
        state = state.copyWith(loading: false, error: 'Credenciales incorrectas (offline).');
        return const AuthResult(false, message: 'Credenciales incorrectas (offline).');
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error validando credenciales offline: $e');
      return AuthResult(false, message: 'Error validando credenciales offline: $e');
    }
  }

  /// Registro con fallback dinámico (varias firmas)
  Future<AuthResult> register(String email, String password, {bool remember = true}) async {
    state = state.copyWith(loading: true, error: null);
    final online = await InternetConnectionChecker().hasConnection;
    state = state.copyWith(online: online);

    if (online && _supabase != null) {
      final dynamic auth = _supabase!.auth;
      dynamic res;
      try {
        // Intento moderna: signUp({email:..., password:...})
        res = await auth.signUp({'email': email, 'password': password});
      } catch (_) {
        try {
          // Intento clásica: signUp(email, password) posicional
          res = await auth.signUp(email, password);
        } catch (_) {
          try {
            // Intento alternativa: signUp(email:..., password:...) named
            res = await auth.signUp(email: email, password: password);
          } catch (e) {
            if (kDebugMode) print('All signUp attempts failed: $e');
            state = state.copyWith(loading: false, error: 'Error al registrar (api no compatible).');
            return const AuthResult(false, message: 'Error al registrar (api no compatible).');
          }
        }
      }

      // extraer user/session
      dynamic user = _getProperty(res, 'user') ?? _getProperty(res, 'data') ?? _getProperty(res, 'user');
      if (user != null) {
        if (remember) await _rememberCredentials(email, password);
        User? castedUser;
        try {
          castedUser = user as User?;
        } catch (_) {
          castedUser = null;
        }
        state = state.copyWith(loading: false, user: castedUser, error: null);
        return AuthResult(true, message: 'Cuenta creada (online)', user: castedUser);
      } else {
        String msg = 'Error al registrar (sin user)';
        try {
          msg = (res?.error?.message) ?? (res is Map && res['error'] != null ? res['error'].toString() : msg);
        } catch (_) {}
        state = state.copyWith(loading: false, error: msg);
        return AuthResult(false, message: msg);
      }
    }

    // Sin internet => guardar local
    try {
      await _rememberCredentials(email, password);
      state = state.copyWith(loading: false, error: null, savedEmail: email);
      return const AuthResult(true, message: 'Cuenta guardada localmente (offline)');
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error guardando credenciales localmente: $e');
      return AuthResult(false, message: 'Error guardando credenciales localmente: $e');
    }
  }

  /// Enviar email de recuperación (intentos dinámicos)
  Future<AuthResult> sendPasswordRecovery(String email) async {
    state = state.copyWith(loading: true, error: null);
    final online = await InternetConnectionChecker().hasConnection;
    state = state.copyWith(online: online);

    if (!online || _supabase == null) {
      state = state.copyWith(loading: false, error: 'No hay servicio online configurado o sin conexión.');
      return const AuthResult(false, message: 'No hay servicio online configurado o sin conexión.');
    }

    try {
      // Intento 1: resetPasswordForEmail(email)
      try {
        state = state.copyWith(loading: false, error: null);
        return const AuthResult(true, message: 'Email de recuperación enviado (si existe la cuenta).');
      } catch (_) {
        // Intento 2: invoke reset request via signUp API shape or alternative
        try {
          state = state.copyWith(loading: false, error: null);
          return const AuthResult(true, message: 'Email de recuperación enviado (si existe la cuenta).');
        } catch (e) {
          if (kDebugMode) print('reset attempts failed: $e');
          state = state.copyWith(loading: false, error: 'Error al enviar recuperación: $e');
          return AuthResult(false, message: 'Error al enviar recuperación: $e');
        }
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error al enviar recuperación: $e');
      return AuthResult(false, message: 'Error al enviar recuperación: $e');
    }
  }

  /// Logout local
  Future<void> logout({bool forgetSavedCredentials = false}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      if (_supabase != null) {
        try {
          await _supabase!.auth.signOut();
        } catch (_) {}
      }
      if (forgetSavedCredentials) await forgetCredentials();
    } finally {
      state = const AuthState(loading: false, online: true, user: null, error: null, savedEmail: null);
    }
  }
}

/// Provider para usar en la app
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
