# Implementation Plan

- [x] 1. Create AudioServices singleton class with core recording functionality

  - Implement singleton pattern with private constructor and static instance
  - Add AudioRecorder and AudioPlayer instances as private properties
  - Create hasPermission() method to check microphone permissions
  - Implement \_makeFileName() helper to generate unique recording filenames
  - Create \_recordingDir() method to get/create temporary recording directory
  - _Requirements: 2.1, 2.4, 4.6, 6.1_

- [x] 2. Implement basic recording start/stop functionality in AudioServices

  - Create startRecording() method with backgroundMode parameter
  - Configure RecordConfig with AAC-LC encoding, 128kbps bitrate, 44.1kHz sample rate
  - Implement iOS background audio session configuration in \_configureAudioSession()
  - Create stopRecording() method that returns absolute file path
  - Add lastFilePath property to track most recent recording
  - _Requirements: 2.1, 4.6, 6.1, 6.2_

- [x] 3. Add Firebase Storage upload functionality to AudioServices

  - Implement uploadRecording() method that takes local file path
  - Create Firebase Storage path structure: sos*recordings/{uid}/Triggered_on*{date}/filename.m4a
  - Add proper error handling for FirebaseException cases
  - Return download URL on successful upload, null on failure
  - Add debug logging for upload success/failure tracking
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 4. Implement safe chunk recording system in AudioServices

  - Create recordInSafeChunks() method with configurable duration parameters
  - Implement loop to record 5-second chunks for total 30-second duration
  - Add immediate upload after each chunk completion
  - Return List<String> of successfully uploaded URLs
  - Add proper cleanup of temporary files after upload
  - _Requirements: 2.3, 2.4, 2.5, 4.1, 4.2_

- [x] 5. Create SOSPage widget with basic structure and design system integration

  - Create StatefulWidget with TickerProviderStateMixin for animations
  - Add Scaffold with SingleChildScrollView and proper padding using SizeConfig
  - Implement page header with "Stay Safe" title using AppTypography.titleLarge
  - Add subtitle "Hold 3 secs to trigger alert!" with default text style
  - Create basic SOS button structure with shield icon and "SOS" text
  - _Requirements: 1.1, 3.1, 5.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 6. Implement SOS button state management and visual feedback

  - Add state variables: \_isPressed, \_sosTriggered, \_isProcessing
  - Create AnimationControllers for glow, particles, and timer
  - Implement GestureDetector with onTapDown, onTapUp, onTapCancel handlers
  - Add AnimatedScale for button press visual feedback (0.95x scale)
  - Implement button opacity dimming (0.7) during processing state
  - _Requirements: 1.3, 1.6, 3.3, 3.5, 7.6_

- [x] 7. Create countdown timer animation and progress circle

  - Implement \_TimerPainter CustomPainter for progress circle animation
  - Add 3-second countdown with AnimationController
  - Display countdown numbers (3, 2, 1) in button center during hold
  - Create animated progress circle around button showing countdown progress
  - Add AnimationStatusListener to trigger SOS when countdown completes
  - _Requirements: 1.1, 1.2, 1.5, 3.4_

- [x] 8. Implement particle effects and background glow animations

  - Create \_buildParticle() method to generate individual particle widgets
  - Implement 12 particles with animated position using trigonometry
  - Set particle spread radius to 100-200px from button center
  - Add particle visual properties: 12x12 size, 0.8+ opacity, glow shadow
  - Create continuous glow animation with ScaleTransition (0.8 to 1.1 scale)
  - _Requirements: 3.2, 3.6, 3.7_

- [x] 9. Implement SOS trigger flow and AudioServices integration

  - Create \_startSOSTimer() method to begin countdown on button press
  - Implement \_cancelSOSTimer() method for early button release
  - Add \_onSOSTriggered() method with haptic feedback and state updates
  - Integrate AudioServices.recordInSafeChunks() call after trigger
  - Add proper error handling and user feedback via snackbars
  - _Requirements: 1.2, 1.4, 2.1, 2.2, 2.6_

- [x] 11. Integrate emergency contacts display below SOS button

  - Add conditional rendering: EmergencyContacts() for logged-in users
  - Show guestEcCard(context) for guest users
  - Ensure proper spacing using SizeConfig.defaultHeight2
  - Maintain existing emergency contacts functionality without modification
  - Test integration with current user authentication state
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 12. Add comprehensive error handling and edge cases

  - Handle microphone permission denial gracefully
  - Add network failure handling for Firebase uploads
  - Implement proper cleanup of animation controllers in dispose()
  - Add null safety checks for all file operations
  - Handle background recording interruptions (phone calls, etc.)
  - _Requirements: 4.4, 4.5, 6.3, 6.4_

- [x] 13. Implement iOS-specific background recording support

  - Add platform-specific checks for iOS background recording
  - Implement proper audio session configuration for background mode
  - Add \_isBackgroundRecording state tracking
  - Handle app lifecycle changes during recording
  - Add proper cleanup when background recording completes
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 10. Fix user feedback system and cleanup implementation issues

  - Fix unused variable warning in \_onSOSTriggered method
  - Uncomment and implement success/failure feedback based on recording results
  - Ensure proper display of upload success/failure messages to user
  - Verify \_resetSosState() method works correctly after all operations
  - _Requirements: 1.4, 2.2, 4.3, 4.4, 7.6_

- [x] 16. Rename AudioServices2 class to AudioServices for consistency

  - Rename AudioServices2 class to AudioServices in audio_services.dart
  - Update all imports and references in SOSPage to use AudioServices
  - Ensure singleton instance is properly accessible as AudioServices.instance
  - Update any other files that reference AudioServices2
  - _Requirements: 2.1, 4.1_

- [x] 17. Create unit tests for AudioServices functionality

  - Write tests for singleton pattern implementation
  - Test recording start/stop functionality with mocked dependencies
  - Add tests for Firebase upload success/failure scenarios
  - Test safe chunk recording with various duration parameters
  - Verify proper error handling for all edge cases
  - _Requirements: 2.1, 2.4, 4.1, 4.4_

- [ ] 18. Create widget tests for SOSPage interactions
  - Test button press, hold, and release behaviors
  - Verify countdown animation and state transitions
  - Test SOS trigger flow and state management
  - Add tests for particle animations and visual feedback
  - Verify emergency contacts integration
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 5.1_
