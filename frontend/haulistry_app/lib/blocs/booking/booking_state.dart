import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingServicesLoaded extends BookingState {
  final List<Service> services;
  final Service? selectedService;

  const BookingServicesLoaded({
    required this.services,
    this.selectedService,
  });

  @override
  List<Object?> get props => [services, selectedService];
}

class BookingListLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingListLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingCreated extends BookingState {
  final BookingModel booking;

  const BookingCreated({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingUpdated extends BookingState {
  final String bookingId;
  final String status;

  const BookingUpdated({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
