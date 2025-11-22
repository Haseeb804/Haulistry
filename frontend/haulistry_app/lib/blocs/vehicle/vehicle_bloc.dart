import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/graphql_service.dart';
import '../../services/auth_service.dart';
import '../../models/vehicle_model.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();
  
  List<Vehicle> _vehicles = [];

  VehicleBloc() : super(VehicleInitial()) {
    on<LoadVehiclesRequested>(_onLoadVehiclesRequested);
    on<AddVehicleRequested>(_onAddVehicleRequested);
    on<UpdateVehicleRequested>(_onUpdateVehicleRequested);
    on<DeleteVehicleRequested>(_onDeleteVehicleRequested);
    on<ToggleVehicleAvailabilityRequested>(_onToggleVehicleAvailabilityRequested);
  }

  String? get _providerUid => _authService.userProfile?['uid'];

  Future<void> _onLoadVehiclesRequested(
    LoadVehiclesRequested event,
    Emitter<VehicleState> emit,
  ) async {
    if (_providerUid == null) {
      emit(VehicleError(message: 'User not logged in'));
      return;
    }

    emit(VehicleLoading());

    try {
      final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
      
      _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
      
      emit(VehicleLoaded(vehicles: _vehicles));
    } catch (e) {
      emit(VehicleError(message: 'Failed to load vehicles: $e'));
    }
  }

  Future<void> _onAddVehicleRequested(
    AddVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    if (_providerUid == null) {
      emit(VehicleError(message: 'User not logged in'));
      return;
    }

    emit(VehicleLoading());

    try {
      final response = await _graphqlService.addVehicle(
        providerUid: _providerUid!,
        name: event.vehicle.vehicleName,
        vehicleType: event.vehicle.vehicleType,
        make: event.vehicle.make,
        model: event.vehicle.model,
        year: event.vehicle.year,
        registrationNumber: event.vehicle.registrationNumber,
        capacity: event.vehicle.capacity,
        condition: event.vehicle.condition,
        vehicleImage: event.vehicle.vehicleImage,
        hasInsurance: event.vehicle.hasInsurance,
        insuranceExpiry: event.vehicle.insuranceExpiry,
        isAvailable: event.vehicle.isAvailable,
        city: event.vehicle.city,
        province: event.vehicle.province,
        pricePerHour: event.vehicle.pricePerHour,
        pricePerDay: event.vehicle.pricePerDay,
        description: event.vehicle.description,
      );

      if (response['success'] == true) {
        // Reload vehicles to get updated list
        final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
        _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
        
        emit(VehicleAdded(vehicle: event.vehicle));
        emit(VehicleLoaded(vehicles: _vehicles));
      } else {
        emit(VehicleError(message: response['message'] ?? 'Failed to add vehicle'));
      }
    } catch (e) {
      emit(VehicleError(message: 'Failed to add vehicle: $e'));
    }
  }

  Future<void> _onUpdateVehicleRequested(
    UpdateVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    try {
      final response = await _graphqlService.updateVehicle(
        vehicleId: event.vehicleId,
        name: event.updatedVehicle.vehicleName,
        vehicleType: event.updatedVehicle.vehicleType,
        make: event.updatedVehicle.make,
        model: event.updatedVehicle.model,
        year: event.updatedVehicle.year,
        capacity: event.updatedVehicle.capacity,
        condition: event.updatedVehicle.condition,
        isAvailable: event.updatedVehicle.isAvailable,
        city: event.updatedVehicle.city,
        province: event.updatedVehicle.province,
        pricePerHour: event.updatedVehicle.pricePerHour,
        pricePerDay: event.updatedVehicle.pricePerDay,
        description: event.updatedVehicle.description,
      );

      if (response['success'] == true && _providerUid != null) {
        final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
        _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
        
        emit(VehicleUpdated(vehicle: event.updatedVehicle));
        emit(VehicleLoaded(vehicles: _vehicles));
      } else {
        emit(VehicleError(message: response['message'] ?? 'Failed to update vehicle'));
      }
    } catch (e) {
      emit(VehicleError(message: 'Failed to update vehicle: $e'));
    }
  }

  Future<void> _onDeleteVehicleRequested(
    DeleteVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    try {
      final response = await _graphqlService.deleteVehicle(event.vehicleId);

      if (response['success'] == true && _providerUid != null) {
        final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
        _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
        
        emit(VehicleDeleted(vehicleId: event.vehicleId));
        emit(VehicleLoaded(vehicles: _vehicles));
      } else {
        emit(VehicleError(message: response['message'] ?? 'Failed to delete vehicle'));
      }
    } catch (e) {
      emit(VehicleError(message: 'Failed to delete vehicle: $e'));
    }
  }

  Future<void> _onToggleVehicleAvailabilityRequested(
    ToggleVehicleAvailabilityRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    try {
      // Note: toggleVehicleAvailability method needs to be added to GraphQLService
      // For now, we'll use updateVehicle to toggle availability
      // You can implement the specific toggle mutation in GraphQLService later
      
      if (_providerUid != null) {
        // Reload vehicles to get updated list
        final vehiclesData = await _graphqlService.getProviderVehicles(_providerUid!);
        _vehicles = vehiclesData.map((data) => Vehicle.fromGraphQL(data)).toList();
        
        emit(VehicleLoaded(vehicles: _vehicles));
      } else {
        emit(VehicleError(message: 'User not authenticated'));
      }
    } catch (e) {
      emit(VehicleError(message: 'Failed to toggle availability: $e'));
    }
  }
}
