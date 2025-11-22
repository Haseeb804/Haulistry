import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggleRequested>(_onThemeToggleRequested);
    on<ThemeSetRequested>(_onThemeSetRequested);
    
    // Auto-load theme on initialization
    add(ThemeLoadRequested());
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      
      emit(ThemeLoaded(
        isDarkMode: isDarkMode,
        lightTheme: _lightTheme,
        darkTheme: _darkTheme,
      ));
    } catch (e) {
      emit(ThemeLoaded(
        isDarkMode: false,
        lightTheme: _lightTheme,
        darkTheme: _darkTheme,
      ));
    }
  }

  Future<void> _onThemeToggleRequested(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      final newDarkMode = !currentState.isDarkMode;
      
      emit(ThemeLoaded(
        isDarkMode: newDarkMode,
        lightTheme: _lightTheme,
        darkTheme: _darkTheme,
      ));
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', newDarkMode);
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _onThemeSetRequested(
    ThemeSetRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      if (currentState.isDarkMode == event.isDarkMode) return;
      
      emit(ThemeLoaded(
        isDarkMode: event.isDarkMode,
        lightTheme: _lightTheme,
        darkTheme: _darkTheme,
      ));
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', event.isDarkMode);
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Light Theme
  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF3B82F6),
      surface: Colors.white,
      background: Colors.grey.shade50,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1F2937),
      onBackground: Color(0xFF1F2937),
    ),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Dark Theme
  ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
      surface: Color(0xFF1F2937),
      background: Color(0xFF111827),
      error: Color(0xFFF87171),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFF111827),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF1F2937),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
