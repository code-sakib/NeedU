import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudDB {
  /// Checking whether the user document already exists in Firestore
  static Future<bool> isUserAlreadyCreated() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid);
    final docSnap = await docRef.get();

    return docSnap.exists;
  }

  /// Create initial user doc only if it doesn't exist
  static Future<void> isNewUser() async {
    tryCatch(() async {
      if (await isUserAlreadyCreated()) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid)
          .set(thisUser!.toMap());

      thisUser!.saveToLocal(thisUser);
      ;

      print("✅ User document created successfully!");
    });
  }

  // /// Fetch user data if needed later
  // static Future<void> fetchUserData() async {
  //   tryCatch(() async {
  //     await isUserAlreadyCreated() ? null : await is();
  //   });
  // }

  static Future<void> loadLocalContacts() async {
    tryCatch(() async {
      await SharedPreferences.getInstance().then((prefs) {
        final emergencyContactsStr = prefs.getString('emergencyContacts');
        if (emergencyContactsStr != null) {
          final Map<String, dynamic>? emergencyContacts =
              jsonDecode(emergencyContactsStr) as Map<String, dynamic>;
          thisUser?.emergencyContacts.value = emergencyContacts;
        }
      });
      // if (auth.currentUser?.emergencyContacts.value != null) return;

      // final docRef = FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(auth.currentUser?.uid);
      // final docSnap = await docRef.get();

      // if (docSnap.exists) {
      //   auth.currentUser?.emergencyContacts.value = docSnap['emergencyContacts'];
      // } else {
      //   print("⚠️ No user data found for ${auth.currentUser?.uid}");
      // }
    });
  }

  static void fetchCloudContacts() {
    print('in fetchCloudContacts');
    tryCatch(() async {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        thisUser?.emergencyContacts.value != docSnap['emergencyContacts']
            ? thisUser?.emergencyContacts.value = docSnap['emergencyContacts']
            : null;
      }
    });
  }

  static Future<void> updateEmergencyContacts(
    Map<String, dynamic> newContacts,
  ) async {
    tryCatch(() async {
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid)
          .update({'emergencyContacts': newContacts});

      await thisUser?.updateEmergencyContacts(newContacts);

      print("✅ Emergency contacts updated for ${auth.currentUser?.uid}");
    });
  }

  static Future<void> updateNameAndDP(File? imageFile, String name) async {
    tryCatch(() async {
      {
        String? imgUrl;
        final uid = auth.currentUser?.uid;

        // 1. Upload to Firebase Storage (if new image selected)
        if (imageFile != null) {
          final ref = FirebaseStorage.instance.ref().child(
            'users/$uid/dp/profile_pic.jpg',
          ); // store dp as profile_pic.jpg

          await ref.putFile(imageFile);

          // 2. Get download URL
          imgUrl = await ref.getDownloadURL();
        }

        // 3. Update Firestore with name and image url (if uploaded)
        final updateData = <String, dynamic>{'name': name};

        if (imgUrl != null) {
          updateData['profilePicUrl'] = imgUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updateData);

        print("✅ Profile updated for $uid");
      }
    });
  }

  //Phone Auth
  static String? fetchedVerificationId;
  static String? smsCode;
  static Future<void> otpSending(String pNumber, BuildContext context) async {
    tryCatch(() async {
      Utilis.showSnackBar('Sending to $pNumber');
      await auth.verifyPhoneNumber(
        phoneNumber: pNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This is called automatically on some devices (auto-verification)
          // await auth.signInWithCredential(credential);
          // print("Auto signed in");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          fetchedVerificationId = verificationId;
          print("Code sent. VerificationId: $verificationId");
          Utilis.showSnackBar('OTP sent successfully, please enter it.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          fetchedVerificationId = verificationId;
          print("Auto retrieval timeout. VerificationId: $verificationId");
        },
      );
    });
  }

  static Future<bool> otpVerifying(String smsCode) async {
    tryCatch(() async {
      if (fetchedVerificationId == null || fetchedVerificationId!.isEmpty) {
        print("Error: No verificationId saved.");
        return false;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: fetchedVerificationId!,
        smsCode: smsCode,
      );
    });
    return true;
  }

  /// A reusable try-catch wrapper
  static void tryCatch(Function() f) async {
    try {
      Utilis.showLoading(true);
      await f();
      Utilis.showLoading(false);
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
