import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  List<Vehicle> get availableVehicles => _vehicles.where((v) => v.isAvailable).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicles => _vehicles.isNotEmpty;

  // Initialize and load vehicles from storage
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? vehiclesJson = prefs.getString('provider_vehicles');
      
      if (vehiclesJson != null) {
        final List<dynamic> decoded = json.decode(vehiclesJson);
        _vehicles = decoded.map((v) => Vehicle.fromJson(v)).toList();
      }
    } catch (e) {
      _error = 'Failed to load vehicles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save vehicles to storage
  Future<void> _saveVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_vehicles.map((v) => v.toJson()).toList());
      await prefs.setString('provider_vehicles', encoded);
    } catch (e) {
      _error = 'Failed to save vehicles: $e';
      notifyListeners();
    }
  }

  // Add new vehicle
  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      _vehicles.add(vehicle);
      await _saveVehicles();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing vehicle
  Future<bool> updateVehicle(String id, Vehicle updatedVehicle) async {
    try {
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle.copyWith(updatedAt: DateTime.now());
        await _saveVehicles();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String id) async {
    try {
      _vehicles.removeWhere((v) => v.id == id);
      await _saveVehicles();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle vehicle availability
  Future<bool> toggleAvailability(String id) async {
    try {
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = _vehicles[index].copyWith(
          isAvailable: !_vehicles[index].isAvailable,
          updatedAt: DateTime.now(),
        );
        await _saveVehicles();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to toggle availability: $e';
      notifyListeners();
      return false;
    }
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get vehicles by type
  List<Vehicle> getVehiclesByType(String type) {
    return _vehicles.where((v) => v.vehicleType == type).toList();
  }

  // Clear all vehicles (for testing/logout)
  Future<void> clearVehicles() async {
    _vehicles.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('provider_vehicles');
    notifyListeners();
  }

  // Generate unique ID
  String _generateId() {
    return 'VEH${DateTime.now().millisecondsSinceEpoch}';
  }
}
