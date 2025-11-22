import 'package:equatable/equatable.dart';
import '../../models/seeker_preferences_model.dart';

abstract class SeekerPreferencesState extends Equatable {
  const SeekerPreferencesState();

  @override
  List<Object?> get props => [];
}

class SeekerPreferencesInitial extends SeekerPreferencesState {}

class SeekerPreferencesLoading extends SeekerPreferencesState {}

class SeekerPreferencesLoaded extends SeekerPreferencesState {
  final SeekerPreferences preferences;

  const SeekerPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  bool get hasPreferences => preferences.serviceCategories.isNotEmpty;
}

class SeekerPreferencesSaved extends SeekerPreferencesState {
  final SeekerPreferences preferences;

  const SeekerPreferencesSaved({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class SeekerPreferencesUpdated extends SeekerPreferencesState {
  final SeekerPreferences preferences;

  const SeekerPreferencesUpdated({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class SeekerPreferencesCleared extends SeekerPreferencesState {}

class SeekerPreferencesError extends SeekerPreferencesState {
  final String message;

  const SeekerPreferencesError({required this.message});

  @override
  List<Object?> get props => [message];
}
