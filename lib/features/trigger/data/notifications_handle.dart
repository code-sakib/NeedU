import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsHandle {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initializeNotifications() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_stat_name');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  /// Displays a persistent notification with action buttons.
  static Future<void> showPersistentNotification() async {
    // Android-specific notification details
    var androidDetails = const AndroidNotificationDetails(
      'persistent_channel_id',
      'Persistent Notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Makes the notification persistent
      autoCancel: false, // Prevents the user from dismissing it by swipe
      sound: null,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'ACTION_TRIGGER', // Action ID
          'Trigger', // Button label
          icon: DrawableResourceAndroidBitmap(
              'ic_stat_name'), // Reference the icon here (in res/drawable folder)
        ),
      ],
    );

    // Notification details for all platforms
    var notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      null,
      'Tap to trigger NeedU',
      notificationDetails,
    );
  }

  /// Handles notification action button or tap event.
  static void _onSelectNotification(NotificationResponse notificationResponse) {
    if (notificationResponse.actionId == 'ACTION_TRIGGER') {
      _triggerAction();
      print('select triggered');
    }
  }

  /// The action that is triggered by the notification button.
  static void _triggerAction() {
    // Perform your desired functionality here

    print('pressed button');
    i = true;
  }
}

bool i = false;
