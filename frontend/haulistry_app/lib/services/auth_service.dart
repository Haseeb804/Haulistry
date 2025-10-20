import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'graphql_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GraphQLService _graphql = GraphQLService();
  
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // User is authenticated if they have either Firebase user OR backend user profile with token
  bool get isAuthenticated => _currentUser != null || _userProfile != null;
  String? get userType => _userProfile?['userType'];

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
    
    // Try to restore session from stored data
    _restoreSession();
  }
  
  /// Restore user session from stored data (for web when Firebase client auth fails)
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('custom_token');
      final userUid = prefs.getString('user_uid');
      final userEmail = prefs.getString('user_email');
      final userType = prefs.getString('user_type');
      
      if (token != null && userUid != null) {
        // Load full user profile from backend using the token
        await _loadUserProfile(userUid);
      }
    } catch (e) {
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Sign in with custom token (works for both web and mobile)
  Future<UserCredential> _signInWithCustomToken(String customToken) async {
    try {
      
      // For both web and mobile, we'll try the direct method first
      // This may work on some web configurations and all mobile
      try {
        final credential = await _auth.signInWithCustomToken(customToken);
        return credential;
      } catch (customTokenError) {
        throw customTokenError;
      }
      
    } catch (e) {
      rethrow;
    }
  }

  /// Load user profile from GraphQL backend
  Future<void> _loadUserProfile(String uid) async {
    try {
      _userProfile = await _graphql.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
    }
  }

  /// Public method to reload current user profile
  Future<void> loadUserProfile() async {
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.uid);
    }
  }

  /// Register a new seeker (customer)
  Future<bool> registerSeeker({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      
      _setLoading(true);
      _setError(null);

      // Call GraphQL mutation - this creates user in both Firebase and Neo4j
      final result = await _graphql.registerSeeker(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (!result['success']) {
        throw Exception(result['message'] ?? 'Registration failed');
      }

      
      // Store user data
      _userProfile = result['user'];
      
      // Save authentication data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_token', result['token']);
      await prefs.setString('user_uid', result['user']['uid']);
      await prefs.setString('user_email', result['user']['email']);
      await prefs.setString('user_type', result['user']['userType']);
      
      // Try Firebase client sign-in with custom token
      try {
        final credential = await _signInWithCustomToken(result['token']);
        _currentUser = credential.user;
      } catch (firebaseError) {
        // If custom token fails, the user is still authenticated via backend
        // User is authenticated with backend token
        _userProfile = result['user'];
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Register a new provider (service provider)
  Future<bool> registerProvider({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? businessName,
    String? businessType,
    String? serviceType,
    String? cnicNumber,
    String? address,
    String? city,
    String? province,
    int? yearsExperience,
    String? description,
  }) async {
    try {
      
      _setLoading(true);
      _setError(null);

      // Call GraphQL mutation - this creates user in both Firebase and Neo4j
      final result = await _graphql.registerProvider(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        businessName: businessName,
        businessType: businessType,
        serviceType: serviceType,
        cnicNumber: cnicNumber,
        address: address,
        city: city,
        province: province,
        yearsExperience: yearsExperience,
        description: description,
      );

      if (!result['success']) {
        throw Exception(result['message'] ?? 'Registration failed');
      }


      // Store user data
      _userProfile = result['user'];
      
      // Save authentication data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_token', result['token']);
      await prefs.setString('user_uid', result['user']['uid']);
      await prefs.setString('user_email', result['user']['email']);
      await prefs.setString('user_type', result['user']['userType']);
      
      // Try Firebase client sign-in with custom token
      try {
        final credential = await _signInWithCustomToken(result['token']);
        _currentUser = credential.user;
        notifyListeners();
      } catch (firebaseError) {
        // Custom token sign-in may not work on web due to API key restrictions
        // But the user IS authenticated via backend - set them as authenticated
        
        // User is authenticated with backend token
        _userProfile = result['user'];
        _currentUser = null;
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Login user with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // First, sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      // Then call GraphQL to get user data from Neo4j
      final result = await _graphql.login(
        email: email,
        password: password,
      );

      if (!result['success']) {
        throw Exception(result['message'] ?? 'Login failed');
      }

      // Store user data
      _userProfile = result['user'];
      
      // 🐛 DEBUG: Print what we received from backend
      
      // Check if seeker - print preferences
      if (_userProfile?['userType'] == 'seeker') {
      }
      
      // Save custom token if provided
      if (result['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_token', result['token']);
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Reload user profile from backend (useful after updates)
  Future<bool> reloadUserProfile() async {
    try {
      if (_userProfile == null) {
        return false;
      }

      final uid = _userProfile?['uid'];
      if (uid == null) {
        return false;
      }


      // Call GraphQL to get fresh user data from Neo4j
      final freshProfile = await _graphql.getUserProfile(uid);

      if (freshProfile != null) {
        _userProfile = freshProfile;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_token');
      
      // Sign out from Firebase
      await _auth.signOut();
      
      _currentUser = null;
      _userProfile = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      await _currentUser!.updateDisplayName(displayName);
      await _currentUser!.updatePhotoURL(photoURL);
      await _currentUser!.reload();
      _currentUser = _auth.currentUser;

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Get current user's Firebase ID token
  Future<String?> getIdToken() async {
    try {
      return await _currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  /// Refresh user profile from backend
  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.uid);
    }
  }

  /// Handle Firebase Auth errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Update provider profile with optional business fields
  Future<bool> updateProviderProfile({
    required String uid,
    String? businessName,
    String? businessType,
    String? serviceType,
    String? cnicNumber,
    String? address,
    String? city,
    String? province,
    int? yearsExperience,
    String? description,
    // Document images (Base64 data URLs)
    String? profileImage,
    String? cnicFrontImage,
    String? cnicBackImage,
    String? licenseImage,
    String? licenseNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);


      final result = await _graphql.updateProviderProfile(
        uid: uid,
        businessName: businessName,
        businessType: businessType,
        serviceType: serviceType,
        cnicNumber: cnicNumber,
        address: address,
        city: city,
        province: province,
        yearsExperience: yearsExperience,
        description: description,
        profileImage: profileImage,
        cnicFrontImage: cnicFrontImage,
        cnicBackImage: cnicBackImage,
        licenseImage: licenseImage,
        licenseNumber: licenseNumber,
      );

      if (!result['success']) {
        throw Exception(result['message']);
      }

      // Update local user profile
      _userProfile = result['user'];
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_userProfile);
      await prefs.setString('user_profile', userJson);
      
      notifyListeners();
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update seeker profile with optional personal fields
  Future<bool> updateSeekerProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? profileImage,
    String? address,
    String? bio,
    String? gender,
    String? dateOfBirth,
    String? serviceCategories,
    String? categoryDetails,
    String? serviceRequirements,
    String? primaryPurpose,
    String? urgency,
    String? preferencesNotes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);


      final result = await _graphql.updateSeekerProfile(
        uid: uid,
        fullName: fullName,
        phone: phone,
        profileImage: profileImage,
        address: address,
        bio: bio,
        gender: gender,
        dateOfBirth: dateOfBirth,
        serviceCategories: serviceCategories,
        categoryDetails: categoryDetails,
        serviceRequirements: serviceRequirements,
        primaryPurpose: primaryPurpose,
        urgency: urgency,
        preferencesNotes: preferencesNotes,
      );

      if (!result['success']) {
        throw Exception(result['message']);
      }

      // Update local user profile
      _userProfile = result['user'];
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_userProfile);
      await prefs.setString('user_profile', userJson);
      
      notifyListeners();
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Expose GraphQL service for advanced operations
  GraphQLService get graphqlService => _graphql;

  /// Update user profile in memory (used when preferences are updated)
  void updateUserProfile(Map<String, dynamic> updatedProfile) {
    _userProfile = updatedProfile;
    notifyListeners();
  }
}



