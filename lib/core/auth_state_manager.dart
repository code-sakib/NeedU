import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'user_repository.dart';
import 'app_error.dart';
import 'data_sync_service.dart';

/// Enum representing different authentication states
enum AuthState {
  /// Initial state when the app is starting up
  loading,
  
  /// User is authenticated and user data is loaded
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// User is authenticated but needs to complete account setup
  needsSetup,
  
  /// An error occurred during authentication or user data loading
  error,
}

/// Global authentication state manager with static methods for user state management
/// 
/// This class manages the global user state, handles user session initialization,
/// and provides state notifications using ValueNotifier for reactive UI updates.
class AuthStateManager {
  // Private constructor to prevent instantiation
  AuthStateManager._();

  // Static fields for global state management
  static UserModel? _currentUser;
  static final ValueNotifier<AuthState> _authState = ValueNotifier(AuthState.loading);
  static final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  /// Current authenticated user
  static UserModel? get currentUser => _currentUser;

  /// Authentication state notifier for reactive UI updates
  static ValueNotifier<AuthState> get authState => _authState;

  /// Error message notifier for displaying errors in UI
  static ValueNotifier<String?> get errorMessage => _errorMessage;

  /// Check if user is currently authenticated
  static bool get isAuthenticated => _currentUser != null && _authState.value == AuthState.authenticated;

  /// Check if user needs to complete account setup
  static bool get needsSetup => _authState.value == AuthState.needsSetup;

