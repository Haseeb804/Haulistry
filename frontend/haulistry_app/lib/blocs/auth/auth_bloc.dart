import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      final userRole = prefs.getString(AppConstants.keyUserRole) ?? '';

      if (isLoggedIn && userRole.isNotEmpty) {
        emit(AuthAuthenticated(userRole: userRole));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock login - replace with actual API call
      if (event.email.isNotEmpty && event.password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        
        // Check if user exists (during signup, their role was saved)
        String? savedRole = prefs.getString('${AppConstants.keyUserRole}_${event.email}');
        
        // If no saved role exists for this email, check email pattern as fallback
        if (savedRole == null) {
          savedRole = event.email.contains('provider') 
              ? AppConstants.roleProvider 
              : AppConstants.roleSeeker;
        }
        
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserToken, 'mock_token_123');
        await prefs.setString(AppConstants.keyUserId, 'user_123');
        await prefs.setString(AppConstants.keyUserRole, savedRole);

        emit(AuthAuthenticated(userRole: savedRole));
      } else {
        emit(const AuthError(message: 'Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock signup - replace with actual API call
      final prefs = await SharedPreferences.getInstance();
      
      // Save user role with email as key for future logins
      await prefs.setString('${AppConstants.keyUserRole}_${event.email}', event.role);
      
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserToken, 'mock_token_123');
      await prefs.setString(AppConstants.keyUserId, 'user_123');
      await prefs.setString(AppConstants.keyUserRole, event.role);

      emit(AuthAuthenticated(userRole: event.role));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      emit(AuthForgotPasswordSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthAuthenticated(
          userRole: currentState.userRole,
          currentUser: event.user,
        ));
        emit(AuthProfileUpdateSuccess(user: event.user));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
