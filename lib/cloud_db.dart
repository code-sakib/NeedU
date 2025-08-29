import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/core/model_class.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudDB {
  /// Checking whether the user document already exists in Firestore
  static Future<bool> isUserAlreadyCreated() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    final docSnap = await docRef.get();

    return docSnap.exists;
  }

  /// Create initial user doc only if it doesn't exist
  static Future<void> isNewUser() async {
    tryCatch(() async {
      if (await isUserAlreadyCreated()) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(currentUser.toMap());

      currentUser.saveToLocal(currentUser);

      print("✅ User document created successfully!");
    });
  }

  // /// Fetch user data if needed later
  // static Future<void> fetchUserData() async {
  //   tryCatch(() async {
  //     await isUserAlreadyCreated() ? null : await is();
  //   });
  // }

  static Future<void> fetchEmergencyContacts() async {
    tryCatch(() async {
      await SharedPreferences.getInstance().then((prefs) {
        final emergencyContactsStr = prefs.getString('emergencyContacts');
        if (emergencyContactsStr != null) {
          final Map<String, dynamic> emergencyContacts =
              jsonDecode(emergencyContactsStr) as Map<String, dynamic>;
          currentUser.emergencyContacts = emergencyContacts;
        }
      });

      if (currentUser.emergencyContacts != null) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        currentUser.emergencyContacts = docSnap['emergencyContacts'];
      } else {
        print("⚠️ No user data found for ${currentUser.uid}");
      }
    });
  }

  static Future<void> updateEmergencyContacts(
    Map<String, dynamic> newContacts,
  ) async {
    tryCatch(() async {
      // Update locally
      currentUser.emergencyContacts = newContacts;

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'emergencyContacts': newContacts});

      print("✅ Emergency contacts updated for ${currentUser.uid}");
    });
  }

  /// A reusable try-catch wrapper
  static void tryCatch(Function() f) async {
    try {
      await f();
    } on FirebaseAuthException catch (e) {
      Utilis.showSnackBar('${e.code}: ${e.message}', isErr: true);
      // print("Auth Err: ${e.code} - ${e.message}");
    } on FirebaseException catch (e) {
      Utilis.showSnackBar('${e.code}: ${e.message}', isErr: true);
      // print("Server Err: ${e.code} - ${e.message}");
    } catch (e) {
      Utilis.showSnackBar(e.toString(), isErr: true);
    }
  }
}
