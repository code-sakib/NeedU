// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:fj2/utilis&configs/globals.dart';
import 'package:fj2/utilis&configs/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectedContacts {
  Map<String, dynamic> toJson(Contact contact) {
    return {
      'name': contact.displayName,
      'phoneNumber': contact.phones?.first.value,
      'inCircle': contact.avatar ?? contact.initials()
    };
  }

  Contact fromJson(Map contact) {
    String pN = contact['phoneNumber'];
    return Contact(
      displayName: contact['name'],
      phones: [Item(value: pN)],
      avatar: contact['inCircle'].runtimeType == Uint8List
          ? contact['inCircle']
          : null,
    );
  }

  static Future<void> isPermitted() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> thisContacts = await ContactsService.getContacts();
      allContacts.addAll(thisContacts.toList());
    } else {
      AppSnackBar.showSnackBar('Contacts permission denied', colorGreen: false);
    }
  }
}
