class Vehicle {
  final String vehicleId;
  final String providerUid;
  final String vehicleName;
  final String vehicleType;
  final String make;
  final String model;
  final int year;
  final String registrationNumber;
  final String? capacity;
  final String condition;
  final String? vehicleImage; // Base64 image data
  final String? additionalImages; // JSON string of image array
  final bool hasInsurance;
  final String? insuranceExpiry;
  final bool isAvailable;
  final String? city;
  final String? province;
  final double? pricePerHour;
  final double? pricePerDay;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.vehicleId,
    required this.providerUid,
    required this.vehicleName,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNumber,
    this.capacity,
    this.condition = 'Good',
    this.vehicleImage,
    this.additionalImages,
    this.hasInsurance = false,
    this.insuranceExpiry,
    this.isAvailable = true,
    this.city,
    this.province,
    this.pricePerHour,
    this.pricePerDay,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Backward compatibility: use vehicleId as id
  String get id => vehicleId;

  // Copy with method
  Vehicle copyWith({
    String? vehicleId,
    String? providerUid,
    String? vehicleName,
    String? vehicleType,
    String? make,
    String? model,
    int? year,
    String? registrationNumber,
    String? capacity,
    String? condition,
    String? vehicleImage,
    String? additionalImages,
    bool? hasInsurance,
    String? insuranceExpiry,
    bool? isAvailable,
    String? city,
    String? province,
    double? pricePerHour,
    double? pricePerDay,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      providerUid: providerUid ?? this.providerUid,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleType: vehicleType ?? this.vehicleType,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      capacity: capacity ?? this.capacity,
      condition: condition ?? this.condition,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      additionalImages: additionalImages ?? this.additionalImages,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      isAvailable: isAvailable ?? this.isAvailable,
      city: city ?? this.city,
      province: province ?? this.province,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From GraphQL response
  factory Vehicle.fromGraphQL(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'] as String,
      providerUid: json['providerUid'] as String,
      vehicleName: json['name'] as String,
      vehicleType: json['vehicleType'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      registrationNumber: json['registrationNumber'] as String,
      capacity: json['capacity'] as String?,
      condition: json['condition'] as String? ?? 'Good',
      vehicleImage: json['vehicleImage'] as String?,
      additionalImages: json['additionalImages'] as String?,
      hasInsurance: json['hasInsurance'] as bool? ?? false,
      insuranceExpiry: json['insuranceExpiry'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      city: json['city'] as String?,
      province: json['province'] as String?,
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // To JSON (for local storage or debugging)
  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'providerUid': providerUid,
      'name': vehicleName,
      'vehicleType': vehicleType,
      'make': make,
      'model': model,
      'year': year,
      'registrationNumber': registrationNumber,
      'capacity': capacity,
      'condition': condition,
      'vehicleImage': vehicleImage,
      'additionalImages': additionalImages,
      'hasInsurance': hasInsurance,
      'insuranceExpiry': insuranceExpiry,
      'isAvailable': isAvailable,
      'city': city,
      'province': province,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get display name
  String get displayName => '$vehicleName ($vehicleType)';

  // Get short description
  String get shortDescription => '$make $model - $year';
  
  // Get price display
  String get priceDisplay {
    if (pricePerHour != null) {
      return 'PKR ${pricePerHour!.toStringAsFixed(0)}/hour';
    } else if (pricePerDay != null) {
      return 'PKR ${pricePerDay!.toStringAsFixed(0)}/day';
    }
    return 'Price not set';
  }
}
