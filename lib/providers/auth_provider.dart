import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _userRole = '';
  UserModel? _currentUser;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    _userRole = prefs.getString(AppConstants.keyUserRole) ?? '';
    
    if (_isLoggedIn) {
      // Load user data from preferences
      // final userId = prefs.getString(AppConstants.keyUserId) ?? '';
      // final userToken = prefs.getString(AppConstants.keyUserToken) ?? '';
      // Load user details...
    }
    
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock login - replace with actual API call
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserToken, 'mock_token_123');
        await prefs.setString(AppConstants.keyUserId, 'user_123');
        
        // Determine role based on email (mock logic)
        _userRole = email.contains('provider') 
            ? AppConstants.roleProvider 
            : AppConstants.roleSeeker;
        await prefs.setString(AppConstants.keyUserRole, _userRole);

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signup
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock signup - replace with actual API call
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserToken, 'mock_token_123');
      await prefs.setString(AppConstants.keyUserId, 'user_123');
      await prefs.setString(AppConstants.keyUserRole, role);

      _userRole = role;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isLoggedIn = false;
    _userRole = '';
    _currentUser = null;
    notifyListeners();
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
