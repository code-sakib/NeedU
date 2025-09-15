// Example usage of UserModel - This file can be deleted after integration
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

/// Example demonstrating UserModel usage
class UserModelExample {
  
  /// Example: Creating a new user
  static UserModel createNewUser(String uid, String name, String email) {
    return UserModel.create(
      uid: uid,
      name: name,
      email: email,
      emergencyContacts: {},
    );
  }

  /// Example: Saving user to Firestore
  static Future<void> saveUserToFirestore(UserModel user) async {
    final firestore = FirebaseFirestore.instance;
    final userData = user.toFirestore();
    
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('data')
        .doc('profile')
        .set(userData);
  }

  /// Example: Loading user from Firestore
  static Future<UserModel?> loadUserFromFirestore(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('data')
          .doc('profile')
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error loading user from Firestore: $e');
      return null;
    }
  }

  /// Example: Saving user to local storage
  static Future<void> saveUserToLocalStorage(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = user.toLocalStorage();
    
    for (final entry in userData.entries) {
      if (entry.value != null) {
        await prefs.setString(entry.key, entry.value.toString());
      }
    }
  }

  /// Example: Loading user from local storage
  static Future<UserModel?> loadUserFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [
        'user_uid', 'user_name', 'user_email', 'user_phone',
        'user_emergency_contacts', 'user_profile_photo',
        'user_created_at', 'user_updated_at'
      ];
      
      final userData = <String, dynamic>{};
      for (final key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          userData[key] = value;
        }
      }
      
      if (userData.isNotEmpty && userData.containsKey('user_uid')) {
        return UserModel.fromLocalStorage(userData);
      }
      return null;
    } catch (e) {
      print('Error loading user from local storage: $e');
      return null;
    }
  }

  /// Example: Updating user profile
  static UserModel updateUserProfile(UserModel user, {
    String? newName,
    String? newEmail,
    String? newPhoneNumber,
    String? newProfilePhotoUrl,
    Map<String, dynamic>? newEmergencyContacts,
  }) {
    return user.copyWith(
      name: newName,
      email: newEmail,
      phoneNumber: newPhoneNumber,
      profilePhotoUrl: newProfilePhotoUrl,
      emergencyContacts: newEmergencyContacts,
    ).withUpdatedTimestamp();
  }

  /// Example: Data synchronization pattern
  static Future<UserModel?> syncUserData(String uid) async {
    // Try to load from local storage first
    UserModel? localUser = await loadUserFromLocalStorage();
    
    // Try to load from Firestore
    UserModel? cloudUser = await loadUserFromFirestore(uid);
    
    // Use cloud data as source of truth if available
    if (cloudUser != null) {
      // Save to local storage for offline access
      await saveUserToLocalStorage(cloudUser);
      return cloudUser;
    }
    
    // Fall back to local data if cloud is unavailable
    return localUser;
  }
}