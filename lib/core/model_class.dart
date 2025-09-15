import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser {
  late String uid;
  late String? name;
  late String? email;
  late String? phoneNumber;
  late ValueNotifier<Map<String, dynamic>?> emergencyContacts;
  late String? profilePhotoUrl;
  final User? currentUser;
  DateTime? createdAt;

  CurrentUser(this.currentUser) {
    uid = currentUser!.uid;
    name = currentUser?.displayName;
    email = currentUser?.email;
    phoneNumber = currentUser?.phoneNumber;
    emergencyContacts = ValueNotifier({});
    profilePhotoUrl = currentUser?.photoURL;
    createdAt = DateTime.now();
  } 

  /// Convert CurrentUser to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'emergencyContacts': emergencyContacts.value,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
    };
  }

  fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    name = map['name'] ?? null;
    profilePhotoUrl = map['profilePhotoUrl'] ?? null;
    emergencyContacts.value = map['emergencyContacts'] ?? {};
    phoneNumber = map['phoneNumber'] ?? '';
    createdAt = (map['createdAt'] as Timestamp?)?.toDate();

  }

   Future<void> saveToLocal(CurrentUser? user) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('uid', user?.uid ?? '');
      prefs.setString('email', user?.email ?? '');
      prefs.setString('name', user?.name ?? '');
      prefs.setString('phoneNumber', user?.phoneNumber ?? '');
      prefs.setString('profilePhotoUrl', user?.profilePhotoUrl ?? '');
      prefs.setString(
        'emergencyContacts',
        jsonEncode(user?.emergencyContacts.value ?? {}),
      );
    });
  }

  Future<void> updateEmergencyContacts(Map? updatedMap) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('emergencyContacts', jsonEncode(updatedMap ?? {}));
    });
  }

  //static because currentUser won't be reintialized again when user directly lands on sos_page so to load all data of user from local storage, if internet is connected the imp datas like emergency contacts will be fetched fresh from firestore
  static void getFromLocal() {
    SharedPreferences.getInstance().then((prefs) {
      String uid = prefs.getString('uid') ?? '';
      String email = prefs.getString('email') ?? '';
      String name = prefs.getString('name') ?? '';
      String phoneNumber = prefs.getString('phoneNumber') ?? '';
      String profilePhotoUrl = prefs.getString('profilePhotoUrl') ?? '';
      String emergencyContacts = prefs.getString('emergencyContacts') ?? '{}';

      if (kDebugMode) {
        print('Local Storage Data:');
        print('UID: $uid');
        print('Email: $email');
        print('Name: $name');
        print('Phone Number: $phoneNumber');
        print('Profile Photo URL: $profilePhotoUrl');
        print('Emergency Contacts: $emergencyContacts');
      }
    });
  }
}
