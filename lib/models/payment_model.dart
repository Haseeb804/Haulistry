class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank', 'mobile_wallet'
  final String name;
  final String last4;
  final String expiryDate;
  final String cardBrand; // 'visa', 'mastercard', 'amex'
  final bool isDefault;
  final String? bankName;
  final String? accountNumber;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.last4,
    this.expiryDate = '',
    this.cardBrand = '',
    this.isDefault = false,
    this.bankName,
    this.accountNumber,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? 'card',
      name: json['name'] ?? '',
      last4: json['last4'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cardBrand: json['cardBrand'] ?? '',
      isDefault: json['isDefault'] ?? false,
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'last4': last4,
      'expiryDate': expiryDate,
      'cardBrand': cardBrand,
      'isDefault': isDefault,
      'bankName': bankName,
      'accountNumber': accountNumber,
    };
  }
}

class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final String status; // 'pending', 'processing', 'completed', 'failed', 'refunded'
  final String paymentMethod;
  final String paymentMethodId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? receiptUrl;
  final String? failureReason;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    this.currency = 'PKR',
    required this.status,
    required this.paymentMethod,
    required this.paymentMethodId,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.receiptUrl,
    this.failureReason,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'PKR',
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentMethodId: json['paymentMethodId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionId: json['transactionId'],
      receiptUrl: json['receiptUrl'],
      failureReason: json['failureReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentMethodId': paymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
      'failureReason': failureReason,
    };
  }
}

class PaymentIntent {
  final String id;
  final double amount;
  final String currency;
  final String clientSecret;
  final String status;

  PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.clientSecret,
    required this.status,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'PKR',
      clientSecret: json['clientSecret'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
