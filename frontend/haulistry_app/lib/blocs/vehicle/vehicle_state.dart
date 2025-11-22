import 'package:equatable/equatable.dart';
import '../../models/vehicle_model.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehicleLoaded({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];

  List<Vehicle> get availableVehicles => vehicles.where((v) => v.isAvailable).toList();
  bool get hasVehicles => vehicles.isNotEmpty;
}

class VehicleAdded extends VehicleState {
  final Vehicle vehicle;

  const VehicleAdded({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}

class VehicleUpdated extends VehicleState {
  final Vehicle vehicle;

  const VehicleUpdated({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}

class VehicleDeleted extends VehicleState {
  final String vehicleId;

  const VehicleDeleted({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError({required this.message});

  @override
  List<Object?> get props => [message];
}
