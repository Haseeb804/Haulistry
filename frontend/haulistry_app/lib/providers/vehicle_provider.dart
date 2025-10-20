import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/graphql_service.dart';
import '../services/auth_service.dart';

class VehicleProvider extends ChangeNotifier {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();
  
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  List<Vehicle> get availableVehicles => _vehicles.where((v) => v.isAvailable).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicles => _vehicles.isNotEmpty;

  String? get _providerUid => _authService.userProfile?['uid'];

  // Load vehicles from GraphQL API
  Future<void> loadVehicles() async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
      
      _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
    } catch (e) {
      _error = 'Failed to load vehicles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new vehicle via GraphQL
  Future<bool> addVehicle(Vehicle vehicle) async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      
      final response = await _graphqlService.addVehicle(
        providerUid: _providerUid!,
        name: vehicle.vehicleName,
        vehicleType: vehicle.vehicleType,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        registrationNumber: vehicle.registrationNumber,
        capacity: vehicle.capacity,
        condition: vehicle.condition,
        vehicleImage: vehicle.vehicleImage,
        hasInsurance: vehicle.hasInsurance,
        insuranceExpiry: vehicle.insuranceExpiry,
        isAvailable: vehicle.isAvailable,
        city: vehicle.city,
        province: vehicle.province,
        pricePerHour: vehicle.pricePerHour,
        pricePerDay: vehicle.pricePerDay,
        description: vehicle.description,
      );

      if (response['success'] == true) {
        // Reload vehicles to get updated list
        await loadVehicles();
        return true;
      }
      
      _error = response['message'] ?? 'Failed to add vehicle';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing vehicle via GraphQL
  Future<bool> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    try {
      
      final response = await _graphqlService.updateVehicle(
        vehicleId: vehicleId,
        name: updatedVehicle.vehicleName,
        vehicleType: updatedVehicle.vehicleType,
        make: updatedVehicle.make,
        model: updatedVehicle.model,
        year: updatedVehicle.year,
        registrationNumber: updatedVehicle.registrationNumber,
        capacity: updatedVehicle.capacity,
        condition: updatedVehicle.condition,
        vehicleImage: updatedVehicle.vehicleImage,
        hasInsurance: updatedVehicle.hasInsurance,
        insuranceExpiry: updatedVehicle.insuranceExpiry,
        isAvailable: updatedVehicle.isAvailable,
        city: updatedVehicle.city,
        province: updatedVehicle.province,
        pricePerHour: updatedVehicle.pricePerHour,
        pricePerDay: updatedVehicle.pricePerDay,
        description: updatedVehicle.description,
      );

      if (response['success'] == true) {
        await loadVehicles();
        return true;
      }
      
      _error = response['message'] ?? 'Failed to update vehicle';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete vehicle via GraphQL (CASCADE - deletes related services)
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      
      final response = await _graphqlService.deleteVehicle(vehicleId);

      if (response['success'] == true) {
        await loadVehicles();
        return true;
      }
      
      _error = response['message'] ?? 'Failed to delete vehicle';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle vehicle availability via GraphQL
  Future<bool> toggleAvailability(String vehicleId) async {
    try {
      final vehicle = getVehicleById(vehicleId);
      if (vehicle == null) return false;

      
      final response = await _graphqlService.updateVehicle(
        vehicleId: vehicleId,
        isAvailable: !vehicle.isAvailable,
      );

      if (response['success'] == true) {
        await loadVehicles();
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
  Vehicle? getVehicleById(String vehicleId) {
    try {
      return _vehicles.firstWhere((v) => v.vehicleId == vehicleId);
    } catch (e) {
      return null;
    }
  }

  // Get vehicles by type
  List<Vehicle> getVehiclesByType(String type) {
    return _vehicles.where((v) => v.vehicleType == type).toList();
  }

  // Clear all vehicles (for logout)
  void clearVehicles() {
    _vehicles.clear();
    _error = null;
    notifyListeners();
  }
}
