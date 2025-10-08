class SeekerPreferences {
  final String id;
  final String userId;
  final List<String> serviceCategories;
  final Map<String, List<String>> categoryDetails;
  final Map<String, ServiceRequirement> serviceRequirements;
  final String primaryPurpose;
  final String urgency; // immediate, within_week, within_month, flexible
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SeekerPreferences({
    required this.id,
    required this.userId,
    required this.serviceCategories,
    required this.categoryDetails,
    required this.serviceRequirements,
    required this.primaryPurpose,
    required this.urgency,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method
  SeekerPreferences copyWith({
    String? id,
    String? userId,
    List<String>? serviceCategories,
    Map<String, List<String>>? categoryDetails,
    Map<String, ServiceRequirement>? serviceRequirements,
    String? primaryPurpose,
    String? urgency,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeekerPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      categoryDetails: categoryDetails ?? this.categoryDetails,
      serviceRequirements: serviceRequirements ?? this.serviceRequirements,
      primaryPurpose: primaryPurpose ?? this.primaryPurpose,
      urgency: urgency ?? this.urgency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceCategories': serviceCategories,
      'categoryDetails': categoryDetails,
      'serviceRequirements': serviceRequirements.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'primaryPurpose': primaryPurpose,
      'urgency': urgency,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SeekerPreferences.fromJson(Map<String, dynamic> json) {
    return SeekerPreferences(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      serviceCategories: List<String>.from(json['serviceCategories'] ?? []),
      categoryDetails: Map<String, List<String>>.from(
        (json['categoryDetails'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ),
      ),
      serviceRequirements: (json['serviceRequirements'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, ServiceRequirement.fromJson(value)),
      ) ?? {},
      primaryPurpose: json['primaryPurpose'] ?? '',
      urgency: json['urgency'] ?? 'flexible',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Create empty preferences
  factory SeekerPreferences.empty() {
    return SeekerPreferences(
      id: '',
      userId: '',
      serviceCategories: [],
      categoryDetails: {},
      serviceRequirements: {},
      primaryPurpose: '',
      urgency: 'flexible',
      notes: '',
    );
  }
}

// Service requirement details
class ServiceRequirement {
  final String category;
  final String? quantity; // e.g., "50 acres", "10 trolleys", "5 days"
  final String? duration; // e.g., "1 day", "1 week", "1 month"
  final String? frequency; // one-time, weekly, monthly, seasonal
  final Map<String, String> additionalDetails; // category-specific details

  ServiceRequirement({
    required this.category,
    this.quantity,
    this.duration,
    this.frequency,
    this.additionalDetails = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'quantity': quantity,
      'duration': duration,
      'frequency': frequency,
      'additionalDetails': additionalDetails,
    };
  }

  factory ServiceRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceRequirement(
      category: json['category'] ?? '',
      quantity: json['quantity'],
      duration: json['duration'],
      frequency: json['frequency'],
      additionalDetails: Map<String, String>.from(json['additionalDetails'] ?? {}),
    );
  }

  ServiceRequirement copyWith({
    String? category,
    String? quantity,
    String? duration,
    String? frequency,
    Map<String, String>? additionalDetails,
  }) {
    return ServiceRequirement(
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }
}

// Service categories and their subcategories
class ServiceCategories {
  static const String agriculture = 'Agriculture';
  static const String construction = 'Construction';
  static const String logistics = 'Logistics & Transport';
  static const String emergency = 'Emergency Services';

  static const Map<String, List<String>> subcategories = {
    agriculture: [
      'Harvester Services',
      'Tractor Services',
      'Plowing & Tilling',
      'Crop Spraying',
      'Rice Harvesting',
      'Wheat Harvesting',
      'Cotton Picking',
      'Sugarcane Harvesting',
    ],
    construction: [
      'Sand Trucks',
      'Brick Trucks',
      'Cement Trucks',
      'Gravel Trucks',
      'Dumper Services',
      'Excavator Services',
      'Bulldozer Services',
      'Material Transport',
    ],
    logistics: [
      'Heavy Load Transport',
      'Container Transport',
      'Goods Transport',
      'Equipment Transport',
      'Inter-city Transport',
      'Local Delivery',
    ],
    emergency: [
      'Crane Services',
      'Heavy Lifting',
      'Emergency Transport',
      'Rescue Equipment',
      'Emergency Repairs',
    ],
  };

  static List<String> getAllCategories() {
    return [agriculture, construction, logistics, emergency];
  }

  static List<String> getSubcategories(String category) {
    return subcategories[category] ?? [];
  }

  static String getCategoryIcon(String category) {
    switch (category) {
      case agriculture:
        return '🌾';
      case construction:
        return '🏗️';
      case logistics:
        return '🚛';
      case emergency:
        return '🚨';
      default:
        return '📦';
    }
  }

  // Get requirement fields for each category
  static List<RequirementField> getRequirementFields(String category) {
    switch (category) {
      case agriculture:
        return [
          RequirementField('acres', 'Land Area (Acres)', 'e.g., 50 acres', 'number'),
          RequirementField('cropType', 'Crop Type', 'e.g., Rice, Wheat, Cotton', 'text'),
          RequirementField('duration', 'Duration Needed', 'e.g., 1 day, 3 days', 'text'),
          RequirementField('season', 'Season/Time', 'e.g., Harvesting season', 'text'),
        ];
      case construction:
        return [
          RequirementField('trolleys', 'Number of Trolleys/Loads', 'e.g., 10 trolleys', 'number'),
          RequirementField('material', 'Material Type', 'e.g., Sand, Bricks, Cement', 'text'),
          RequirementField('location', 'Site Location', 'Delivery location', 'text'),
          RequirementField('duration', 'Project Duration', 'e.g., 1 week, 1 month', 'text'),
        ];
      case logistics:
        return [
          RequirementField('weight', 'Load Weight/Capacity', 'e.g., 5 tons', 'text'),
          RequirementField('distance', 'Distance', 'e.g., 50 km, Inter-city', 'text'),
          RequirementField('frequency', 'How Often', 'e.g., One-time, Weekly', 'text'),
          RequirementField('duration', 'Duration', 'e.g., 1 day, ongoing', 'text'),
        ];
      case emergency:
        return [
          RequirementField('craneType', 'Crane/Equipment Type', 'e.g., Mobile crane, Tower crane', 'text'),
          RequirementField('liftingCapacity', 'Lifting Capacity', 'e.g., 20 tons', 'text'),
          RequirementField('duration', 'Days Needed', 'e.g., 1 day, 5 days', 'number'),
          RequirementField('urgency', 'Urgency Level', 'e.g., Immediate, Within 24hrs', 'text'),
        ];
      default:
        return [];
    }
  }
}

// Requirement field definition
class RequirementField {
  final String key;
  final String label;
  final String hint;
  final String inputType; // text, number, date

  RequirementField(this.key, this.label, this.hint, this.inputType);
}

// Urgency levels
class UrgencyLevel {
  static const String immediate = 'Immediate (within 24 hours)';
  static const String withinWeek = 'Within a week';
  static const String withinMonth = 'Within a month';
  static const String flexible = 'Flexible/Seasonal';

  static List<String> getAllLevels() {
    return [immediate, withinWeek, withinMonth, flexible];
  }

  static String getIcon(String urgency) {
    if (urgency.contains('Immediate')) return '🔴';
    if (urgency.contains('week')) return '🟡';
    if (urgency.contains('month')) return '🟢';
    return '🔵';
  }
}

// Frequency options
class FrequencyOption {
  static const String oneTime = 'One-time service';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String seasonal = 'Seasonal';
  static const String ongoing = 'Ongoing/As needed';

  static List<String> getAllOptions() {
    return [oneTime, weekly, monthly, seasonal, ongoing];
  }
}
