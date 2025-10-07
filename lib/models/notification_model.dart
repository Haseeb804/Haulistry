class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'booking', 'payment', 'message', 'system'
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'],
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'actionUrl': actionUrl,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

class NotificationPreferences {
  final bool bookingUpdates;
  final bool paymentAlerts;
  final bool messageNotifications;
  final bool promotions;
  final bool systemUpdates;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationPreferences({
    this.bookingUpdates = true,
    this.paymentAlerts = true,
    this.messageNotifications = true,
    this.promotions = false,
    this.systemUpdates = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      bookingUpdates: json['bookingUpdates'] ?? true,
      paymentAlerts: json['paymentAlerts'] ?? true,
      messageNotifications: json['messageNotifications'] ?? true,
      promotions: json['promotions'] ?? false,
      systemUpdates: json['systemUpdates'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingUpdates': bookingUpdates,
      'paymentAlerts': paymentAlerts,
      'messageNotifications': messageNotifications,
      'promotions': promotions,
      'systemUpdates': systemUpdates,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? bookingUpdates,
    bool? paymentAlerts,
    bool? messageNotifications,
    bool? promotions,
    bool? systemUpdates,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      bookingUpdates: bookingUpdates ?? this.bookingUpdates,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      promotions: promotions ?? this.promotions,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
