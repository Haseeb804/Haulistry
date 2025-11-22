import 'package:equatable/equatable.dart';
import '../../models/service_model.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadServicesRequested extends ServiceEvent {}

class LoadVehicleServicesRequested extends ServiceEvent {
  final String vehicleId;

  const LoadVehicleServicesRequested({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class AddServiceRequested extends ServiceEvent {
  final Service service;
  final String? serviceImages;

  const AddServiceRequested({
    required this.service,
    this.serviceImages,
  });

  @override
  List<Object?> get props => [service, serviceImages];
}

class UpdateServiceRequested extends ServiceEvent {
  final String serviceId;
  final Service updatedService;

  const UpdateServiceRequested({
    required this.serviceId,
    required this.updatedService,
  });

  @override
  List<Object?> get props => [serviceId, updatedService];
}

class DeleteServiceRequested extends ServiceEvent {
  final String serviceId;

  const DeleteServiceRequested({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

class ToggleServiceActiveRequested extends ServiceEvent {
  final String serviceId;

  const ToggleServiceActiveRequested({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}
