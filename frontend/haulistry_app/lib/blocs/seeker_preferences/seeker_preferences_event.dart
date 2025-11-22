import 'package:equatable/equatable.dart';
import '../../models/seeker_preferences_model.dart';

abstract class SeekerPreferencesEvent extends Equatable {
  const SeekerPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPreferencesRequested extends SeekerPreferencesEvent {
  final String userId;

  const LoadPreferencesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SavePreferencesRequested extends SeekerPreferencesEvent {
  final String userId;
  final SeekerPreferences preferences;

  const SavePreferencesRequested({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, preferences];
}

class UpdatePreferencesRequested extends SeekerPreferencesEvent {
  final String userId;
  final SeekerPreferences preferences;

  const UpdatePreferencesRequested({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, preferences];
}

class ClearPreferencesRequested extends SeekerPreferencesEvent {
  final String userId;

  const ClearPreferencesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
