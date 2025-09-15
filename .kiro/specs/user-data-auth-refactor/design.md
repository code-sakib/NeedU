# Design Document

## Overview

This design refactors the user data management and authentication system to provide a clean, maintainable, and robust foundation. The design focuses on proper separation of concerns, consistent data models, reliable error handling, and seamless user experience.

## Architecture

### Core Components

1. **UserModel** - Clean data model with proper serialization
2. **UserRepository** - Handles all user data operations (Firestore + local storage)
3. **AuthService** - Manages authentication operations
4. **AuthStateManager** - Manages global auth state and user object
5. **ErrorHandler** - Centralized error handling and user feedback

### Data Flow

```
User Action → AuthService → UserRepository → Firestore/LocalStorage
                ↓
         AuthStateManager → Global State Update → UI Update
```

## Components and Interfaces

### UserModel

```dart
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final Map<String, dynamic> emergencyContacts;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Serialization methods
  Map<String, dynamic> toFirestore();
  Map<String, dynamic> toLocalStorage();
  static UserModel fromFirestore(Map<String, dynamic> data);
  static UserModel fromLocalStorage(Map<String, dynamic> data);
}
```

### UserRepository

```dart
class UserRepository {
  // Firestore operations
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> updateUser(UserModel user);
  Future<bool> userExists(String uid);
  
  // Local storage operations
  Future<void> saveUserLocally(UserModel user);
  Future<UserModel?> getUserLocally();
  Future<void> clearLocalUser();
  
  // Emergency contacts specific
  Future<void> updateEmergencyContacts(String uid, Map<String, dynamic> contacts);
  Future<Map<String, dynamic>> getEmergencyContacts(String uid);
  
  // Profile operations
  Future<String> uploadProfilePhoto(String uid, File imageFile);
  Future<void> updateProfile(String uid, {String? name, String? photoUrl});
}
```

### AuthService

```dart
class AuthService {
  // Email/Password auth
  Future<User> signUpWithEmail(String email, String password);
  Future<User> signInWithEmail(String email, String password);
  
  // Google auth
  Future<User> signInWithGoogle();
  
  // Phone auth
  Future<void> sendOTP(String phoneNumber);
  Future<User> verifyOTP(String verificationId, String smsCode);
  
  // General
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
```

### AuthStateManager

```dart
class AuthStateManager {
  static UserModel? _currentUser;
  static final ValueNotifier<AuthState> _authState = ValueNotifier(AuthState.loading);
  
  // Initialize user session
  static Future<void> initializeUser(User firebaseUser);
  
  // Update user data
  static Future<void> updateCurrentUser(UserModel user);
  
  // Clear user session
  static Future<void> clearUser();
  
  // Getters
  static UserModel? get currentUser => _currentUser;
  static ValueNotifier<AuthState> get authState => _authState;
}
```

## Data Models

### Firestore Structure

```
users/{uid}/
  ├── data/
  │   ├── uid: string
  │   ├── name: string?
  │   ├── email: string?
  │   ├── phoneNumber: string?
  │   ├── emergencyContacts: Map<string, dynamic>
  │   ├── profilePhotoUrl: string?
  │   ├── createdAt: Timestamp
  │   └── updatedAt: Timestamp?
```

### Local Storage Structure

```
SharedPreferences:
  - user_uid: string
  - user_name: string
  - user_email: string
  - user_phone: string
  - user_emergency_contacts: JSON string
  - user_profile_photo: string
  - user_created_at: ISO string
  - user_updated_at: ISO string
```

### Firebase Storage Structure

```
users/{uid}/
  └── profile/
      └── profile_photo.jpg
```

## Error Handling

### Error Types

1. **AuthenticationError** - Login/signup failures
2. **NetworkError** - Connection issues
3. **ValidationError** - Invalid data
4. **StorageError** - File upload issues
5. **DatabaseError** - Firestore operation failures

### Error Handling Strategy

```dart
class AppError {
  final String code;
  final String message;
  final String userMessage;
  final dynamic originalError;
  
  // Factory constructors for different error types
  factory AppError.authentication(String message);
  factory AppError.network(String message);
  factory AppError.validation(String field, String message);
  factory AppError.storage(String message);
  factory AppError.database(String message);
}

class ErrorHandler {
  static void handleError(AppError error) {
    // Log error for debugging
    _logError(error);
    
    // Show user-friendly message
    _showUserMessage(error.userMessage);
    
    // Handle specific error types
    _handleSpecificError(error);
  }
}
```

## Testing Strategy

### Unit Tests

1. **UserModel** - Serialization/deserialization
2. **UserRepository** - All CRUD operations
3. **AuthService** - Authentication methods
4. **AuthStateManager** - State management logic

### Integration Tests

1. **Auth Flow** - Complete signup/signin process
2. **Data Sync** - Local storage ↔ Firestore synchronization
3. **Error Scenarios** - Network failures, invalid data

### Widget Tests

1. **Auth Screens** - Form validation, user interactions
2. **Loading States** - Progress indicators
3. **Error States** - Error message display

## Implementation Phases

### Phase 1: Core Data Models
- Create UserModel with proper serialization
- Implement UserRepository with basic CRUD operations
- Set up proper error handling foundation

### Phase 2: Authentication Service
- Refactor AuthService with clean interfaces
- Implement AuthStateManager for global state
- Update auth screens to use new services

### Phase 3: Data Synchronization
- Implement local storage operations
- Add data synchronization logic
- Handle offline scenarios

### Phase 4: Profile Management
- Add profile photo upload functionality
- Implement profile update operations
- Add emergency contacts management

### Phase 5: Integration & Testing
- Integrate all components
- Add comprehensive error handling
- Implement loading states and user feedback

## Security Considerations

1. **Data Validation** - Validate all user inputs
2. **Access Control** - Ensure users can only access their own data
3. **Sensitive Data** - Never store passwords locally
4. **File Upload** - Validate file types and sizes for profile photos
5. **Phone Verification** - Implement rate limiting for OTP requests