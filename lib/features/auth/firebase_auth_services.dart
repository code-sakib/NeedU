// firebase_auth_services.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/data_state.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/utilis/snackbar.dart'; // Assuming this is where Utilis.showSnackBar is defined

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // EMAIL & PASSWORD Sign Up (wrapped in async error handling)
  static Future<void> signUpWithEmail(String email, String password) async {
    await DataState.run(() async {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await CloudDB.userInitialDBSetup();
    });
  }

  // EMAIL & PASSWORD Sign In (wrapped in async error handling)
  static Future<void> signInWithEmail(String email, String password) async {
    await DataState.run(() async {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  // GOOGLE SIGN-IN (fixed method call and wrapped in async error handling)
  static Future<void> googleAuthenticating() async {
    await DataState.run(() async {
      final GoogleSignInAccount? gUser = await GoogleSignIn.instance.authenticate();
      if (gUser == null) return; // User cancelled sign-in

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final OAuthCredential credentials = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
      );

      await auth.signInWithCredential(credentials);
    });
  }

  // Request OTP (callbacks for success/error to allow UI handling)
  Future<void> verifyPhoneNumber({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(User user) onVerified,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCred = await _auth.signInWithCredential(credential);
          if (userCred.user != null) onVerified(userCred.user!);
        } catch (e) {
          onError(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Optional: Handle timeout if needed
      },
    );
  }

  // Verify OTP manually (returns user or null on failure)
  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } catch (e) {
      Utilis.showSnackBar("Invalid OTP: $e", isErr: true);
      return null;
    }
  }

  // LOGOUT (wrapped in async error handling)
  Future<void> signOut() async {
    await DataState.run(() async {
      await _auth.signOut();
      await GoogleSignIn.instance.signOut();
    });
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;
}