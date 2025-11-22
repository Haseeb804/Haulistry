import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';
import 'location_picker_web.dart';

/// Platform-aware Location Picker
/// Automatically uses web version for web platform
/// and native version for Android/iOS
class PlatformLocationPicker extends StatelessWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const PlatformLocationPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  Widget build(BuildContext context) {
    // Use web-specific implementation for web platform
    if (kIsWeb) {
      return LocationPickerWeb(
        initialLocation: initialLocation,
        initialAddress: initialAddress,
      );
    }
    
    // Use native implementation for mobile platforms
    return LocationPickerScreen(
      initialLocation: initialLocation,
      initialAddress: initialAddress,
    );
  }
}
