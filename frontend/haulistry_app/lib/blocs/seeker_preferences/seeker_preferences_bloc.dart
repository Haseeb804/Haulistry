import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/seeker_preferences_model.dart';
import '../../services/auth_service.dart';
import 'seeker_preferences_event.dart';
import 'seeker_preferences_state.dart';

class SeekerPreferencesBloc extends Bloc<SeekerPreferencesEvent, SeekerPreferencesState> {
  final AuthService _authService;

  SeekerPreferencesBloc({required AuthService authService})
      : _authService = authService,
        super(SeekerPreferencesInitial()) {
    on<LoadPreferencesRequested>(_onLoadPreferencesRequested);
    on<SavePreferencesRequested>(_onSavePreferencesRequested);
    on<UpdatePreferencesRequested>(_onUpdatePreferencesRequested);
    on<ClearPreferencesRequested>(_onClearPreferencesRequested);
  }

  Future<void> _onLoadPreferencesRequested(
    LoadPreferencesRequested event,
    Emitter<SeekerPreferencesState> emit,
  ) async {
    emit(SeekerPreferencesLoading());

    try {
      // Load from AuthService userProfile (from backend)
      final userProfile = _authService.userProfile;

      if (userProfile != null) {
        // Check if backend has preferences
        if (userProfile['serviceCategories'] != null &&
            userProfile['serviceCategories'] is String &&
            (userProfile['serviceCategories'] as String).isNotEmpty &&
            userProfile['serviceCategories'] != '[]') {
          // Parse preferences from backend
          try {
            final serviceCategories = json.decode(userProfile['serviceCategories'] ?? '[]') as List;
            final categoryDetails = userProfile['categoryDetails'] != null
                ? json.decode(userProfile['categoryDetails']) as Map<String, dynamic>
                : <String, dynamic>{};
            final serviceRequirements = userProfile['serviceRequirements'] != null
                ? json.decode(userProfile['serviceRequirements']) as Map<String, dynamic>
                : <String, dynamic>{};

            // Convert to SeekerPreferences model
            final Map<String, List<String>> categoryDetailsMap = {};
            categoryDetails.forEach((key, value) {
              categoryDetailsMap[key] = (value as List).map((e) => e.toString()).toList();
            });

            final Map<String, ServiceRequirement> serviceRequirementsMap = {};
            serviceRequirements.forEach((key, value) {
              if (value is Map) {
                serviceRequirementsMap[key] = ServiceRequirement.fromJson(Map<String, dynamic>.from(value));
              }
            });

            final preferences = SeekerPreferences(
              id: event.userId,
              userId: event.userId,
              serviceCategories: serviceCategories.map((e) => e.toString()).toList(),
              categoryDetails: categoryDetailsMap,
              serviceRequirements: serviceRequirementsMap,
              primaryPurpose: userProfile['primaryPurpose'] ?? '',
              urgency: userProfile['urgency'] ?? '',
              notes: userProfile['preferencesNotes'] ?? '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            emit(SeekerPreferencesLoaded(preferences: preferences));
            return;
          } catch (parseError) {
            emit(SeekerPreferencesError(message: 'Failed to parse preferences: $parseError'));
            return;
          }
        }
      }

      // If we reach here, no preferences were loaded
      emit(SeekerPreferencesLoaded(preferences: SeekerPreferences.empty()));
    } catch (e) {
      emit(SeekerPreferencesError(message: e.toString()));
    }
  }

  Future<void> _onSavePreferencesRequested(
    SavePreferencesRequested event,
    Emitter<SeekerPreferencesState> emit,
  ) async {
    emit(SeekerPreferencesLoading());

    try {
      // Here you would typically save to backend/GraphQL
      // For now, we'll just emit the saved state
      
      emit(SeekerPreferencesSaved(preferences: event.preferences));
      emit(SeekerPreferencesLoaded(preferences: event.preferences));
    } catch (e) {
      emit(SeekerPreferencesError(message: 'Failed to save preferences: $e'));
    }
  }

  Future<void> _onUpdatePreferencesRequested(
    UpdatePreferencesRequested event,
    Emitter<SeekerPreferencesState> emit,
  ) async {
    emit(SeekerPreferencesLoading());

    try {
      // Here you would typically update backend/GraphQL
      // For now, we'll just emit the updated state
      
      emit(SeekerPreferencesUpdated(preferences: event.preferences));
      emit(SeekerPreferencesLoaded(preferences: event.preferences));
    } catch (e) {
      emit(SeekerPreferencesError(message: 'Failed to update preferences: $e'));
    }
  }

  Future<void> _onClearPreferencesRequested(
    ClearPreferencesRequested event,
    Emitter<SeekerPreferencesState> emit,
  ) async {
    emit(SeekerPreferencesLoading());

    try {
      // Here you would typically clear from backend/GraphQL
      
      emit(SeekerPreferencesCleared());
      emit(SeekerPreferencesLoaded(preferences: SeekerPreferences.empty()));
    } catch (e) {
      emit(SeekerPreferencesError(message: 'Failed to clear preferences: $e'));
    }
  }
}
