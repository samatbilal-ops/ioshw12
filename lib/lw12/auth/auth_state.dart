import 'package:equatable/equatable.dart';

/// Immutable states of the authentication state machine.
///
///   AuthInitial --login()--> AuthLoading --> AuthSuccess | AuthError
///
/// Equatable gives value equality (via [props]). That matters because
/// Bloc/Cubit calls `==` before emitting: two equal consecutive states are
/// ignored, and BlocBuilder/BlocConsumer rebuild only when the state changed.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String username;
  final String email;

  const AuthSuccess({required this.username, required this.email});

  @override
  List<Object?> get props => [username, email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
