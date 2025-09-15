# Requirements Document

## Introduction

This feature implements a comprehensive phone-based authentication system for the app, replacing or enhancing the existing authentication flow. The system will support first-time sign-up with phone number verification via Firebase Phone OTP, user data persistence in Firestore, local storage management, and proper navigation flow using go_router. The authentication flow will collect essential user information (name and phone) during sign-up, verify phone numbers through OTP, and maintain user sessions both locally and in the cloud.

## Requirements

### Requirement 1

**User Story:** As a new user, I want to sign up using my phone number and name, so that I can create an account and access the app's features.

#### Acceptance Criteria

1. WHEN a new user accesses the sign-up page THEN the system SHALL display input fields for name and phone number
2. WHEN the user enters a valid name and phone number THEN the system SHALL validate the inputs and enable the "Send OTP" button
3. WHEN the user submits valid sign-up information THEN the system SHALL call Firebase Phone Auth to send an OTP to the provided phone number
4. WHEN the OTP is successfully sent THEN the system SHALL navigate to the OTP verification screen with the verification ID, name, and phone number
5. IF the phone number is invalid or OTP sending fails THEN the system SHALL display an appropriate error message using snackbar

### Requirement 2

**User Story:** As a new user, I want to verify my phone number with an OTP code, so that I can complete my account registration securely.

#### Acceptance Criteria

1. WHEN the user reaches the OTP verification screen THEN the system SHALL display an input field for the 6-digit OTP code
2. WHEN the user enters a valid OTP code THEN the system SHALL verify the code with Firebase Auth
3. WHEN OTP verification is successful AND this is a first-time sign-up THEN the system SHALL create a new Firestore document in the users collection
4. WHEN creating the Firestore user document THEN the system SHALL include fields: uid, name, profilePhotoUrl (nullable), emergencyContacts (nullable/array), phoneNumber, and createdAt timestamp
5. WHEN the user document is created successfully THEN the system SHALL return a map containing all user data
6. WHEN the user data map is returned THEN the system SHALL save it locally using SharedPreferences and set the global currentUser
7. WHEN local storage is complete THEN the system SHALL navigate to the account setup page or SOS page
8. IF OTP verification fails THEN the system SHALL display an error message and allow retry or resend

### Requirement 3

**User Story:** As an existing user, I want to sign in using my phone number or email/password, so that I can access my account and app features.

#### Acceptance Criteria

1. WHEN an existing user accesses the sign-in page THEN the system SHALL provide options for phone OTP sign-in and email/password sign-in
2. WHEN the user chooses phone sign-in and enters their phone number THEN the system SHALL send an OTP to the registered phone number
3. WHEN the user verifies the OTP successfully THEN the system SHALL fetch the existing user document from Firestore
4. WHEN the user document is retrieved THEN the system SHALL save it locally and set the global currentUser
5. WHEN sign-in is complete THEN the system SHALL navigate to the main app (SOS page)
6. IF the user chooses email/password sign-in THEN the system SHALL authenticate using Firebase Auth email/password method
7. IF sign-in fails THEN the system SHALL display appropriate error messages

### Requirement 4

**User Story:** As a user, I want my authentication state to persist across app sessions, so that I don't have to sign in every time I open the app.

#### Acceptance Criteria

1. WHEN a user successfully signs up or signs in THEN the system SHALL save their user data as a JSON string in SharedPreferences under the key "currentUser"
2. WHEN the app starts THEN the system SHALL check for stored user data in SharedPreferences
3. WHEN stored user data is found THEN the system SHALL set the global currentUser variable and navigate to the appropriate authenticated screen
4. WHEN no stored user data is found THEN the system SHALL navigate to the authentication landing page
5. WHEN a user signs out THEN the system SHALL clear the stored user data from SharedPreferences and reset the global currentUser

### Requirement 5

**User Story:** As a developer, I want proper navigation flow using go_router, so that the authentication states are properly managed and users can navigate seamlessly through the auth flow.

#### Acceptance Criteria

1. WHEN implementing navigation THEN the system SHALL use go_router for all authentication-related navigation
2. WHEN defining routes THEN the system SHALL include routes for: landing (/), sign-up (/auth/signUp), sign-in (/auth/signIn), OTP verification (/auth/verifyOtp), account setup (/accountSetup), and main app (/sosPage)
3. WHEN navigating to OTP verification THEN the system SHALL pass required data (verificationId, name, phone) via the extra parameter
4. WHEN navigation occurs THEN the system SHALL ensure proper state management and data flow between screens
5. WHEN users cancel or go back during the auth flow THEN the system SHALL handle navigation appropriately

### Requirement 6

**User Story:** As a user, I want the app to prevent duplicate accounts and handle phone number uniqueness, so that I can't accidentally create multiple accounts with the same phone number.

#### Acceptance Criteria

1. WHEN creating a new user account THEN the system SHALL check if the phone number already exists in the Firestore users collection
2. WHEN an existing phone number is found THEN the system SHALL treat it as an existing account and return the existing user data instead of creating a duplicate
3. WHEN no existing phone number is found THEN the system SHALL proceed with creating a new user document
4. WHEN checking for phone uniqueness THEN the system SHALL query the users collection for documents where phoneNumber equals the requested phone
5. IF the uniqueness check fails due to network issues THEN the system SHALL display an appropriate error message

### Requirement 7

**User Story:** As a user, I want a consistent and accessible UI design throughout the authentication flow, so that I have a smooth and professional experience.

#### Acceptance Criteria

1. WHEN designing authentication screens THEN the system SHALL use AppTypography, AppColors, AppTheme, and SizeConfig for consistent styling
2. WHEN implementing phone input THEN the system SHALL use IntlPhoneField for proper international phone number formatting
3. WHEN displaying messages THEN the system SHALL use Utilis.showSnackBar for success and error notifications
4. WHEN forms are being processed THEN the system SHALL show loading indicators and disable buttons to prevent multiple submissions
5. WHEN designing input fields THEN the system SHALL ensure proper validation, accessibility, and user feedback
6. WHEN implementing the UI THEN the system SHALL maintain consistency with existing app design patterns and components

### Requirement 8

**User Story:** As a user, I want proper error handling and recovery options during the authentication process, so that I can successfully complete authentication even if issues occur.

#### Acceptance Criteria

1. WHEN OTP sending fails THEN the system SHALL display a clear error message and provide a "Resend OTP" option
2. WHEN OTP verification times out THEN the system SHALL allow the user to request a new OTP
3. WHEN network errors occur THEN the system SHALL display appropriate error messages and provide retry options
4. WHEN users cancel during OTP verification THEN the system SHALL navigate back to the sign-up page
5. WHEN Firebase Auth errors occur THEN the system SHALL translate technical error messages into user-friendly messages
6. WHEN Firestore operations fail THEN the system SHALL handle errors gracefully and provide fallback options