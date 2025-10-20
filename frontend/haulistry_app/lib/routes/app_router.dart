import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/seeker/seeker_dashboard_screen.dart';
import '../screens/seeker/service_listing_screen.dart';
import '../screens/seeker/service_detail_screen.dart';
import '../screens/seeker/booking_screen.dart';
import '../screens/seeker/my_bookings_screen.dart';
import '../screens/seeker/booking_detail_screen.dart';
import '../screens/seeker/profile_screen.dart';
import '../screens/seeker/edit_profile_screen.dart';
import '../screens/seeker/favorites_screen.dart';
import '../screens/seeker/settings_screen.dart' as seeker_settings;
import '../screens/seeker/seeker_service_preferences_screen.dart';
import '../screens/seeker/view_preferences_screen.dart';
import '../screens/provider/provider_dashboard_screen.dart';
import '../screens/provider/vehicle_details_screen.dart';
import '../screens/provider/vehicle_management_screen.dart';
import '../screens/provider/add_edit_vehicle_screen.dart';
import '../screens/provider/services_management_screen.dart';
import '../screens/provider/add_edit_service_screen.dart';
import '../screens/provider/booking_requests_screen.dart';
import '../screens/provider/provider_bookings_screen.dart';
import '../screens/provider/provider_earnings_screen.dart';
import '../screens/provider/reviews_management_screen.dart';
import '../screens/provider/provider_profile_screen.dart';
import '../screens/provider/edit_provider_profile_screen.dart';
import '../screens/provider/provider_settings_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/common/messages_screen.dart';
import '../screens/common/chat_screen.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/help_support_screen.dart';
import '../screens/common/privacy_security_screen.dart';
import '../screens/common/payment_settings_screen.dart';
import '../screens/common/location_settings_screen.dart';
import '../screens/common/about_screen.dart';
import '../screens/common/help_center_screen.dart';
import '../screens/common/privacy_policy_screen.dart';
import '../screens/common/terms_of_service_screen.dart';
import '../screens/provider/verify_account_screen.dart';
import '../screens/provider/service_areas_screen.dart';
import '../screens/provider/document_upload_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? '';
          return SignupScreen(role: role);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Seeker Routes
      GoRoute(
        path: '/seeker/dashboard',
        name: 'seeker-dashboard',
        builder: (context, state) => const SeekerDashboardScreen(),
      ),
      GoRoute(
        path: '/seeker/services/:type',
        name: 'service-listing',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? '';
          return ServiceListingScreen(serviceType: type);
        },
      ),
      GoRoute(
        path: '/seeker/service/:id',
        name: 'service-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ServiceDetailScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: '/seeker/booking/:serviceId',
        name: 'booking',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId'] ?? '';
          return BookingScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/seeker/my-bookings',
        name: 'my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/seeker/booking-detail/:id',
        name: 'booking-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/seeker/profile',
        name: 'seeker-profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/seeker/edit-profile',
        name: 'seeker-edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/seeker/favorites',
        name: 'seeker-favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/seeker/settings',
        name: 'seeker-settings',
        builder: (context, state) => const seeker_settings.SettingsScreen(),
      ),
      GoRoute(
        path: '/seeker/service-preferences',
        name: 'seeker-service-preferences',
        builder: (context, state) => const SeekerServicePreferencesScreen(),
      ),
      GoRoute(
        path: '/seeker/view-preferences',
        name: 'view-preferences',
        builder: (context, state) => const ViewPreferencesScreen(),
      ),
      
      // Provider Routes
      GoRoute(
        path: '/provider/vehicle-details',
        name: 'vehicle-details',
        builder: (context, state) => const VehicleDetailsScreen(),
      ),
      GoRoute(
        path: '/provider/vehicles',
        name: 'vehicle-management',
        builder: (context, state) => const VehicleManagementScreen(),
      ),
      GoRoute(
        path: '/provider/add-vehicle',
        name: 'add-vehicle',
        builder: (context, state) {
          final isOnboarding = state.uri.queryParameters['onboarding'] == 'true';
          return AddEditVehicleScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/provider/edit-vehicle/:id',
        name: 'edit-vehicle',
        builder: (context, state) {
          final vehicleId = state.pathParameters['id'];
          return AddEditVehicleScreen(vehicleId: vehicleId);
        },
      ),
      GoRoute(
        path: '/provider/dashboard',
        name: 'provider-dashboard',
        builder: (context, state) => const ProviderDashboardScreen(),
      ),
      GoRoute(
        path: '/provider/services',
        name: 'provider-services',
        builder: (context, state) => const ServicesManagementScreen(),
      ),
      GoRoute(
        path: '/provider/add-service',
        name: 'add-service',
        builder: (context, state) => const AddEditServiceScreen(),
      ),
      GoRoute(
        path: '/provider/edit-service/:id',
        name: 'edit-service',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AddEditServiceScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: '/provider/booking-requests',
        name: 'booking-requests',
        builder: (context, state) => const BookingRequestsScreen(),
      ),
      GoRoute(
        path: '/provider/bookings',
        name: 'provider-bookings',
        builder: (context, state) => const ProviderBookingsScreen(),
      ),
      GoRoute(
        path: '/provider/earnings',
        name: 'provider-earnings',
        builder: (context, state) => const ProviderEarningsScreen(),
      ),
      GoRoute(
        path: '/provider/reviews',
        name: 'provider-reviews',
        builder: (context, state) => const ReviewsManagementScreen(),
      ),
      GoRoute(
        path: '/provider/profile',
        name: 'provider-profile',
        builder: (context, state) => const ProviderProfileScreen(),
      ),
      GoRoute(
        path: '/provider/edit-profile',
        name: 'provider-edit-profile',
        builder: (context, state) => const EditProviderProfileScreen(),
      ),
      GoRoute(
        path: '/provider/settings',
        name: 'provider-settings',
        builder: (context, state) => const ProviderSettingsScreen(),
      ),
      
      // Common Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        name: 'chat',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          final userName = state.uri.queryParameters['name'] ?? '';
          return ChatScreen(userId: userId, userName: userName);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      
      // New Settings Screens
      GoRoute(
        path: '/privacy-security',
        name: 'privacy-security',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: '/payment-settings',
        name: 'payment-settings',
        builder: (context, state) => const PaymentSettingsScreen(),
      ),
      GoRoute(
        path: '/location-settings',
        name: 'location-settings',
        builder: (context, state) => const LocationSettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/help-center',
        name: 'help-center',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/provider/verification',
        name: 'provider-verification',
        builder: (context, state) => const VerifyAccountScreen(),
      ),
      GoRoute(
        path: '/provider/service-areas',
        name: 'provider-service-areas',
        builder: (context, state) => const ServiceAreasScreen(),
      ),
      GoRoute(
        path: '/provider/document-upload',
        name: 'provider-document-upload',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
    ],
  );
}
