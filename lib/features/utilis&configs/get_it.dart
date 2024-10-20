import 'package:fj2/features/trigger/data/notifications_handle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

Future<void> initializeDependencies() async {
  NotificationsHandle.initializeNotifications();
  NotificationsHandle.showPersistentNotification();

  // await SendSMS.isPermited();
  sharedPref = await SharedPreferences.getInstance();
}
