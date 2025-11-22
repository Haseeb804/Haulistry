import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  List<BookingModel> _bookings = [];
  List<Service> _services = [];
  Service? _selectedService;

  BookingBloc() : super(BookingInitial()) {
    on<FetchServicesRequested>(_onFetchServicesRequested);
    on<FetchBookingsRequested>(_onFetchBookingsRequested);
    on<CreateBookingRequested>(_onCreateBookingRequested);
    on<UpdateBookingStatusRequested>(_onUpdateBookingStatusRequested);
    on<SelectServiceRequested>(_onSelectServiceRequested);
  }

  Future<void> _onFetchServicesRequested(
    FetchServicesRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _services = _getMockServices(event.serviceType);
      
      emit(BookingServicesLoaded(
        services: _services,
        selectedService: _selectedService,
      ));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onFetchBookingsRequested(
    FetchBookingsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _bookings = _getMockBookings();
      
      emit(BookingListLoaded(bookings: _bookings));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _bookings.add(event.booking);
      
      emit(BookingCreated(booking: event.booking));
      emit(BookingListLoaded(bookings: _bookings));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onUpdateBookingStatusRequested(
    UpdateBookingStatusRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _bookings.indexWhere((b) => b.id == event.bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: event.status);
      }
      
      emit(BookingUpdated(bookingId: event.bookingId, status: event.status));
      emit(BookingListLoaded(bookings: _bookings));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onSelectServiceRequested(
    SelectServiceRequested event,
    Emitter<BookingState> emit,
  ) async {
    _selectedService = event.service;
    
    emit(BookingServicesLoaded(
      services: _services,
      selectedService: _selectedService,
    ));
  }

  // Mock data generators
  List<Service> _getMockServices(String type) {
    return List.generate(10, (index) => Service(
      serviceId: 'service_$index',
      vehicleId: 'vehicle_$index',
      providerUid: 'provider_$index',
      serviceName: '$type Service ${index + 1}',
      serviceCategory: type,
      description: 'Professional $type service with experienced operators',
      pricePerHour: 1500 + (index * 200).toDouble(),
      rating: 4.0 + (index % 10) * 0.1,
      totalBookings: 20 + index * 5,
      isActive: index % 3 != 0,
    ));
  }

  List<BookingModel> _getMockBookings() {
    return List.generate(5, (index) => BookingModel(
      id: 'booking_$index',
      serviceId: 'service_$index',
      serviceName: 'Service ${index + 1}',
      providerName: 'Provider ${index + 1}',
      date: DateTime.now().add(Duration(days: index)),
      startTime: '09:00 AM',
      endTime: '05:00 PM',
      location: 'Location ${index + 1}',
      totalPrice: 5000 + (index * 1000).toDouble(),
      status: index % 3 == 0 ? 'pending' : index % 3 == 1 ? 'accepted' : 'completed',
    ));
  }
}
