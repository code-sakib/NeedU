# Implementation Plan

- [x] 1. Create local storage utility service
  - Implement `LocalUserStore` class in `lib/utilis/local_storage.dart` with methods for saving, retrieving, and clearing user data from SharedPreferences
  - Add JSON serialization/deserialization for user data maps
  - Include error handling for storage operations
  - _Requirements: 1.4, 1.6_

- [x] 2. Enhance Firebase authentication service for phone OTP
  - Refactor existing `verifyPhoneNumber` method in `firebase_auth_services.dart` to match design interface
  - Create `verifyPhoneOtpAndSignUp` method that verifies OTP, checks phone uniqueness, creates/retrieves Firestore user document
  - Add `signInWithPhoneOtp` method for existing user sign-in
  - Implement proper error handling and user-friendly error messages
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3_

- [x] 3. Enhance Firestore user document management
  - Update existing `CloudDB.isNewUser()` method to include phone number uniqueness checking
  - Create new method `CloudDB.checkPhoneUniqueness()` to query users collection by phone number
  - Implement proper server timestamp handling for `createdAt` field using `FieldValue.serverTimestamp()`
  - Enhance error handling for Firestore operations
  - _Requirements: 1.2, 1.6, 2.2_

- [x] 4. Create dedicated phone number sign-up screen
  - Build new `PhoneSignUpScreen` widget in `auth_services.dart` with name and phone number input fields using `IntlPhoneField`
  - Implement form validation for name and phone number
  - Add "Send OTP" button with loading states
  - Integrate with enhanced Firebase service to request OTP
  - Handle success/error states and navigation to OTP screen
  - _Requirements: 1.1, 1.5, 2.7_

- [x] 5. Create dedicated OTP verification screen
  - Build new `OTPVerificationScreen` widget in `auth_services.dart` with 6-digit OTP input field
  - Implement OTP verification logic calling Firebase service
  - Add resend OTP functionality with timer
  - Handle verification success/failure with appropriate navigation
  - Include loading states and error handling
  - _Requirements: 1.2, 1.5, 2.8_

- [x] 6. Create phone sign-in screen for existing users
  - Build new `PhoneSignInScreen` widget in `auth_services.dart` for existing user phone sign-in
  - Implement phone number input and OTP request
  - Navigate to OTP verification screen with sign-in context
  - Handle successful sign-in by fetching existing user data
  - _Requirements: 1.3, 1.5_

- [x] 7. Update authentication coordinator screen
  - Modify existing `AuthScreen` in `auth_services.dart` to include phone authentication options
  - Add navigation buttons for phone sign-up and phone sign-in alongside existing email/password options
  - Ensure consistent styling with current design system using existing `authButton` widget
  - _Requirements: 1.5, 2.7_

- [x] 8. Update go_router navigation configuration
  - Add new routes in `routing.dart` for phone sign-up (`/auth/phoneSignUp`), phone sign-in (`/auth/phoneSignIn`), and OTP verification (`/auth/verifyOtp`)
  - Implement proper data passing between screens using `extra` parameter
  - Update existing route guards and redirects for new auth flow
  - Replace current `/accountSetup` route that points to `PhoneAuth2`
  - _Requirements: 1.5, 2.5_

- [x] 9. Implement user data persistence and global state management
  - Update user data saving to use new `LocalUserStore` after successful authentication
  - Modify global `currentUser` initialization in routing logic to load from local storage on app startup
  - Update `CurrentUser.getFromLocal()` method to properly restore global state
  - Ensure user data synchronization between local and cloud storage
  - _Requirements: 1.4, 1.6_

- [x] 10. Update sign-out functionality
  - Modify existing `AuthService.signOut()` method to clear local stored user data using `LocalUserStore`
  - Reset global `currentUser` state to null
  - Ensure proper cleanup of authentication tokens
  - Navigate to appropriate screen after sign-out
  - _Requirements: 1.4_

- [x] 11. Replace existing PhoneAuth2 implementation
  - Remove existing `PhoneAuth2` class from `account_setup.dart`
  - Update references in routing to use new phone auth screens
  - Clean up unused imports and variables in `account_setup.dart`
  - Ensure smooth transition to new phone auth flow
  - _Requirements: 1.5_

- [x] 12. Implement comprehensive error handling
  - Add user-friendly error messages for all authentication failures in Firebase service
  - Implement retry mechanisms for network failures
  - Add proper error recovery options (resend OTP, retry verification)
  - Ensure consistent error display using existing `Utilis.showSnackBar`
  - _Requirements: 2.8_

- [x] 13. Add loading states and user feedback
  - Implement loading indicators for all async operations in phone auth screens
  - Disable buttons during processing to prevent multiple submissions
  - Add success feedback for completed operations
  - Ensure accessibility compliance for all loading states
  - _Requirements: 2.7_

- [x] 14. Create comprehensive unit tests
  - Write tests for `LocalUserStore` methods
  - Test enhanced Firebase authentication service methods with mocked responses
  - Add validation tests for phone number and OTP input
  - Test error handling scenarios and edge cases
  - _Requirements: All requirements - testing coverage_

- [x] 15. Create integration tests for authentication flow
  - Test complete sign-up flow from phone entry to account creation
  - Test existing user sign-in flow
  - Verify data persistence across app restarts
  - Test navigation flow between authentication screens
  - _Requirements: All requirements - integration testing_

- [x] 16. Update app initialization and routing logic
  - Modify app startup logic in `routing.dart` to check for stored user data using `LocalUserStore`
  - Update initial route determination based on authentication state
  - Ensure proper handling of deep links and route restoration
  - Test app behavior with and without stored user data
  - _Requirements: 1.4, 1.5_
