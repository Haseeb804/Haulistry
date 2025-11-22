import 'package:equatable/equatable.dart';
import '../../models/vehicle_model.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehiclesRequested extends VehicleEvent {}

class AddVehicleRequested extends VehicleEvent {
  final Vehicle vehicle;

  const AddVehicleRequested({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}

class UpdateVehicleRequested extends VehicleEvent {
  final String vehicleId;
  final Vehicle updatedVehicle;

  const UpdateVehicleRequested({
    required this.vehicleId,
    required this.updatedVehicle,
  });

  @override
  List<Object?> get props => [vehicleId, updatedVehicle];
}

class DeleteVehicleRequested extends VehicleEvent {
  final String vehicleId;

  const DeleteVehicleRequested({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class ToggleVehicleAvailabilityRequested extends VehicleEvent {
  final String vehicleId;

  const ToggleVehicleAvailabilityRequested({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
