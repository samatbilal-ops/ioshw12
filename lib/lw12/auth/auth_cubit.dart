import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

/// Asynchronous authentication state machine (Cubit = methods + emit, no events).
class AuthCubit extends Cubit<AuthState> {
  /// Demo credentials required by the lab.
  static const String demoEmail = 'student@narxoz.kz';
  static const String demoPassword = '123456';

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final Duration _delay;

  /// [delay] simulates the network round trip; tests pass Duration.zero.
  AuthCubit({Duration delay = const Duration(seconds: 2)})
      : _delay = delay,
        super(const AuthInitial());

  Future<void> login(String email, String password) async {
    if (state is AuthLoading) return; // ignore double taps

    emit(const AuthLoading());
    await Future<void>.delayed(_delay); // simulated server call
    if (isClosed) return; // screen was destroyed while we were waiting

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || password.isEmpty) {
      emit(const AuthError('Email and password are required'));
    } else if (!_emailPattern.hasMatch(cleanEmail)) {
      emit(const AuthError('Enter a valid email address'));
    } else if (cleanEmail == demoEmail && password == demoPassword) {
      emit(AuthSuccess(
        username: _usernameFrom(cleanEmail),
        email: cleanEmail,
      ));
    } else {
      emit(const AuthError('Invalid email or password'));
    }
  }

  /// Back to the very first state.
  void logout() => emit(const AuthInitial());

  /// student@narxoz.kz -> Student
  static String _usernameFrom(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}
