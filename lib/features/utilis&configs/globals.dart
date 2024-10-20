import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Contact> selectedContacts = [];
ValueNotifier<int> toBuildSList = ValueNotifier(0);
final List<Contact> allContacts = [];

late final SharedPreferences sharedPref;

bool isSendSmsPermitted = false;
