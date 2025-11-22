import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeLoadRequested extends ThemeEvent {}

class ThemeToggleRequested extends ThemeEvent {}

class ThemeSetRequested extends ThemeEvent {
  final bool isDarkMode;

  const ThemeSetRequested({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}
