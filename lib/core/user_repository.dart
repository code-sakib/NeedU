import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

/// Repository class for managing user data operations with Firestore and local storage
class UserRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');

  /// Create a new user document in Firestore
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> createUser(UserModel user) async {
    try {
      final docRef = _usersCollection.doc(user.uid);
      await docRef.set(user.toFirestore());
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to create user: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error creating user: $e',
        originalError: e,
      );
    }
  }

  /// Get user data from Firestore
  /// Returns null if user doesn't exist
  /// Throws [UserRepositoryException] if operation fails
  static Future<UserModel?> getUser(String uid) async {
    try {
      final docRef = _usersCollection.doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        return null;
      }

      final data = docSnap.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return UserModel.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to get user: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error getting user: $e',
        originalError: e,
      );
    }
  }

  /// Update user data in Firestore
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> updateUser(UserModel user) async {
    try {
      final docRef = _usersCollection
          .doc(user.uid)
          .collection('data')
          .doc('profile');
      final updatedUser = user.withUpdatedTimestamp();
      await docRef.update(updatedUser.toFirestore());
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to update user: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error updating user: $e',
        originalError: e,
      );
    }
  }

  /// Check if user document exists in Firestore
  /// Throws [UserRepositoryException] if operation fails
  static Future<bool> userExists(String uid) async {
    try {
      final docRef = _usersCollection
          .doc(uid);
      final docSnap = await docRef.get();
      return docSnap.exists;
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to check user existence: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error checking user existence: $e',
        originalError: e,
      );
    }
  }

  /// Save user data to local storage (SharedPreferences)
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = user.toLocalStorage();

      for (final entry in localData.entries) {
        if (entry.value != null) {
          await prefs.setString(entry.key, entry.value.toString());
        } else {
          await prefs.remove(entry.key);
        }
      }
    } catch (e) {
      throw UserRepositoryException.storage(
        'Failed to save user locally: $e',
        originalError: e,
      );
    }
  }

  /// Get user data from local storage
  /// Returns null if no user data found locally
  /// Throws [UserRepositoryException] if operation fails
  static Future<UserModel?> getUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user data exists
      final uid = prefs.getString('user_uid');
      if (uid == null || uid.isEmpty) {
        return null;
      }

      final localData = <String, dynamic>{
        'user_uid': prefs.getString('user_uid'),
        'user_name': prefs.getString('user_name'),
        'user_email': prefs.getString('user_email'),
        'user_phone': prefs.getString('user_phone'),
        'user_emergency_contacts': prefs.getString('user_emergency_contacts'),
        'user_profile_photo': prefs.getString('user_profile_photo'),
        'user_created_at': prefs.getString('user_created_at'),
        'user_updated_at': prefs.getString('user_updated_at'),
      };

      return UserModel.fromLocalStorage(localData);
    } catch (e) {
      throw UserRepositoryException.storage(
        'Failed to get user locally: $e',
        originalError: e,
      );
    }
  }

  /// Clear user data from local storage
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> clearLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all user-related keys
      final userKeys = [
        'user_uid',
        'user_name',
        'user_email',
        'user_phone',
        'user_emergency_contacts',
        'user_profile_photo',
        'user_created_at',
        'user_updated_at',
      ];

      for (final key in userKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw UserRepositoryException.storage(
        'Failed to clear local user data: $e',
        originalError: e,
      );
    }
  }

  /// Update emergency contacts for a user
  /// Updates both Firestore and local storage
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> updateEmergencyContacts(
    String uid,
    Map<String, dynamic> contacts,
  ) async {
    try {
      // Update in Firestore
      final docRef = _usersCollection
          .doc(uid)
          .collection('data')
          .doc('profile');
      await docRef.update({
        'emergencyContacts': contacts,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update in local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_emergency_contacts', jsonEncode(contacts));
      await prefs.setString(
        'user_updated_at',
        DateTime.now().toIso8601String(),
      );
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to update emergency contacts: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error updating emergency contacts: $e',
        originalError: e,
      );
    }
  }

  /// Get emergency contacts for a user from Firestore
  /// Throws [UserRepositoryException] if operation fails
  static Future<Map<String, dynamic>> getEmergencyContacts(String uid) async {
    try {
      final docRef = _usersCollection
          .doc(uid)
          .collection('data')
          .doc('profile');
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        return {};
      }

      final data = docSnap.data();
      return Map<String, dynamic>.from(data?['emergencyContacts'] ?? {});
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to get emergency contacts: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw UserRepositoryException.unknown(
        'Unexpected error getting emergency contacts: $e',
        originalError: e,
      );
    }
  }

  /// Upload profile photo to Firebase Storage and return download URL
  /// Throws [UserRepositoryException] if operation fails
  static Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      // Validate file
      if (!imageFile.existsSync()) {
        throw UserRepositoryException.validation('Image file does not exist');
      }

      // Check file size (limit to 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw UserRepositoryException.validation(
          'Image file size must be less than 5MB',
        );
      }

      // Upload to Firebase Storage
      final ref = _storage.ref().child('users/$uid/profile/profile_photo.jpg');
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw UserRepositoryException.storage(
        'Failed to upload profile photo: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is UserRepositoryException) rethrow;
      throw UserRepositoryException.unknown(
        'Unexpected error uploading profile photo: $e',
        originalError: e,
      );
    }
  }

  /// Update user profile (name and/or profile photo URL)
  /// Throws [UserRepositoryException] if operation fails
  static Future<void> updateProfile(
    String uid, {
    String? name,
    String? photoUrl,
  }) async {
    try {
      if (name == null && photoUrl == null) {
        throw UserRepositoryException.validation(
          'At least one field (name or photoUrl) must be provided',
        );
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) {
        final trimmedName = name.trim();
        if (trimmedName.isEmpty) {
          throw UserRepositoryException.validation('Name cannot be empty');
        }
        updateData['name'] = trimmedName;
      }

      if (photoUrl != null) {
        updateData['profilePhotoUrl'] = photoUrl;
      }

      // Update in Firestore
      final docRef = _usersCollection
          .doc(uid)
          .collection('data')
          .doc('profile');
      await docRef.update(updateData);

      // Update in local storage
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString('user_name', name);
      }
      if (photoUrl != null) {
        await prefs.setString('user_profile_photo', photoUrl);
      }
      await prefs.setString(
        'user_updated_at',
        DateTime.now().toIso8601String(),
      );
    } on FirebaseException catch (e) {
      throw UserRepositoryException.database(
        'Failed to update profile: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is UserRepositoryException) rethrow;
      throw UserRepositoryException.unknown(
        'Unexpected error updating profile: $e',
        originalError: e,
      );
    }
  }
}

