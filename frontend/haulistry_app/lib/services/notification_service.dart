import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  // Initialize notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final granted = await androidImplementation?.requestNotificationsPermission();
    return granted ?? false;
  }

  // Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'haulistry_channel',
      'Haulistry Notifications',
      channelDescription: 'Notifications for Haulistry app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle navigation based on payload
    print('Notification tapped: ${response.payload}');
  }

  // Get all notifications (from local storage)
  Future<List<AppNotification>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      return notificationsJson
          .map((json) => AppNotification.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Save notification
  Future<void> saveNotification(AppNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      notificationsJson.add(jsonEncode(notification.toJson()));
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        
        final prefs = await SharedPreferences.getInstance();
        final notificationsJson = notifications
            .map((n) => jsonEncode(n.toJson()))
            .toList();
        
        await prefs.setStringList('notifications', notificationsJson);
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = updatedNotifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      await _localNotifications.cancelAll();
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  // Get notification preferences
  Future<NotificationPreferences> getPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('notification_preferences');
      
      if (prefsJson != null) {
        return NotificationPreferences.fromJson(jsonDecode(prefsJson));
      }
      
      return NotificationPreferences();
    } catch (e) {
      return NotificationPreferences();
    }
  }

  // Save notification preferences
  Future<void> savePreferences(NotificationPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'notification_preferences',
        jsonEncode(preferences.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  // Schedule notification (for reminders, etc.)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'haulistry_channel',
      'Haulistry Notifications',
      channelDescription: 'Notifications for Haulistry app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: You'll need to add timezone package for proper scheduling
    // This is a placeholder
    // await _localNotifications.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   tz.TZDateTime.from(scheduledDate, tz.local),
    //   details,
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   payload: payload,
    // );
  }
}
