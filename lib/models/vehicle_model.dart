class Vehicle {
  final String id;
  final String vehicleType;
  final String vehicleName;
  final String make;
  final String model;
  final int year;
  final String registrationNumber;
  final String condition;
  final String capacity;
  final double pricePerHour;
  final bool hasInsurance;
  final bool isAvailable;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vehicleType,
    required this.vehicleName,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNumber,
    required this.condition,
    required this.capacity,
    required this.pricePerHour,
    required this.hasInsurance,
    required this.isAvailable,
    this.images = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method
  Vehicle copyWith({
    String? id,
    String? vehicleType,
    String? vehicleName,
    String? make,
    String? model,
    int? year,
    String? registrationNumber,
    String? condition,
    String? capacity,
    double? pricePerHour,
    bool? hasInsurance,
    bool? isAvailable,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      condition: condition ?? this.condition,
      capacity: capacity ?? this.capacity,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      isAvailable: isAvailable ?? this.isAvailable,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'vehicleName': vehicleName,
      'make': make,
      'model': model,
      'year': year,
      'registrationNumber': registrationNumber,
      'condition': condition,
      'capacity': capacity,
      'pricePerHour': pricePerHour,
      'hasInsurance': hasInsurance,
      'isAvailable': isAvailable,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // From JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleType: json['vehicleType'],
      vehicleName: json['vehicleName'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      registrationNumber: json['registrationNumber'],
      condition: json['condition'],
      capacity: json['capacity'],
      pricePerHour: json['pricePerHour'].toDouble(),
      hasInsurance: json['hasInsurance'],
      isAvailable: json['isAvailable'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Get display name
  String get displayName => '$vehicleName ($vehicleType)';

  // Get short description
  String get shortDescription => '$make $model - $year';
}
