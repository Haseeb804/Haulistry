import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userRole;
  final UserModel? currentUser;

  const AuthAuthenticated({
    required this.userRole,
    this.currentUser,
  });

  @override
  List<Object?> get props => [userRole, currentUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordSuccess extends AuthState {}

class AuthProfileUpdateSuccess extends AuthState {
  final UserModel user;

  const AuthProfileUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}
