import 'package:flutter/material.dart';
import '../services/graphql_service.dart';
import '../services/auth_service.dart';

class EarningsProvider extends ChangeNotifier {
  final GraphQLService _graphqlService = GraphQLService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  
  double _totalEarnings = 0.0;
  double _pendingEarnings = 0.0;
  double _availableBalance = 0.0;
  double _withdrawnAmount = 0.0;
  
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _monthlyEarnings = [];
  Map<String, double> _earningsByService = {};
  
  String _selectedPeriod = 'This Month';

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalEarnings => _totalEarnings;
  double get pendingEarnings => _pendingEarnings;
  double get availableBalance => _availableBalance;
  double get withdrawnAmount => _withdrawnAmount;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get monthlyEarnings => _monthlyEarnings;
  Map<String, double> get earningsByService => _earningsByService;
  String get selectedPeriod => _selectedPeriod;

  String? get _providerUid => _authService.userProfile?['uid'];

  Future<void> loadEarnings() async {
    if (_providerUid == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _totalEarnings = 125000.0;
      _pendingEarnings = 15000.0;
      _availableBalance = 110000.0;
      _withdrawnAmount = 95000.0;
      
      _transactions = [
        {
          'id': 'TXN001',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'amount': 5000.0,
          'type': 'Booking Payment',
          'status': 'Completed',
          'service': 'Harvester',
          'bookingId': 'BK123',
        },
      ];
      
      _monthlyEarnings = [
        {'month': 'January', 'amount': 35000.0},
        {'month': 'February', 'amount': 42000.0},
      ];
      
      _earningsByService = {
        'Harvester': 55000.0,
        'Crane': 35000.0,
      };
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    loadEarnings();
  }

  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankDetails) async {
    if (_providerUid == null || amount > _availableBalance) {
      _error = amount > _availableBalance ? 'Insufficient balance' : 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      _availableBalance -= amount;
      _pendingEarnings += amount;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await loadEarnings();
  }

  void clearData() {
    _totalEarnings = 0.0;
    _pendingEarnings = 0.0;
    _availableBalance = 0.0;
    _withdrawnAmount = 0.0;
    _transactions = [];
    _monthlyEarnings = [];
    _earningsByService = {};
    _error = null;
    notifyListeners();
  }
}