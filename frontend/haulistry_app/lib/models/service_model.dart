// Service model matching GraphQL Service type
class Service {
  final String serviceId;
  final String vehicleId;
  final String providerUid;
  final String serviceName;
  final String serviceCategory;
  final double? pricePerHour;
  final double? pricePerDay;
  final double? pricePerService;
  final String? description;
  final String? serviceArea;
  final String? minBookingDuration;
  final bool isActive;
  final String? availableDays; // JSON string
  final String? availableHours;
  final bool operatorIncluded;
  final bool fuelIncluded;
  final bool transportationIncluded;
  final int totalBookings;
  final double rating;
  final String? serviceImages; // JSON array string of base64 images
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.serviceId,
    required this.vehicleId,
    required this.providerUid,
    required this.serviceName,
    required this.serviceCategory,
    this.pricePerHour,
    this.pricePerDay,
    this.pricePerService,
    this.description,
    this.serviceArea,
    this.minBookingDuration,
    this.isActive = true,
    this.availableDays,
    this.availableHours,
    this.operatorIncluded = true,
    this.fuelIncluded = false,
    this.transportationIncluded = false,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.serviceImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Backward compatibility: use serviceId as id
  String get id => serviceId;

  // From GraphQL response
  factory Service.fromGraphQL(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] as String,
      vehicleId: json['vehicleId'] as String,
      providerUid: json['providerUid'] as String,
      serviceName: json['serviceName'] as String,
      serviceCategory: json['serviceCategory'] as String,
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerService: (json['pricePerService'] as num?)?.toDouble(),
      description: json['description'] as String?,
      serviceArea: json['serviceArea'] as String?,
      minBookingDuration: json['minBookingDuration'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      availableDays: json['availableDays'] as String?,
      availableHours: json['availableHours'] as String?,
      operatorIncluded: json['operatorIncluded'] as bool? ?? true,
      fuelIncluded: json['fuelIncluded'] as bool? ?? false,
      transportationIncluded: json['transportationIncluded'] as bool? ?? false,
      totalBookings: json['totalBookings'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      serviceImages: json['serviceImages'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'vehicleId': vehicleId,
      'providerUid': providerUid,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'pricePerService': pricePerService,
      'description': description,
      'serviceArea': serviceArea,
      'minBookingDuration': minBookingDuration,
      'isActive': isActive,
      'availableDays': availableDays,
      'availableHours': availableHours,
      'operatorIncluded': operatorIncluded,
      'fuelIncluded': fuelIncluded,
      'transportationIncluded': transportationIncluded,
      'totalBookings': totalBookings,
      'rating': rating,
      'serviceImages': serviceImages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  Service copyWith({
    String? serviceId,
    String? vehicleId,
    String? providerUid,
    String? serviceName,
    String? serviceCategory,
    double? pricePerHour,
    double? pricePerDay,
    double? pricePerService,
    String? description,
    String? serviceArea,
    String? minBookingDuration,
    bool? isActive,
    String? availableDays,
    String? availableHours,
    bool? operatorIncluded,
    bool? fuelIncluded,
    bool? transportationIncluded,
    int? totalBookings,
    double? rating,
    String? serviceImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      serviceId: serviceId ?? this.serviceId,
      vehicleId: vehicleId ?? this.vehicleId,
      providerUid: providerUid ?? this.providerUid,
      serviceName: serviceName ?? this.serviceName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pricePerService: pricePerService ?? this.pricePerService,
      description: description ?? this.description,
      serviceArea: serviceArea ?? this.serviceArea,
      minBookingDuration: minBookingDuration ?? this.minBookingDuration,
      isActive: isActive ?? this.isActive,
      availableDays: availableDays ?? this.availableDays,
      availableHours: availableHours ?? this.availableHours,
      operatorIncluded: operatorIncluded ?? this.operatorIncluded,
      fuelIncluded: fuelIncluded ?? this.fuelIncluded,
      transportationIncluded: transportationIncluded ?? this.transportationIncluded,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      serviceImages: serviceImages ?? this.serviceImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get price display
  String get priceDisplay {
    if (pricePerHour != null) {
      return 'PKR ${pricePerHour!.toStringAsFixed(0)}/hour';
    } else if (pricePerDay != null) {
      return 'PKR ${pricePerDay!.toStringAsFixed(0)}/day';
    } else if (pricePerService != null) {
      return 'PKR ${pricePerService!.toStringAsFixed(0)}/service';
    }
    return 'Price not set';
  }

  // Get status display
  String get statusDisplay => isActive ? 'Active' : 'Inactive';
}
