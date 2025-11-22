import 'package:equatable/equatable.dart';
import '../../models/service_model.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<Service> services;

  const ServiceLoaded({required this.services});

  @override
  List<Object?> get props => [services];

  List<Service> get activeServices => services.where((s) => s.isActive).toList();
  bool get hasServices => services.isNotEmpty;
}

class VehicleServicesLoaded extends ServiceState {
  final List<Service> services;
  final String vehicleId;

  const VehicleServicesLoaded({
    required this.services,
    required this.vehicleId,
  });

  @override
  List<Object?> get props => [services, vehicleId];
}

class ServiceAdded extends ServiceState {
  final Service service;

  const ServiceAdded({required this.service});

  @override
  List<Object?> get props => [service];
}

class ServiceUpdated extends ServiceState {
  final Service service;

  const ServiceUpdated({required this.service});

  @override
  List<Object?> get props => [service];
}

class ServiceDeleted extends ServiceState {
  final String serviceId;

  const ServiceDeleted({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError({required this.message});

  @override
  List<Object?> get props => [message];
}
