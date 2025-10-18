import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../models/location_model.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location
  Future<Location> getCurrentLocation() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address from coordinates
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        return Location(
          latitude: position.latitude,
          longitude: position.longitude,
          address: place.street,
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
          postalCode: place.postalCode,
        );
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  // Get address from coordinates
  Future<Location> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        return Location(
          latitude: latitude,
          longitude: longitude,
          address: place.street,
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
          postalCode: place.postalCode,
        );
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    return Location(latitude: latitude, longitude: longitude);
  }

  // Get coordinates from address
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);

      if (locations.isNotEmpty) {
        geo.Location location = locations[0];
        return Location(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
        );
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }

    return null;
  }

  // Calculate distance between two points (in km)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Get distance between two locations
  double getDistanceBetween(Location location1, Location location2) {
    return calculateDistance(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    );
  }

  // Stream location updates
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Get nearby service providers (mock implementation)
  Future<List<ServiceProviderLocation>> getNearbyProviders({
    required Location userLocation,
    required double radiusInKm,
    String? serviceType,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    return [
      ServiceProviderLocation(
        providerId: '1',
        providerName: 'Ahmad Transport Services',
        location: Location(
          latitude: userLocation.latitude + 0.01,
          longitude: userLocation.longitude + 0.01,
          address: 'Main Street, Lahore',
          city: 'Lahore',
        ),
        lastUpdated: DateTime.now(),
        isOnline: true,
        vehicleType: 'Harvester',
      ),
      ServiceProviderLocation(
        providerId: '2',
        providerName: 'Khan Machinery',
        location: Location(
          latitude: userLocation.latitude - 0.015,
          longitude: userLocation.longitude + 0.02,
          address: 'Canal Road, Lahore',
          city: 'Lahore',
        ),
        lastUpdated: DateTime.now(),
        isOnline: true,
        vehicleType: 'Crane',
      ),
    ];
  }

  // Get route between two locations (mock implementation)
  Future<RouteInfo> getRoute({
    required Location from,
    required Location to,
  }) async {
    // TODO: Integrate with Google Directions API or similar
    await Future.delayed(const Duration(seconds: 1));

    double distance = getDistanceBetween(from, to);
    int duration = (distance * 3).toInt(); // Rough estimate: 20 km/h

    return RouteInfo(
      polylinePoints: [from, to], // In reality, this would have many points
      distanceInKm: distance,
      durationInMinutes: duration,
      estimatedArrival:
          DateTime.now().add(Duration(minutes: duration)).toString(),
    );
  }

  // Track service provider location
  Stream<ServiceProviderLocation> trackProvider(String providerId) async* {
    // TODO: Implement real-time tracking with Firebase or WebSocket
    await Future.delayed(const Duration(seconds: 2));

    // Mock data stream
    while (true) {
      await Future.delayed(const Duration(seconds: 5));

      yield ServiceProviderLocation(
        providerId: providerId,
        providerName: 'Service Provider',
        location: Location(
          latitude: 31.5204 + (DateTime.now().second * 0.0001),
          longitude: 74.3587 + (DateTime.now().second * 0.0001),
          city: 'Lahore',
        ),
        lastUpdated: DateTime.now(),
        isOnline: true,
      );
    }
  }
}
