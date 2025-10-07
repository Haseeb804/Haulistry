import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;
  List<BookingModel> _bookings = [];
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  
  bool get isLoading => _isLoading;
  List<BookingModel> get bookings => _bookings;
  List<ServiceModel> get services => _services;
  ServiceModel? get selectedService => _selectedService;

  // Fetch services by type
  Future<void> fetchServices(String serviceType) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _services = _getMockServices(serviceType);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch bookings
  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _bookings = _getMockBookings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create booking
  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _bookings.add(booking);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId, 'cancelled');
  }

  // Set selected service
  void setSelectedService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  // Mock data generators
  List<ServiceModel> _getMockServices(String type) {
    return List.generate(10, (index) => ServiceModel(
      id: 'service_$index',
      providerId: 'provider_$index',
      providerName: 'Provider ${index + 1}',
      serviceType: type,
      title: '$type Service ${index + 1}',
      description: 'Professional $type service with experienced operators',
      pricePerHour: 1500 + (index * 200).toDouble(),
      rating: 4.0 + (index % 10) * 0.1,
      reviewCount: 20 + index * 5,
      imageUrl: 'https://via.placeholder.com/300',
      location: 'Lahore, Pakistan',
      isAvailable: index % 3 != 0,
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
