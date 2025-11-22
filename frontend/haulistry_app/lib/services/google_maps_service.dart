import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Enhanced Google Maps Service with Places Autocomplete and Directions API
/// Implements modern search algorithms and route optimization
class GoogleMapsService {
  static const String _apiKey = 'AIzaSyAS4j4CQrnzzsnob_s22yNxjOV5FdBSjRo';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Search places with autocomplete (optimized for Pakistan)
  /// Uses sessionToken for billing optimization
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    LatLng? location,
    int radius = 50000,
    String? sessionToken,
  }) async {
    if (query.isEmpty) return [];

    try {
      final params = {
        'input': query,
        'key': _apiKey,
        'components': 'country:pk', // Restrict to Pakistan
        if (sessionToken != null) 'sessiontoken': sessionToken,
        if (location != null) ...{
          'location': '${location.latitude},${location.longitude}',
          'radius': radius.toString(),
        },
      };

      final uri = Uri.parse('$_baseUrl/place/autocomplete/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching places: $e');
    }
    return [];
  }

  /// Get detailed place information including coordinates
  Future<PlaceDetails?> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) async {
    try {
      final params = {
        'place_id': placeId,
        'key': _apiKey,
        'fields': 'geometry,formatted_address,address_components,name,types',
        if (sessionToken != null) 'sessiontoken': sessionToken,
      };

      final uri = Uri.parse('$_baseUrl/place/details/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
    return null;
  }

  /// Get optimized route with multiple alternatives
  /// Uses traffic-aware routing and considers various factors
  Future<List<RouteInfo>> getOptimizedRoutes(
    LatLng origin,
    LatLng destination, {
    bool avoidTolls = false,
    bool avoidHighways = false,
    bool avoidFerries = false,
    int maxAlternatives = 3,
  }) async {
    try {
      final avoid = <String>[];
      if (avoidTolls) avoid.add('tolls');
      if (avoidHighways) avoid.add('highways');
      if (avoidFerries) avoid.add('ferries');

      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': _apiKey,
        'mode': 'driving',
        'departure_time': 'now', // Traffic-aware routing
        'alternatives': 'true',
        'traffic_model': 'best_guess', // or 'pessimistic', 'optimistic'
        if (avoid.isNotEmpty) 'avoid': avoid.join('|'),
      };

      final uri = Uri.parse('$_baseUrl/directions/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final routes = (data['routes'] as List)
              .take(maxAlternatives)
              .map((r) => RouteInfo.fromJson(r))
              .toList();

          // Sort by a combination of time and distance
          routes.sort((a, b) {
            final scoreA = a.durationSeconds + (a.distanceMeters / 100);
            final scoreB = b.durationSeconds + (b.distanceMeters / 100);
            return scoreA.compareTo(scoreB);
          });

          return routes;
        }
      }
    } catch (e) {
      print('Error getting routes: $e');
    }
    return [];
  }

  /// Calculate distance matrix for multiple origins/destinations
  /// Useful for finding nearest services
  Future<DistanceMatrix?> getDistanceMatrix(
    List<LatLng> origins,
    List<LatLng> destinations,
  ) async {
    try {
      final originsStr = origins
          .map((l) => '${l.latitude},${l.longitude}')
          .join('|');
      final destinationsStr = destinations
          .map((l) => '${l.latitude},${l.longitude}')
          .join('|');

      final params = {
        'origins': originsStr,
        'destinations': destinationsStr,
        'key': _apiKey,
        'mode': 'driving',
        'departure_time': 'now',
      };

      final uri = Uri.parse('$_baseUrl/distancematrix/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return DistanceMatrix.fromJson(data);
        }
      }
    } catch (e) {
      print('Error getting distance matrix: $e');
    }
    return null;
  }

  /// Geocode address to coordinates
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final params = {
        'address': address,
        'key': _apiKey,
        'components': 'country:PK',
      };

      final uri = Uri.parse('$_baseUrl/geocode/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      print('Error geocoding address: $e');
    }
    return null;
  }

  /// Reverse geocode coordinates to address
  Future<String?> reverseGeocode(LatLng position) async {
    try {
      final params = {
        'latlng': '${position.latitude},${position.longitude}',
        'key': _apiKey,
      };

      final uri = Uri.parse('$_baseUrl/geocode/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return null;
  }

  /// Search nearby places by type and location
  Future<List<NearbyPlace>> searchNearbyPlaces(
    LatLng location, {
    required String type, // e.g., 'gas_station', 'parking'
    int radius = 5000,
  }) async {
    try {
      final params = {
        'location': '${location.latitude},${location.longitude}',
        'radius': radius.toString(),
        'type': type,
        'key': _apiKey,
      };

      final uri = Uri.parse('$_baseUrl/place/nearbysearch/json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['results'] as List)
              .map((p) => NearbyPlace.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching nearby places: $e');
    }
    return [];
  }
}

/// Place suggestion from autocomplete
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
}

/// Detailed place information
class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final LatLng location;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    final components = json['address_components'] as List?;

    String? city, state, country, postalCode;
    if (components != null) {
      for (var component in components) {
        final types = component['types'] as List;
        if (types.contains('locality')) {
          city = component['long_name'];
        } else if (types.contains('administrative_area_level_1')) {
          state = component['long_name'];
        } else if (types.contains('country')) {
          country = component['long_name'];
        } else if (types.contains('postal_code')) {
          postalCode = component['long_name'];
        }
      }
    }

    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'],
      location: LatLng(location['lat'], location['lng']),
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
    );
  }
}

