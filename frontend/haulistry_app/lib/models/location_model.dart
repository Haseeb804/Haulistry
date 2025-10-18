class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }
}

class ServiceProviderLocation {
  final String providerId;
  final String providerName;
  final Location location;
  final DateTime lastUpdated;
  final bool isOnline;
  final String? vehicleType;

  ServiceProviderLocation({
    required this.providerId,
    required this.providerName,
    required this.location,
    required this.lastUpdated,
    this.isOnline = false,
    this.vehicleType,
  });

  factory ServiceProviderLocation.fromJson(Map<String, dynamic> json) {
    return ServiceProviderLocation(
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      isOnline: json['isOnline'] ?? false,
      vehicleType: json['vehicleType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'location': location.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOnline': isOnline,
      'vehicleType': vehicleType,
    };
  }
}

class RouteInfo {
  final List<Location> polylinePoints;
  final double distanceInKm;
  final int durationInMinutes;
  final String? estimatedArrival;

  RouteInfo({
    required this.polylinePoints,
    required this.distanceInKm,
    required this.durationInMinutes,
    this.estimatedArrival,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      polylinePoints: (json['polylinePoints'] as List<dynamic>?)
              ?.map((point) => Location.fromJson(point))
              .toList() ??
          [],
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      durationInMinutes: json['durationInMinutes'] ?? 0,
      estimatedArrival: json['estimatedArrival'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polylinePoints': polylinePoints.map((p) => p.toJson()).toList(),
      'distanceInKm': distanceInKm,
      'durationInMinutes': durationInMinutes,
      'estimatedArrival': estimatedArrival,
    };
  }

  String get formattedDistance {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (durationInMinutes < 60) {
      return '$durationInMinutes min';
    }
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
