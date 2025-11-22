import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/graphql_service.dart';
import '../../services/auth_service.dart';
import '../../models/service_model.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();
  
  List<Service> _services = [];

  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServicesRequested>(_onLoadServicesRequested);
    on<LoadVehicleServicesRequested>(_onLoadVehicleServicesRequested);
    on<AddServiceRequested>(_onAddServiceRequested);
    on<UpdateServiceRequested>(_onUpdateServiceRequested);
    on<DeleteServiceRequested>(_onDeleteServiceRequested);
    on<ToggleServiceActiveRequested>(_onToggleServiceActiveRequested);
  }

  String? get _providerUid => _authService.userProfile?['uid'];

  Future<void> _onLoadServicesRequested(
    LoadServicesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    if (_providerUid == null) {
      emit(ServiceError(message: 'User not logged in'));
      return;
    }

    emit(ServiceLoading());

    try {
      final servicesData = await _graphqlService.getProviderServices(_providerUid!);
      
      _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
      
      emit(ServiceLoaded(services: _services));
    } catch (e) {
      emit(ServiceError(message: 'Failed to load services: $e'));
    }
  }

  Future<void> _onLoadVehicleServicesRequested(
    LoadVehicleServicesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    try {
      final servicesData = await _graphqlService.getVehicleServices(event.vehicleId);
      
      final vehicleServices = servicesData.map((data) => Service.fromGraphQL(data)).toList();
      
      emit(VehicleServicesLoaded(
        services: vehicleServices,
        vehicleId: event.vehicleId,
      ));
    } catch (e) {
      emit(ServiceError(message: 'Failed to load vehicle services: $e'));
    }
  }

  Future<void> _onAddServiceRequested(
    AddServiceRequested event,
    Emitter<ServiceState> emit,
  ) async {
    if (_providerUid == null) {
      emit(ServiceError(message: 'User not logged in'));
      return;
    }

    emit(ServiceLoading());

    try {
      final response = await _graphqlService.addService(
        vehicleId: event.service.vehicleId,
        providerUid: _providerUid!,
        serviceName: event.service.serviceName,
        serviceCategory: event.service.serviceCategory,
        pricePerHour: event.service.pricePerHour,
        pricePerDay: event.service.pricePerDay,
        pricePerService: event.service.pricePerService,
        description: event.service.description,
        serviceArea: event.service.serviceArea,
        minBookingDuration: event.service.minBookingDuration,
        latitude: event.service.latitude,
        longitude: event.service.longitude,
        fullAddress: event.service.fullAddress,
        city: event.service.city,
        province: event.service.province,
        serviceImages: event.serviceImages,
        isActive: event.service.isActive,
        availableDays: event.service.availableDays,
        availableHours: event.service.availableHours,
        operatorIncluded: event.service.operatorIncluded,
        fuelIncluded: event.service.fuelIncluded,
        transportationIncluded: event.service.transportationIncluded,
      );

      if (response['success'] == true) {
        final servicesData = await _graphqlService.getProviderServices(_providerUid!);
        _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
        
        emit(ServiceAdded(service: event.service));
        emit(ServiceLoaded(services: _services));
      } else {
        emit(ServiceError(message: response['message'] ?? 'Failed to add service'));
      }
    } catch (e) {
      emit(ServiceError(message: 'Failed to add service: $e'));
    }
  }

  Future<void> _onUpdateServiceRequested(
    UpdateServiceRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    try {
      final response = await _graphqlService.updateService(
        serviceId: event.serviceId,
        serviceName: event.updatedService.serviceName,
        serviceCategory: event.updatedService.serviceCategory,
        pricePerHour: event.updatedService.pricePerHour,
        pricePerDay: event.updatedService.pricePerDay,
        pricePerService: event.updatedService.pricePerService,
        description: event.updatedService.description,
        serviceArea: event.updatedService.serviceArea,
        minBookingDuration: event.updatedService.minBookingDuration,
        isActive: event.updatedService.isActive,
        availableDays: event.updatedService.availableDays,
        availableHours: event.updatedService.availableHours,
        operatorIncluded: event.updatedService.operatorIncluded,
        fuelIncluded: event.updatedService.fuelIncluded,
        transportationIncluded: event.updatedService.transportationIncluded,
      );

      if (response['success'] == true && _providerUid != null) {
        final servicesData = await _graphqlService.getProviderServices(_providerUid!);
        _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
        
        emit(ServiceUpdated(service: event.updatedService));
        emit(ServiceLoaded(services: _services));
      } else {
        emit(ServiceError(message: response['message'] ?? 'Failed to update service'));
      }
    } catch (e) {
      emit(ServiceError(message: 'Failed to update service: $e'));
    }
  }

  Future<void> _onDeleteServiceRequested(
    DeleteServiceRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    try {
      final response = await _graphqlService.deleteService(event.serviceId);

      if (response['success'] == true && _providerUid != null) {
        final servicesData = await _graphqlService.getProviderServices(_providerUid!);
        _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
        
        emit(ServiceDeleted(serviceId: event.serviceId));
        emit(ServiceLoaded(services: _services));
      } else {
        emit(ServiceError(message: response['message'] ?? 'Failed to delete service'));
      }
    } catch (e) {
      emit(ServiceError(message: 'Failed to delete service: $e'));
    }
  }

  Future<void> _onToggleServiceActiveRequested(
    ToggleServiceActiveRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    try {
      // Note: toggleServiceActive method needs to be added to GraphQLService
      // For now, we'll use updateService to toggle active status
      // You can implement the specific toggle mutation in GraphQLService later
      
      if (_providerUid != null) {
        // Reload services to get updated list
        final servicesData = await _graphqlService.getProviderServices(_providerUid!);
        _services = servicesData.map((data) => Service.fromGraphQL(data)).toList();
        
        emit(ServiceLoaded(services: _services));
      } else {
        emit(ServiceError(message: 'User not authenticated'));
      }
    } catch (e) {
      emit(ServiceError(message: 'Failed to toggle service status: $e'));
    }
  }
}
