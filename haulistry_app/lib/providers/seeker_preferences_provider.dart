import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/seeker_preferences_model.dart';

class SeekerPreferencesProvider with ChangeNotifier {
  SeekerPreferences _preferences = SeekerPreferences.empty();
  bool _isLoading = false;
  String? _errorMessage;

  SeekerPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Local storage key
  static const String _storageKey = 'seeker_preferences';

  // Load preferences from storage
  Future<void> loadPreferences(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? prefsJson = prefs.getString('${_storageKey}_$userId');

      if (prefsJson != null) {
        final Map<String, dynamic> prefsMap = json.decode(prefsJson);
        _preferences = SeekerPreferences.fromJson(prefsMap);
      } else {
        _preferences = SeekerPreferences.empty();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save or update preferences
  Future<bool> savePreferences({
    required String userId,
    required List<String> serviceCategories,
    required Map<String, List<String>> categoryDetails,
    required Map<String, ServiceRequirement> serviceRequirements,
    required String primaryPurpose,
    required String urgency,
    String notes = '',
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create or update preferences
      final newPreferences = SeekerPreferences(
        id: _preferences.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : _preferences.id,
        userId: userId,
        serviceCategories: serviceCategories,
        categoryDetails: categoryDetails,
        serviceRequirements: serviceRequirements,
        primaryPurpose: primaryPurpose,
        urgency: urgency,
        notes: notes,
        createdAt: _preferences.createdAt,
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_storageKey}_$userId',
        json.encode(newPreferences.toJson()),
      );

      _preferences = newPreferences;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
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

  // Clear preferences
  Future<void> clearPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_storageKey}_$userId');
      _preferences = SeekerPreferences.empty();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
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
}
