import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class FetchServicesRequested extends BookingEvent {
  final String serviceType;

  const FetchServicesRequested({required this.serviceType});

  @override
  List<Object?> get props => [serviceType];
}

class FetchBookingsRequested extends BookingEvent {}

class CreateBookingRequested extends BookingEvent {
  final BookingModel booking;

  const CreateBookingRequested({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class UpdateBookingStatusRequested extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusRequested({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}

class SelectServiceRequested extends BookingEvent {
  final Service? service;

  const SelectServiceRequested({this.service});

  @override
  List<Object?> get props => [service];
}