/// Route information with polyline
class RouteInfo {
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;
  final int? durationInTrafficSeconds;
  final String? durationInTrafficText;
  final List<LatLng> polylinePoints;
  final String startAddress;
  final String endAddress;
  final List<RouteStep> steps;

  RouteInfo({
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
    this.durationInTrafficSeconds,
    this.durationInTrafficText,
    required this.polylinePoints,
    required this.startAddress,
    required this.endAddress,
    required this.steps,
  });

  double get distanceKm => distanceMeters / 1000;
  double get durationHours => durationSeconds / 3600;

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    final leg = json['legs'][0];
    final polyline = json['overview_polyline']['points'];

    return RouteInfo(
      distanceMeters: leg['distance']['value'],
      distanceText: leg['distance']['text'],
      durationSeconds: leg['duration']['value'],
      durationText: leg['duration']['text'],
      durationInTrafficSeconds: leg['duration_in_traffic']?['value'],
      durationInTrafficText: leg['duration_in_traffic']?['text'],
      polylinePoints: _decodePolyline(polyline),
      startAddress: leg['start_address'],
      endAddress: leg['end_address'],
      steps: (leg['steps'] as List)
          .map((s) => RouteStep.fromJson(s))
          .toList(),
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}

/// Route step with instructions
class RouteStep {
  final String instruction;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['html_instructions']
          .replaceAll(RegExp(r'<[^>]*>'), ''), // Strip HTML tags
      distanceMeters: json['distance']['value'],
      distanceText: json['distance']['text'],
      durationSeconds: json['duration']['value'],
      durationText: json['duration']['text'],
    );
  }
}

/// Distance matrix result
class DistanceMatrix {
  final List<List<DistanceElement>> elements;

  DistanceMatrix({required this.elements});

  factory DistanceMatrix.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as List;
    final elements = rows.map((row) {
      final rowElements = row['elements'] as List;
      return rowElements.map((e) => DistanceElement.fromJson(e)).toList();
    }).toList();

    return DistanceMatrix(elements: elements);
  }
}

/// Distance matrix element
class DistanceElement {
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  DistanceElement({
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });

  factory DistanceElement.fromJson(Map<String, dynamic> json) {
    return DistanceElement(
      distanceMeters: json['distance']['value'],
      distanceText: json['distance']['text'],
      durationSeconds: json['duration']['value'],
      durationText: json['duration']['text'],
    );
  }
}

/// Nearby place result
class NearbyPlace {
  final String placeId;
  final String name;
  final LatLng location;
  final String vicinity;
  final double? rating;
  final bool openNow;

  NearbyPlace({
    required this.placeId,
    required this.name,
    required this.location,
    required this.vicinity,
    this.rating,
    required this.openNow,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return NearbyPlace(
      placeId: json['place_id'],
      name: json['name'],
      location: LatLng(location['lat'], location['lng']),
      vicinity: json['vicinity'] ?? '',
      rating: json['rating']?.toDouble(),
      openNow: json['opening_hours']?['open_now'] ?? false,
    );
  }
}
