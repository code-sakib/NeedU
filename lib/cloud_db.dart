import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/globals.dart';
import 'package:needu/utilis/snackbar.dart';

class CloudDB {
  static Future<void> userInitialDBSetup() async {
    try {
      final User? user = auth.currentUser;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) return;

      await cloudDB.collection('users').doc(user?.uid).set({
        'name': auth.currentUser?.displayName,
        'profilePhotoUrl': auth.currentUser?.photoURL,
        'emergencyContacts': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ User document created successfully!");
    } on FirebaseAuthException catch (e) {
      Utilis.showSnackBar('${e.code} - ${e.message}', isErr: true);
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      rethrow;
    } on FirebaseException catch (e) {
      Utilis.showSnackBar('${e.code} - ${e.message}', isErr: true);
      print("❌ FirebaseFirestoreException: ${e.code} - ${e.message}");
      rethrow;
    }
  }
}
