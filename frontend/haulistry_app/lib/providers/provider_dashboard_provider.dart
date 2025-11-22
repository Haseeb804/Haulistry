import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../services/graphql_service.dart';
import '../services/auth_service.dart';

class ProviderDashboardProvider extends ChangeNotifier {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic> _stats = {
    'totalEarnings': 0.0,
    'monthlyEarnings': 0.0,
    'pendingBookings': 0,
    'completedBookings': 0,
    'activeServices': 0,
    'averageRating': 0.0,
    'totalReviews': 0,
  };
  
  List<BookingModel> _recentBookings = [];
  List<Service> _topServices = [];
  Map<String, dynamic> _performanceData = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;
  List<BookingModel> get recentBookings => _recentBookings;
  List<Service> get topServices => _topServices;
  Map<String, dynamic> get performanceData => _performanceData;

  String? get _providerUid => _authService.userProfile?['uid'];

  Future<void> loadDashboardData() async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadStats(),
        _loadRecentBookings(),
        _loadTopServices(),
        _loadPerformanceData(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _stats = {
        'totalEarnings': 125000.0,
        'monthlyEarnings': 45000.0,
        'pendingBookings': 3,
        'completedBookings': 28,
        'activeServices': 5,
        'averageRating': 4.5,
        'totalReviews': 42,
      };
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  Future<void> _loadRecentBookings() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _recentBookings = [];
    } catch (e) {
      throw Exception('Failed to load recent bookings: $e');
    }
  }

  Future<void> _loadTopServices() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _topServices = [];
    } catch (e) {
      throw Exception('Failed to load top services: $e');
    }
  }

  Future<void> _loadPerformanceData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _performanceData = {
        'weeklyBookings': [5, 8, 6, 10, 7, 9, 12],
        'monthlyRevenue': [35000, 42000, 38000, 45000],
        'serviceUsage': {
          'Harvester': 15,
          'Crane': 10,
          'Sand Truck': 8,
          'Brick Truck': 5,
        },
      };
    } catch (e) {
      throw Exception('Failed to load performance data: $e');
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }

  void clearData() {
    _stats = {
      'totalEarnings': 0.0,
      'monthlyEarnings': 0.0,
      'pendingBookings': 0,
      'completedBookings': 0,
      'activeServices': 0,
      'averageRating': 0.0,
      'totalReviews': 0,
    };
    _recentBookings = [];
    _topServices = [];
    _performanceData = {};
    _error = null;
    notifyListeners();
  }
}
