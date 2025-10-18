class ServiceModel {
  final String id;
  final String providerId;
  final String providerName;
  final String serviceType;
  final String title;
  final String description;
  final double pricePerHour;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String location;
  final bool isAvailable;
  final List<String>? additionalImages;
  final Map<String, dynamic>? specifications;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.title,
    required this.description,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.location,
    required this.isAvailable,
    this.additionalImages,
    this.specifications,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pricePerHour: json['pricePerHour']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      additionalImages: json['additionalImages'] != null
          ? List<String>.from(json['additionalImages'])
          : null,
      specifications: json['specifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'serviceType': serviceType,
      'title': title,
      'description': description,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'location': location,
      'isAvailable': isAvailable,
      'additionalImages': additionalImages,
      'specifications': specifications,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? serviceType,
    String? title,
    String? description,
    double? pricePerHour,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? location,
    bool? isAvailable,
    List<String>? additionalImages,
    Map<String, dynamic>? specifications,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      additionalImages: additionalImages ?? this.additionalImages,
      specifications: specifications ?? this.specifications,
    );
  }
}