  /// Initialize user session from Firebase User
  /// 
  /// This method should be called when Firebase Auth state changes to set up
  /// the user session by loading user data using DataSyncService for proper
  /// synchronization between local and cloud storage.
  /// 
  /// Throws [AppError] if user data loading fails
  static Future<void> initializeUser(User firebaseUser) async {
    try {
      _authState.value = AuthState.loading;
      _errorMessage.value = null;

      // Use DataSyncService to load user data with proper synchronization
      final userData = await DataSyncService.loadUserData(firebaseUser.uid);

      if (userData != null) {
        // User data exists, set up authenticated state
        _currentUser = userData;
        _authState.value = AuthState.authenticated;
      } else {
        // User data doesn't exist, create minimal user model and set needs setup state
        _currentUser = UserModel.create(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          phoneNumber: firebaseUser.phoneNumber,
          createdAt: DateTime.now(),
        );
        _authState.value = AuthState.needsSetup;
      }
    } catch (e, stackTrace) {
      _currentUser = null;
      _authState.value = AuthState.error;
      
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to initialize user session: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to load your account. Please try again.';
        throw AppError.unknown(
          'Unexpected error during user initialization: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Update the current user object and sync with storage
  /// 
  /// This method updates the global user object and saves the changes
  /// using DataSyncService for proper synchronization.
  /// 
  /// Throws [AppError] if update operations fail
  static Future<void> updateCurrentUser(UserModel user) async {
    try {
      // Validate that the user UID matches current user
      if (_currentUser?.uid != user.uid) {
        throw AppError.validation(
          'user',
          'Cannot update user: UID mismatch',
        );
      }

      // Use DataSyncService to save user data with proper synchronization
      await DataSyncService.saveUserData(user);
      
      // Update global state
      _currentUser = user;
      
      // If user was in setup state and now has complete profile, move to authenticated
      if (_authState.value == AuthState.needsSetup && user.hasCompleteProfile) {
        _authState.value = AuthState.authenticated;
      }
      
      // Clear any previous error messages
      _errorMessage.value = null;
    } catch (e, stackTrace) {
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to update user data: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to save your changes. Please try again.';
        throw AppError.unknown(
          'Unexpected error during user update: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Create user data for new users during account setup
  /// 
  /// This method creates user data using DataSyncService for proper
  /// synchronization and updates the global state to authenticated once setup is complete.
  /// 
  /// Throws [AppError] if user creation fails
  static Future<void> createUserData(UserModel user) async {
    try {
      // Use DataSyncService to save user data with proper synchronization
      await DataSyncService.saveUserData(user);
      
      // Update global state
      _currentUser = user;
      _authState.value = AuthState.authenticated;
      
      // Clear any previous error messages
      _errorMessage.value = null;
    } catch (e, stackTrace) {
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to create user account: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to create your account. Please try again.';
        throw AppError.unknown(
          'Unexpected error during user creation: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Clear user session for sign out operations
  /// 
  /// This method clears all user data from memory and local storage,
  /// and updates the authentication state to unauthenticated.
  static Future<void> clearUser() async {
    try {
      // Clear user data from local storage
      await UserRepository.clearLocalUser();
      
      // Clear global state
      _currentUser = null;
      _authState.value = AuthState.unauthenticated;
      _errorMessage.value = null;
    } catch (e) {
      // Even if clearing local storage fails, we should still clear the global state
      _currentUser = null;
      _authState.value = AuthState.unauthenticated;
      
      // Log the error but don't throw - sign out should always succeed
      debugPrint('Failed to clear local user data during sign out: $e');
      
      // Set error message for UI feedback
      _errorMessage.value = 'Signed out successfully, but failed to clear local data.';
    }
  }

  /// Handle authentication state changes from Firebase Auth
  /// 
  /// This method should be called when Firebase Auth state changes to
  /// properly initialize or clear the user session.
  static Future<void> handleAuthStateChange(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // User is signed in, initialize user session
        await initializeUser(firebaseUser);
      } else {
        // User is signed out, clear user session
        await clearUser();
      }
    } catch (e) {
      // Error handling is done in initializeUser and clearUser methods
      // Just ensure we don't crash the app
      debugPrint('Error handling auth state change: $e');
    }
  }

  /// Refresh user data using DataSyncService
  /// 
  /// This method refreshes the current user data using DataSyncService
  /// for proper synchronization and updates the global state.
  /// 
  /// Throws [AppError] if refresh operation fails
  static Future<void> refreshUserData() async {
    if (_currentUser == null) {
      throw AppError.authentication('No user is currently signed in');
    }

    try {
      // Force sync user data from cloud
      final userData = await DataSyncService.forceSyncUserData(_currentUser!.uid);
      
      if (userData != null) {
        // Update global state
        _currentUser = userData;
        
        // Update auth state if needed
        if (_authState.value == AuthState.needsSetup && userData.hasCompleteProfile) {
          _authState.value = AuthState.authenticated;
        }
        
        // Clear any previous error messages
        _errorMessage.value = null;
      } else {
        // User data was deleted from Firestore
        throw AppError.authentication('User account no longer exists');
      }
    } catch (e, stackTrace) {
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to refresh user data: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to refresh your data. Please try again.';
        throw AppError.unknown(
          'Unexpected error during user data refresh: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Update emergency contacts for the current user
  /// 
  /// This method updates emergency contacts using DataSyncService for proper
  /// synchronization and refreshes the global user state.
  /// 
  /// Throws [AppError] if update operation fails
  static Future<void> updateEmergencyContacts(Map<String, dynamic> contacts) async {
    if (_currentUser == null) {
      throw AppError.authentication('No user is currently signed in');
    }

    try {
      // Update emergency contacts using DataSyncService
      await DataSyncService.updateEmergencyContacts(_currentUser!.uid, contacts);
      
      // Update the current user object
      _currentUser = _currentUser!.copyWith(
        emergencyContacts: contacts,
        updatedAt: DateTime.now(),
      );
      
      // Clear any previous error messages
      _errorMessage.value = null;
    } catch (e, stackTrace) {
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to update emergency contacts: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to update emergency contacts. Please try again.';
        throw AppError.unknown(
          'Unexpected error updating emergency contacts: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Update user profile (name and/or profile photo)
  /// 
  /// This method updates the user profile and refreshes the global user state.
  /// 
  /// Throws [AppError] if update operation fails
  static Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (_currentUser == null) {
      throw AppError.authentication('No user is currently signed in');
    }

    try {
      // Update profile in repository
      await UserRepository.updateProfile(
        _currentUser!.uid,
        name: name,
        photoUrl: photoUrl,
      );
      
      // Update the current user object
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        profilePhotoUrl: photoUrl ?? _currentUser!.profilePhotoUrl,
        updatedAt: DateTime.now(),
      );
      
      // If user was in setup state and now has complete profile, move to authenticated
      if (_authState.value == AuthState.needsSetup && _currentUser!.hasCompleteProfile) {
        _authState.value = AuthState.authenticated;
      }
      
      // Clear any previous error messages
      _errorMessage.value = null;
    } catch (e, stackTrace) {
      if (e is AppError) {
        _errorMessage.value = e.userMessage;
        rethrow;
      } else if (e is UserRepositoryException) {
        _errorMessage.value = e.userMessage;
        throw AppError.database(
          'Failed to update profile: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } else {
        _errorMessage.value = 'Failed to update your profile. Please try again.';
        throw AppError.unknown(
          'Unexpected error updating profile: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Clear error message
  /// 
  /// This method clears the current error message from the state.
  static void clearError() {
    _errorMessage.value = null;
  }

  /// Dispose method for cleaning up resources
  /// 
  /// This method should be called when the app is shutting down to clean up resources.
  static void dispose() {
    _authState.dispose();
    _errorMessage.dispose();
  }
}