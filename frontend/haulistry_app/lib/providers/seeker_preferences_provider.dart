import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/seeker_preferences_model.dart';
import '../services/auth_service.dart';

class SeekerPreferencesProvider with ChangeNotifier {
  SeekerPreferences _preferences = SeekerPreferences.empty();
  bool _isLoading = false;
  String? _errorMessage;

  SeekerPreferencesProvider();

  SeekerPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load preferences directly from AuthService userProfile (from backend/Neo4j)
  Future<void> loadPreferences(String userId, {AuthService? authService}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();


      // Load from AuthService userProfile (from backend)
      final userProfile = authService?.userProfile;
      
      
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
            
            _preferences = SeekerPreferences(
              id: userId,
              userId: userId,
              serviceCategories: serviceCategories.map((e) => e.toString()).toList(),
              categoryDetails: categoryDetailsMap,
              serviceRequirements: serviceRequirementsMap,
              primaryPurpose: userProfile['primaryPurpose'] ?? '',
              urgency: userProfile['urgency'] ?? '',
              notes: userProfile['preferencesNotes'] ?? '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            
            _isLoading = false;
            notifyListeners();
            return;
          } catch (parseError) {
            _errorMessage = 'Failed to parse preferences: $parseError';
          }
        } else {
        }
      } else {
      }

      // If we reach here, no preferences were loaded
      _preferences = SeekerPreferences.empty();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _preferences = SeekerPreferences.empty();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if preferences are set
  bool hasPreferences() {
    return _preferences.id.isNotEmpty && _preferences.serviceCategories.isNotEmpty;
  }

  // Get selected categories
  List<String> getSelectedCategories() {
    return _preferences.serviceCategories;
  }

  // Get subcategories for a category
  List<String> getSelectedSubcategories(String category) {
    return _preferences.categoryDetails[category] ?? [];
  }

  // Get recommended services based on preferences
  List<String> getRecommendedServices() {
    final List<String> recommended = [];
    for (final category in _preferences.serviceCategories) {
      final subcategories = _preferences.categoryDetails[category] ?? [];
      recommended.addAll(subcategories);
    }
    return recommended;
  }

  // Get requirement for a specific category
  ServiceRequirement? getRequirement(String category) {
    return _preferences.serviceRequirements[category];
  }

  // Get urgency level
  String getUrgency() {
    return _preferences.urgency;
  }

  /// Clear preferences from both frontend state and backend (Neo4j)
  Future<void> clearPreferences(String userId, {required AuthService authService}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();


      // Call GraphQL service to clear preferences in Neo4j
      final graphqlService = authService.graphqlService;
      
      final result = await graphqlService.clearSeekerPreferences(uid: userId);
      
      if (result['success'] == true) {
        
        // Update AuthService userProfile with cleared data
        if (result['user'] != null) {
          authService.updateUserProfile(result['user']);
        }
        
        // Clear frontend state
        _preferences = SeekerPreferences.empty();
        
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Failed to clear preferences');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
