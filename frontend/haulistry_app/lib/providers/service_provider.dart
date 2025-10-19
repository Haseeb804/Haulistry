import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/graphql_service.dart';
import '../services/auth_service.dart';

class ServiceProvider extends ChangeNotifier {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();
  
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  List<Service> get activeServices => _services.where((s) => s.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasServices => _services.isNotEmpty;

  String? get _providerUid => _authService.userProfile?['uid'];

  // Load all services for provider from GraphQL API
  Future<void> loadServices() async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Loading services for provider: $_providerUid');
      final servicesData = await _graphqlService.getProviderServices(_providerUid!);
      
      _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
      print('✅ Loaded ${_services.length} services');
    } catch (e) {
      _error = 'Failed to load services: $e';
      print('❌ Error loading services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load services for a specific vehicle
  Future<List<Service>> loadVehicleServices(String vehicleId) async {
    try {
      print('🔄 Loading services for vehicle: $vehicleId');
      final servicesData = await _graphqlService.getVehicleServices(vehicleId);
      
      final vehicleServices = servicesData.map((data) => Service.fromGraphQL(data)).toList();
      print('✅ Loaded ${vehicleServices.length} services for vehicle');
      return vehicleServices;
    } catch (e) {
      print('❌ Error loading vehicle services: $e');
      return [];
    }
  }

  // Add new service via GraphQL
  Future<bool> addService(Service service) async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      print('🛠️  Adding service: ${service.serviceName}');
      
      final response = await _graphqlService.addService(
        vehicleId: service.vehicleId,
        providerUid: _providerUid!,
        serviceName: service.serviceName,
        serviceCategory: service.serviceCategory,
        pricePerHour: service.pricePerHour,
        pricePerDay: service.pricePerDay,
        pricePerService: service.pricePerService,
        description: service.description,
        serviceArea: service.serviceArea,
        minBookingDuration: service.minBookingDuration,
        isActive: service.isActive,
        availableDays: service.availableDays,
        availableHours: service.availableHours,
        operatorIncluded: service.operatorIncluded,
        fuelIncluded: service.fuelIncluded,
        transportationIncluded: service.transportationIncluded,
      );

      if (response['success'] == true) {
        // Reload services to get updated list
        await loadServices();
        print('✅ Service added successfully');
        return true;
      }
      
      _error = response['message'] ?? 'Failed to add service';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add service: $e';
      print('❌ Error adding service: $e');
      notifyListeners();
      return false;
    }
  }

  // Update existing service via GraphQL
  Future<bool> updateService(String serviceId, Service updatedService) async {
    try {
      print('🔧 Updating service: $serviceId');
      
      final response = await _graphqlService.updateService(
        serviceId: serviceId,
        serviceName: updatedService.serviceName,
        serviceCategory: updatedService.serviceCategory,
        pricePerHour: updatedService.pricePerHour,
        pricePerDay: updatedService.pricePerDay,
        pricePerService: updatedService.pricePerService,
        description: updatedService.description,
        serviceArea: updatedService.serviceArea,
        minBookingDuration: updatedService.minBookingDuration,
        isActive: updatedService.isActive,
        availableDays: updatedService.availableDays,
        availableHours: updatedService.availableHours,
        operatorIncluded: updatedService.operatorIncluded,
        fuelIncluded: updatedService.fuelIncluded,
        transportationIncluded: updatedService.transportationIncluded,
      );

      if (response['success'] == true) {
        await loadServices();
        print('✅ Service updated successfully');
        return true;
      }
      
      _error = response['message'] ?? 'Failed to update service';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update service: $e';
      print('❌ Error updating service: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete service via GraphQL
  Future<bool> deleteService(String serviceId) async {
    try {
      print('🗑️  Deleting service: $serviceId');
      
      final response = await _graphqlService.deleteService(serviceId);

      if (response['success'] == true) {
        await loadServices();
        print('✅ Service deleted successfully');
        return true;
      }
      
      _error = response['message'] ?? 'Failed to delete service';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete service: $e';
      print('❌ Error deleting service: $e');
      notifyListeners();
      return false;
    }
  }

  // Toggle service status via GraphQL
  Future<bool> toggleServiceStatus(String serviceId) async {
    try {
      final service = getServiceById(serviceId);
      if (service == null) return false;

      print('🔄 Toggling service status: $serviceId');
      
      final response = await _graphqlService.updateService(
        serviceId: serviceId,
        isActive: !service.isActive,
      );

      if (response['success'] == true) {
        await loadServices();
        print('✅ Service status toggled successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      _error = 'Failed to toggle service status: $e';
      print('❌ Error toggling service status: $e');
      notifyListeners();
      return false;
    }
  }

  // Get service by ID
  Service? getServiceById(String serviceId) {
    try {
      return _services.firstWhere((s) => s.serviceId == serviceId);
    } catch (e) {
      return null;
    }
  }

  // Get services by vehicle ID
  List<Service> getServicesByVehicle(String vehicleId) {
    return _services.where((s) => s.vehicleId == vehicleId).toList();
  }

  // Get services by category
  List<Service> getServicesByCategory(String category) {
    return _services.where((s) => s.serviceCategory == category).toList();
  }

  // Clear all services (for logout)
  void clearServices() {
    _services.clear();
    _error = null;
    notifyListeners();
  }
}
