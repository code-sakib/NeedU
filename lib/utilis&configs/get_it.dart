import 'package:fj2/features/trigger/domain/contacts.dart';
import 'package:fj2/utilis&configs/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeDependencies() async {
  await SelectedContacts.isPermitted();
  // await SendSMS.isPermited();
  sharedPref = await SharedPreferences.getInstance();
}
