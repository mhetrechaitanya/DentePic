import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // var initializationSettingsIOS = IOSInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    //   onDidReceiveLocalNotification:
    //       (int id, String? title, String? body, String? payload) async {},
    // );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle notification response
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
    String? payload,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId', // Replace with your own channel ID
          'channelName', // Replace with your own channel name
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // Replace with your small icon
        ),
      ),
      payload: payload,
    );
  }
  Future<void> scheduleNotificationAfter2Minutes({
    required int id,
    required String? title,
    required String? body,
    String? payload,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channelId', // Replace with your own channel ID
      'channelName', // Replace with your own channel name
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Replace with your small icon
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Calculate the scheduled time as 2 minutes from now
    DateTime scheduledDate = DateTime.now().add(Duration(milliseconds: 60000));

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(scheduledDate), // Schedule at the calculated time
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime scheduledDate) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDateTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
    );
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(seconds: 1));
    }
    return scheduledDateTime;
  }
}
