import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  // Creating an instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin localFlutterNotifications =
      FlutterLocalNotificationsPlugin();

  // Asynchronous method to initialize local notifications
  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('logo');

    // iOS initialization settings for local notifications
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );

    // Combining Android and iOS initialization settings
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initializing FlutterLocalNotificationsPlugin with the settings
    await localFlutterNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {},
    );
  }

  // Method to define notification details for both Android and iOS
  NotificationDetails NotificationBody() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Asynchronous method to show a local notification
  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return localFlutterNotifications.show(
      id,
      title,
      body,
      await NotificationBody(),
    );
  }
}
