import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeLoaded({
    required this.isDarkMode,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object?> get props => [isDarkMode, lightTheme, darkTheme];

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
}
