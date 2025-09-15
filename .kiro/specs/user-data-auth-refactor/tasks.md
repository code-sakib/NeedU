# Implementation Plan

- [x] 1. Create core UserModel with proper serialization

  - Implement UserModel class with all required fields (uid, name, email, phoneNumber, emergencyContacts, profilePhotoUrl, createdAt, updatedAt)
  - Add toFirestore() and fromFirestore() methods for Firestore serialization
  - Add toLocalStorage() and fromLocalStorage() methods for SharedPreferences serialization
  - Include proper null safety and validation
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Implement UserRepository for data operations

  - Create UserRepository class with Firestore operations (createUser, getUser, updateUser, userExists)
  - Add local storage operations (saveUserLocally, getUserLocally, clearLocalUser)
  - Implement emergency contacts specific methods (updateEmergencyContacts, getEmergencyContacts)
  - Add profile operations (uploadProfilePhoto, updateProfile)
  - Include proper error handling for all operations
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 4.1, 4.2, 4.3, 4.4, 7.1, 7.2, 7.3, 7.4_

- [x] 3. Create centralized error handling system

  - Implement AppError class with different error types (authentication, network, validation, storage, database)
  - Create ErrorHandler class for centralized error processing
  - Add user-friendly error message mapping
  - Include logging functionality for debugging
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4. Refactor AuthService with clean interfaces

  - Update AuthService class with proper method signatures for email/password auth
  - Implement Google authentication with proper error handling
  - Add phone authentication methods (sendOTP, verifyOTP)
  - Include signOut method and authStateChanges stream
  - Remove unused imports and clean up existing code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 6.1, 6.2, 6.3, 6.4_

- [x] 5. Implement AuthStateManager for global state management

  - Create AuthStateManager class with static methods for user state management
  - Add initializeUser method to set up user session from Firebase User
  - Implement updateCurrentUser method for updating global user object
  - Add clearUser method for sign out operations
  - Include proper state notifications using ValueNotifier
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 6. Update authentication screens with new services

  - Refactor SignIn and SignUp widgets to use new AuthService methods
  - Add proper form validation and error display
  - Implement loading states during authentication operations
  - Update navigation flow to use AuthStateManager
  - Remove unused imports and clean up existing auth screen code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 5.1, 5.2, 5.3_

- [x] 7. Refactor account setup flow

  - Update PhoneAuth2 widget to use new phone authentication methods
  - Implement proper OTP sending and verification using AuthService
  - Add user data creation using UserRepository after successful verification
  - Include proper error handling and user feedback
  - Clean up existing account setup code and remove redundant functionality
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 6.1, 6.2, 6.3, 6.4_

- [x] 8. Update routing logic with new auth state management

  - Refactor app routing to use AuthStateManager instead of direct Firebase Auth
  - Implement proper user initialization flow in route guards
  - Add loading states during user data fetching
  - Update navigation logic for new vs existing users
  - Clean up existing routing code and remove unused imports
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 9. Implement data synchronization between local and cloud storage

  - Add logic to load user data from local storage on app start
  - Implement cloud data fetching and synchronization
  - Handle conflicts between local and cloud data (cloud as source of truth)
  - Add offline support with local storage fallback
  - Include proper error handling for sync operations
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 10. Update emergency contacts management

  - Refactor emergency contacts operations to use UserRepository
  - Implement proper synchronization between local and cloud storage
  - Add error handling for emergency contacts operations
  - Update UI components to use new data management system
  - Clean up existing emergency contacts code
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 11. Clean up and remove deprecated code

  - Remove old CloudDB class and migrate functionality to UserRepository
  - Clean up unused imports across all auth-related files
  - Remove redundant code and consolidate similar functionality
  - Update global variables and dependencies
  - Ensure all files follow consistent coding patterns
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 12. Add comprehensive error handling and user feedback
  - Integrate ErrorHandler throughout the application
  - Add loading indicators for all async operations
  - Implement success messages for completed operations
  - Add retry mechanisms for failed operations
  - Ensure all error scenarios provide helpful user guidance
  - _Requirements: 5.1, 5.2, 5.3, 5.4_
