import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/service_provider.dart';
import 'providers/seeker_preferences_provider.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/booking/booking_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/vehicle/vehicle_bloc.dart';
import 'blocs/service/service_bloc.dart';
import 'blocs/seeker_preferences/seeker_preferences_bloc.dart';
import 'blocs/app_bloc_observer.dart';
import 'routes/app_router.dart';
import 'utils/app_colors.dart';
// Import new authentication service
import 'services/auth_service.dart';
import 'services/graphql_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set BLoC observer for debugging (only in debug mode)
  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize GraphQL client
  GraphQLService().initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create AuthService instance to be shared
    final authService = AuthService();
    
    return MultiProvider(
      providers: [
        // Keep AuthService as ChangeNotifierProvider for backward compatibility
        ChangeNotifierProvider.value(value: authService),
        // Keep old providers for gradual migration
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => SeekerPreferencesProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc()..add(AuthCheckRequested()),
          ),
          BlocProvider<BookingBloc>(
            create: (_) => BookingBloc(),
          ),
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(),
          ),
          BlocProvider<VehicleBloc>(
            create: (_) => VehicleBloc(),
          ),
          BlocProvider<ServiceBloc>(
            create: (_) => ServiceBloc(),
          ),
          BlocProvider<SeekerPreferencesBloc>(
            create: (_) => SeekerPreferencesBloc(authService: authService),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            if (themeState is ThemeLoading || themeState is ThemeInitial) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            
            if (themeState is ThemeLoaded) {
              return MaterialApp.router(
                title: 'Haulistry',
                debugShowCheckedModeBanner: false,
                theme: themeState.lightTheme,
                darkTheme: themeState.darkTheme,
                themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
              );
            }
            
            // Fallback
            return MaterialApp(
              home: Scaffold(
                body: Center(child: Text('Error loading theme')),
              ),
            );
          },
        ),
      ),
    );
  }
}
