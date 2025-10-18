class AppConstants {
  // App Information
  static const String appName = 'Haulistry';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Book heavy machinery and transport services';
  
  // API Configuration
  static const String baseUrl = 'https://api.haulistry.com/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserToken = 'userToken';
  static const String keyUserId = 'userId';
  static const String keyUserRole = 'userRole';
  static const String keyUserData = 'userData';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  
  // User Roles
  static const String roleSeeker = 'seeker';
  static const String roleProvider = 'provider';
  
  // Service Types
  static const String serviceHarvester = 'harvester';
  static const String serviceSandTruck = 'sand_truck';
  static const String serviceBrickTruck = 'brick_truck';
  static const String serviceCrane = 'crane';
  
  // Booking Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentOnline = 'online';
  
  // Map Configuration
  static const double defaultLatitude = 31.5204; // Lahore
  static const double defaultLongitude = 74.3587;
  static const double defaultZoom = 14.0;
  
  // Pagination
  static const int itemsPerPage = 10;
  static const int maxSearchResults = 50;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  
  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}
