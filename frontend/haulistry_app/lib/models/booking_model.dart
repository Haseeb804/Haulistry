class BookingModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final double totalPrice;
  final String status;
  final String? notes;
  final String? cancellationReason;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.cancellationReason,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      providerName: json['providerName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerName': providerName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'totalPrice': totalPrice,
      'status': status,
      'notes': notes,
      'cancellationReason': cancellationReason,
    };
  }

  BookingModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? providerName,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    double? totalPrice,
    String? status,
    String? notes,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerName: providerName ?? this.providerName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