/// Custom exception class for UserRepository operations
class UserRepositoryException implements Exception {
  final String message;
  final String userMessage;
  final UserRepositoryErrorType type;
  final dynamic originalError;

  const UserRepositoryException._({
    required this.message,
    required this.userMessage,
    required this.type,
    this.originalError,
  });

  /// Create a database-related error
  factory UserRepositoryException.database(
    String message, {
    dynamic originalError,
  }) {
    return UserRepositoryException._(
      message: message,
      userMessage:
          'Unable to sync your data. Please check your internet connection and try again.',
      type: UserRepositoryErrorType.database,
      originalError: originalError,
    );
  }

  /// Create a storage-related error
  factory UserRepositoryException.storage(
    String message, {
    dynamic originalError,
  }) {
    return UserRepositoryException._(
      message: message,
      userMessage: 'Unable to save your data locally. Please try again.',
      type: UserRepositoryErrorType.storage,
      originalError: originalError,
    );
  }

  /// Create a validation error
  factory UserRepositoryException.validation(
    String message, {
    dynamic originalError,
  }) {
    return UserRepositoryException._(
      message: message,
      userMessage: message, // Use the same message for validation errors
      type: UserRepositoryErrorType.validation,
      originalError: originalError,
    );
  }

  /// Create an unknown error
  factory UserRepositoryException.unknown(
    String message, {
    dynamic originalError,
  }) {
    return UserRepositoryException._(
      message: message,
      userMessage: 'Something went wrong. Please try again.',
      type: UserRepositoryErrorType.unknown,
      originalError: originalError,
    );
  }

  @override
  String toString() {
    return 'UserRepositoryException: $message';
  }
}

/// Types of errors that can occur in UserRepository
enum UserRepositoryErrorType { database, storage, validation, unknown }
