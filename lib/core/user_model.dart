import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Clean user data model with proper serialization for both Firestore and local storage
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final Map<String, dynamic> emergencyContacts;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.emergencyContacts = const {},
    this.profilePhotoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel with validation
  factory UserModel.create({
    required String uid,
    String? name,
    String? email,
    String? phoneNumber,
    Map<String, dynamic>? emergencyContacts,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Trim inputs first
    final trimmedUid = uid.trim();
    final trimmedName = name?.trim();
    final trimmedEmail = email?.trim();
    final trimmedPhoneNumber = phoneNumber?.trim();
    final trimmedProfilePhotoUrl = profilePhotoUrl?.trim();

    // Validate required fields
    if (trimmedUid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }

    // Validate email format if provided
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmedEmail)) {
        throw ArgumentError('Invalid email format');
      }
    }

    // Validate phone number format if provided
    if (trimmedPhoneNumber != null && trimmedPhoneNumber.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
      if (!phoneRegex.hasMatch(trimmedPhoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        throw ArgumentError('Invalid phone number format');
      }
    }

    return UserModel(
      uid: trimmedUid,
      name: trimmedName,
      email: trimmedEmail,
      phoneNumber: trimmedPhoneNumber,
      emergencyContacts: emergencyContacts ?? {},
      profilePhotoUrl: trimmedProfilePhotoUrl,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// Convert UserModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'emergencyContacts': emergencyContacts,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create UserModel from Firestore document data
  static UserModel fromFirestore(Map<String, dynamic> data) {
    try {
      return UserModel(
        uid: data['uid'] as String? ?? '',
        name: data['name'] as String?,
        email: data['email'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        emergencyContacts: Map<String, dynamic>.from(data['emergencyContacts'] as Map? ?? {}),
        profilePhotoUrl: data['profilePhotoUrl'] as String?,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw FormatException('Failed to parse UserModel from Firestore data: $e');
    }
  }

  /// Convert UserModel to local storage format (SharedPreferences compatible)
  Map<String, dynamic> toLocalStorage() {
    return {
      'user_uid': uid,
      'user_name': name,
      'user_email': email,
      'user_phone': phoneNumber,
      'user_emergency_contacts': jsonEncode(emergencyContacts),
      'user_profile_photo': profilePhotoUrl,
      'user_created_at': createdAt.toIso8601String(),
      'user_updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create UserModel from local storage data
  static UserModel fromLocalStorage(Map<String, dynamic> data) {
    try {
      return UserModel(
        uid: data['user_uid'] as String? ?? '',
        name: data['user_name'] as String?,
        email: data['user_email'] as String?,
        phoneNumber: data['user_phone'] as String?,
        emergencyContacts: data['user_emergency_contacts'] != null
            ? Map<String, dynamic>.from(jsonDecode(data['user_emergency_contacts'] as String))
            : {},
        profilePhotoUrl: data['user_profile_photo'] as String?,
        createdAt: data['user_created_at'] != null
            ? DateTime.parse(data['user_created_at'] as String)
            : DateTime.now(),
        updatedAt: data['user_updated_at'] != null
            ? DateTime.parse(data['user_updated_at'] as String)
            : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse UserModel from local storage data: $e');
    }
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    Map<String, dynamic>? emergencyContacts,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Update the updatedAt timestamp
  UserModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Check if user has complete profile information
  bool get hasCompleteProfile {
    return name != null && 
           name!.isNotEmpty && 
           (email != null && email!.isNotEmpty || phoneNumber != null && phoneNumber!.isNotEmpty);
  }

  /// Check if user has emergency contacts
  bool get hasEmergencyContacts {
    return emergencyContacts.isNotEmpty;
  }

  /// Get display name (name or email or phone or uid)
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber!;
    return uid;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        _mapEquals(other.emergencyContacts, emergencyContacts) &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      name,
      email,
      phoneNumber,
      emergencyContacts,
      profilePhotoUrl,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, phoneNumber: $phoneNumber, '
           'emergencyContacts: $emergencyContacts, profilePhotoUrl: $profilePhotoUrl, '
           'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// Helper method to compare maps for equality
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}