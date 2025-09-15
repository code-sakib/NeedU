import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'user_model.dart';
import 'user_repository.dart';
import 'app_error.dart';

/// Service for handling data synchronization between local storage and cloud storage
/// 
/// This service manages the synchronization of user data between local storage
/// (SharedPreferences) and cloud storage (Firestore), with cloud data as the
/// source of truth for conflict resolution.
class DataSyncService {
  // Private constructor to prevent instantiation
  DataSyncService._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static final ValueNotifier<bool> _isOnline = ValueNotifier(true);
  static final ValueNotifier<SyncStatus> _syncStatus = ValueNotifier(SyncStatus.idle);
  static final List<String> _pendingSyncUsers = [];

  /// Helper method to safely update sync status without causing build issues
  static void _updateSyncStatus(SyncStatus status) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're in the build phase, defer the update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncStatus.value = status;
      });
    } else {
      // Safe to update immediately
      _syncStatus.value = status;
    }
  }

  /// Helper method to safely update online status without causing build issues
  static void _updateOnlineStatus(bool isOnline) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're in the build phase, defer the update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isOnline.value = isOnline;
      });
    } else {
      // Safe to update immediately
      _isOnline.value = isOnline;
    }
  }

  /// Current online status
  static ValueNotifier<bool> get isOnline => _isOnline;

  /// Current sync status
  static ValueNotifier<SyncStatus> get syncStatus => _syncStatus;

  /// Initialize the data sync service
  /// 
  /// This method sets up connectivity monitoring and should be called
  /// during app initialization.
  static Future<void> initialize() async {
    try {
      // Check initial connectivity
      final connectivityResults = await _connectivity.checkConnectivity();
      _updateOnlineStatus(!connectivityResults.contains(ConnectivityResult.none));

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final wasOnline = _isOnline.value;
          final isOnline = !results.contains(ConnectivityResult.none);
          _updateOnlineStatus(isOnline);

          // If we just came back online, sync pending users
          if (!wasOnline && isOnline && _pendingSyncUsers.isNotEmpty) {
            _syncPendingUsers();
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize DataSyncService: $e');
      // Assume online if we can't check connectivity
      _updateOnlineStatus(true);
    }
  }

  /// Load user data with synchronization logic
  /// 
  /// This method implements the data loading strategy:
  /// 1. Load from local storage first for immediate UI response
  /// 2. If online, fetch from cloud and sync
  /// 3. Handle conflicts with cloud as source of truth
  /// 
  /// Returns the most up-to-date user data available
  static Future<UserModel?> loadUserData(String uid) async {
    try {
      _updateSyncStatus(SyncStatus.loading);

      // Step 1: Load from local storage first for immediate response
      UserModel? localUser;
      try {
        localUser = await UserRepository.getUserLocally();
        // Verify the local user matches the requested UID
        if (localUser?.uid != uid) {
          localUser = null;
        }
      } catch (e) {
        debugPrint('Failed to load user data from local storage: $e');
        localUser = null;
      }

      // Step 2: If online, fetch from cloud and sync
      if (_isOnline.value) {
        try {
          final cloudUser = await UserRepository.getUser(uid);
          
          if (cloudUser != null) {
            // Cloud data exists, use it as source of truth
            final syncedUser = await _syncUserData(localUser, cloudUser);
            _updateSyncStatus(SyncStatus.synced);
            return syncedUser;
          } else if (localUser != null) {
            // Cloud data doesn't exist but local data does
            // This could happen if user was created offline
            try {
              await UserRepository.createUser(localUser);
              _updateSyncStatus(SyncStatus.synced);
              return localUser;
            } catch (e) {
              // Failed to create in cloud, use local data
              _updateSyncStatus(SyncStatus.localOnly);
              _addToPendingSync(uid);
              return localUser;
            }
          } else {
            // No data in either location
            _updateSyncStatus(SyncStatus.synced);
            return null;
          }
        } catch (e) {
          // Cloud fetch failed, use local data if available
          if (localUser != null) {
            _updateSyncStatus(SyncStatus.localOnly);
            _addToPendingSync(uid);
            return localUser;
          } else {
            _updateSyncStatus(SyncStatus.error);
            throw AppError.database(
              'Failed to load user data: $e',
              originalError: e,
            );
          }
        }
      } else {
        // Offline, use local data
        if (localUser != null) {
          _updateSyncStatus(SyncStatus.localOnly);
          _addToPendingSync(uid);
          return localUser;
        } else {
          _updateSyncStatus(SyncStatus.error);
          throw AppError.network('No internet connection and no local data available');
        }
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      if (e is AppError) {
        rethrow;
      } else {
        throw AppError.unknown(
          'Unexpected error loading user data: $e',
          originalError: e,
        );
      }
    }
  }

  /// Sync user data between local and cloud storage
  /// 
  /// This method handles conflict resolution with cloud as source of truth
  static Future<UserModel> _syncUserData(UserModel? localUser, UserModel cloudUser) async {
    try {
      if (localUser == null) {
        // No local data, save cloud data locally
        await UserRepository.saveUserLocally(cloudUser);
        return cloudUser;
      }

      // Compare timestamps to determine which data is newer
      final localUpdated = localUser.updatedAt ?? localUser.createdAt;
      final cloudUpdated = cloudUser.updatedAt ?? cloudUser.createdAt;

      if (cloudUpdated.isAfter(localUpdated)) {
        // Cloud data is newer, update local storage
        await UserRepository.saveUserLocally(cloudUser);
        return cloudUser;
      } else if (localUpdated.isAfter(cloudUpdated)) {
        // Local data is newer, update cloud storage
        try {
          await UserRepository.updateUser(localUser);
          return localUser;
        } catch (e) {
          // Failed to update cloud, use cloud data as fallback
          debugPrint('Failed to update cloud data, using cloud as source of truth: $e');
          await UserRepository.saveUserLocally(cloudUser);
          return cloudUser;
        }
      } else {
        // Same timestamp, cloud is source of truth
        await UserRepository.saveUserLocally(cloudUser);
        return cloudUser;
      }
    } catch (e) {
      // If sync fails, return cloud data and save it locally
      try {
        await UserRepository.saveUserLocally(cloudUser);
      } catch (saveError) {
        debugPrint('Failed to save cloud data locally: $saveError');
      }
      return cloudUser;
    }
  }

  /// Save user data with synchronization
  /// 
  /// This method saves user data to both local and cloud storage,
  /// with fallback to local-only if cloud save fails
  static Future<void> saveUserData(UserModel user) async {
    try {
      _updateSyncStatus(SyncStatus.syncing);

      // Always save to local storage first
      await UserRepository.saveUserLocally(user);

      // If online, also save to cloud
      if (_isOnline.value) {
        try {
          // Check if user exists in cloud
          final exists = await UserRepository.userExists(user.uid);
          
          if (exists) {
            await UserRepository.updateUser(user);
          } else {
            await UserRepository.createUser(user);
          }
          
          _updateSyncStatus(SyncStatus.synced);
          _removeFromPendingSync(user.uid);
        } catch (e) {
          // Cloud save failed, mark for pending sync
          _updateSyncStatus(SyncStatus.localOnly);
          _addToPendingSync(user.uid);
          debugPrint('Failed to save user data to cloud: $e');
        }
      } else {
        // Offline, mark for pending sync
        _updateSyncStatus(SyncStatus.localOnly);
        _addToPendingSync(user.uid);
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      throw AppError.storage(
        'Failed to save user data: $e',
        originalError: e,
      );
    }
  }

  /// Update emergency contacts with synchronization
  /// 
  /// This method updates emergency contacts in both local and cloud storage
  static Future<void> updateEmergencyContacts(
    String uid,
    Map<String, dynamic> contacts,
  ) async {
    try {
      _updateSyncStatus(SyncStatus.syncing);

      if (_isOnline.value) {
        try {
          // Update in cloud first
          await UserRepository.updateEmergencyContacts(uid, contacts);
          _updateSyncStatus(SyncStatus.synced);
          _removeFromPendingSync(uid);
        } catch (e) {
          // Cloud update failed, update locally and mark for sync
          await _updateEmergencyContactsLocally(uid, contacts);
          _updateSyncStatus(SyncStatus.localOnly);
          _addToPendingSync(uid);
          debugPrint('Failed to update emergency contacts in cloud: $e');
        }
      } else {
        // Offline, update locally and mark for sync
        await _updateEmergencyContactsLocally(uid, contacts);
        _updateSyncStatus(SyncStatus.localOnly);
        _addToPendingSync(uid);
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      throw AppError.storage(
        'Failed to update emergency contacts: $e',
        originalError: e,
      );
    }
  }

  /// Update emergency contacts in local storage only
  static Future<void> _updateEmergencyContactsLocally(
    String uid,
    Map<String, dynamic> contacts,
  ) async {
    final localUser = await UserRepository.getUserLocally();
    if (localUser != null && localUser.uid == uid) {
      final updatedUser = localUser.copyWith(
        emergencyContacts: contacts,
        updatedAt: DateTime.now(),
      );
      await UserRepository.saveUserLocally(updatedUser);
    }
  }

  /// Force sync user data with cloud
  /// 
  /// This method forces a synchronization with cloud storage,
  /// useful for manual refresh operations
  static Future<UserModel?> forceSyncUserData(String uid) async {
    if (!_isOnline.value) {
      throw AppError.network('Cannot sync while offline');
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);

      final localUser = await UserRepository.getUserLocally();
      final cloudUser = await UserRepository.getUser(uid);

      if (cloudUser != null) {
        final syncedUser = await _syncUserData(localUser, cloudUser);
        _updateSyncStatus(SyncStatus.synced);
        _removeFromPendingSync(uid);
        return syncedUser;
      } else if (localUser != null && localUser.uid == uid) {
        // Local data exists but not in cloud, create it
        await UserRepository.createUser(localUser);
        _updateSyncStatus(SyncStatus.synced);
        _removeFromPendingSync(uid);
        return localUser;
      } else {
        _updateSyncStatus(SyncStatus.synced);
        return null;
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      throw AppError.database(
        'Failed to sync user data: $e',
        originalError: e,
      );
    }
  }

  /// Add user to pending sync list
  static void _addToPendingSync(String uid) {
    if (!_pendingSyncUsers.contains(uid)) {
      _pendingSyncUsers.add(uid);
    }
  }

  /// Remove user from pending sync list
  static void _removeFromPendingSync(String uid) {
    _pendingSyncUsers.remove(uid);
  }

  /// Sync all pending users when connectivity is restored
  static Future<void> _syncPendingUsers() async {
    if (_pendingSyncUsers.isEmpty || !_isOnline.value) {
      return;
    }

    final usersToSync = List<String>.from(_pendingSyncUsers);
    
    for (final uid in usersToSync) {
      try {
        await forceSyncUserData(uid);
      } catch (e) {
        debugPrint('Failed to sync pending user $uid: $e');
        // Keep in pending list for next attempt
      }
    }
  }

  /// Get sync status for a specific user
  static bool isUserPendingSync(String uid) {
    return _pendingSyncUsers.contains(uid);
  }

  /// Clear all pending sync operations
  static void clearPendingSync() {
    _pendingSyncUsers.clear();
  }

  /// Dispose the service and clean up resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isOnline.dispose();
    _syncStatus.dispose();
    _pendingSyncUsers.clear();
  }
}

/// Enum representing different synchronization states
enum SyncStatus {
  /// No sync operation in progress
  idle,
  
  /// Loading data from storage
  loading,
  
  /// Actively syncing data
  syncing,
  
  /// Data is fully synchronized
  synced,
  
  /// Data is only available locally (offline or sync failed)
  localOnly,
  
  /// Error occurred during sync
  error,
}