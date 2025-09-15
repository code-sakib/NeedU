import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needu/core/app_error.dart';

/// Clean authentication service with proper error handling and interfaces
/// 
/// This service provides methods for email/password authentication, Google sign-in,
/// phone authentication, and user session management with comprehensive error handling.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Private constructor to prevent instantiation
  AuthService._();

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current authenticated user
  static User? get currentUser => _auth.currentUser;

  /// Sign up with email and password
  /// 
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<User> signUpWithEmail(String email, String password) async {
    // Validate inputs first
    if (email.isEmpty || password.isEmpty) {
      throw AppError.validation('email', 'Email and password are required');
    }

    if (password.length < 6) {
      throw AppError.validation('password', 'Password must be at least 6 characters');
    }

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user == null) {
        throw AppError.authentication('Failed to create user account');
      }

      return result.user!;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Sign up failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred during sign up',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sign in with email and password
  /// 
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<User> signInWithEmail(String email, String password) async {
    // Validate inputs first
    if (email.isEmpty || password.isEmpty) {
      throw AppError.validation('email', 'Email and password are required');
    }

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user == null) {
        throw AppError.authentication('Failed to sign in');
      }

      return result.user!;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Sign in failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred during sign in',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sign in with Google
  /// 
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<User> signInWithGoogle() async {
    try {
      // Use your working implementation
      final GoogleSignInAccount gUser = await GoogleSignIn.instance.authenticate();
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential (using only idToken as in your implementation)
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user == null) {
        throw AppError.authentication('Failed to sign in with Google');
      }

      return result.user!;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Google sign in failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred during Google sign in',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Send OTP to phone number
  /// 
  /// Returns a [Completer] that completes with verification ID when code is sent
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<String> sendOTP(String phoneNumber) async {
    // Validate input first
    if (phoneNumber.isEmpty) {
      throw AppError.validation('phone', 'Phone number is required');
    }

    try {
      // Format phone number to ensure it starts with country code
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        // Assume US number if no country code provided
        formattedPhone = '+1$formattedPhone';
      }

      final Completer<String> completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(AppError.authentication(
                'Auto-verification failed',
                originalError: e,
              ));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(AppError.authentication(
              e.message ?? 'Phone verification failed',
              code: e.code,
              originalError: e,
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Failed to send OTP',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred while sending OTP',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Verify OTP with verification ID
  /// 
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<User> verifyOTP(String verificationId, String smsCode) async {
    // Validate inputs first
    if (verificationId.isEmpty || smsCode.isEmpty) {
      throw AppError.validation('otp', 'Verification ID and SMS code are required');
    }

    if (smsCode.length != 6) {
      throw AppError.validation('otp', 'SMS code must be 6 digits');
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user == null) {
        throw AppError.authentication('Failed to verify OTP');
      }

      return result.user!;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'OTP verification failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred during OTP verification',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sign out current user
  /// 
  /// Throws [AppError] with appropriate error type and user-friendly message
  static Future<void> signOut() async {
    try {
      // Sign out from Google Sign In first (gracefully)
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        // Ignore Google sign out errors - continue with Firebase sign out
        debugPrint('Google sign out error (ignored): $e');
      }
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to sign out',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if user is currently signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Get current user's UID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user's email
  static String? get currentUserEmail => _auth.currentUser?.email;

  /// Get current user's phone number
  static String? get currentUserPhone => _auth.currentUser?.phoneNumber;

  /// Reload current user data
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to reload user data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    // Validate input first
    if (email.isEmpty) {
      throw AppError.validation('email', 'Email is required');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Failed to send password reset email',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred while sending password reset email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update user's email
  static Future<void> updateEmail(String newEmail) async {
    // Validate input first
    if (newEmail.isEmpty) {
      throw AppError.validation('email', 'Email is required');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw AppError.authentication('No user is currently signed in');
    }

    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Failed to update email',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred while updating email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update user's password
  static Future<void> updatePassword(String newPassword) async {
    // Validate input first
    if (newPassword.isEmpty) {
      throw AppError.validation('password', 'Password is required');
    }

    if (newPassword.length < 6) {
      throw AppError.validation('password', 'Password must be at least 6 characters');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw AppError.authentication('No user is currently signed in');
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Failed to update password',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Don't catch AppError - let validation errors pass through
      if (e is AppError) rethrow;
      
      throw AppError.authentication(
        'An unexpected error occurred while updating password',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete current user account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppError.authentication('No user is currently signed in');
      }

      await user.delete();
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AppError.authentication(
        e.message ?? 'Failed to delete account',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'An unexpected error occurred while deleting account',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}