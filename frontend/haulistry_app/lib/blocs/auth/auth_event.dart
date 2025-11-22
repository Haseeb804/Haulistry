import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;

  const AuthSignupRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, phone, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final UserModel user;

  const AuthUpdateProfileRequested({required this.user});

  @override
  List<Object?> get props => [user];
}
