# Requirements Document

## Introduction

This feature implements an emergency SOS system for a Flutter mobile application that allows users to trigger emergency alerts through a hold-to-activate button interface. The system records audio evidence in safe chunks and uploads them to Firebase Storage while providing real-time feedback to users. The feature integrates with the existing design system and emergency contacts functionality to provide a comprehensive safety solution.

## Requirements

### Requirement 1

**User Story:** As a user in an emergency situation, I want to trigger an SOS alert by holding a button for 3 seconds, so that I can quickly activate emergency services without complex interactions.

#### Acceptance Criteria

1. WHEN the user presses and holds the SOS button THEN the system SHALL display an animated countdown circle showing progress
2. WHEN the user holds the button for exactly 3 seconds THEN the system SHALL trigger the SOS service with haptic feedback
3. WHEN the user releases the button before 3 seconds THEN the system SHALL cancel the countdown and reset to initial state
4. WHEN the SOS is triggered THEN the system SHALL display a snackbar message "Service Triggered!!"
5. WHEN the button is being held THEN the system SHALL show the remaining countdown seconds (3, 2, 1) in the button center
6. WHEN the SOS is processing THEN the system SHALL disable the button to prevent multiple triggers

### Requirement 2

**User Story:** As a user who has triggered SOS, I want the system to automatically record audio evidence, so that emergency responders have context about my situation.

#### Acceptance Criteria

1. WHEN the SOS is triggered THEN the system SHALL immediately start audio recording
2. WHEN recording starts THEN the system SHALL display a snackbar "Recording emergency message..."
3. WHEN recording THEN the system SHALL record for exactly 30 seconds total duration
4. WHEN recording THEN the system SHALL split the recording into safe 5-second chunks
5. WHEN each chunk is recorded THEN the system SHALL immediately upload it to Firebase Storage
6. WHEN recording is complete THEN the system SHALL reset the SOS state to allow new triggers

### Requirement 3

**User Story:** As a user, I want to see visual feedback during the SOS process, so that I understand the system status and feel confident it's working.

#### Acceptance Criteria

1. WHEN the page loads THEN the system SHALL display a centered SOS button with shield icon and "SOS" text
2. WHEN the page loads THEN the system SHALL show animated background glow and particle effects around the button
3. WHEN the button is pressed THEN the system SHALL scale the button down slightly (0.95x) for visual feedback
4. WHEN countdown is active THEN the system SHALL show an animated progress circle around the button
5. WHEN the system is processing THEN the system SHALL dim the button opacity to 0.7
6. WHEN particles animate THEN the system SHALL spread them 100-200px radius from button center
7. WHEN particles animate THEN the system SHALL make them visible with 12x12 size and 0.8+ opacity

### Requirement 4

**User Story:** As a user, I want the audio recording to be safely stored in the cloud, so that the evidence is preserved even if my device is damaged.

#### Acceptance Criteria

1. WHEN audio is recorded THEN the system SHALL upload each chunk to Firebase Storage path `sos_recordings/{uid}/Triggered_on_{date}/filename.m4a`
2. WHEN upload succeeds THEN the system SHALL log the success and continue with next chunk
3. WHEN all uploads complete successfully THEN the system SHALL show success feedback to user
4. WHEN upload fails THEN the system SHALL show error snackbar "Recording or upload failed"
5. WHEN user is not authenticated THEN the system SHALL handle gracefully without crashing
6. WHEN recording THEN the system SHALL use AAC-LC encoding at 128kbps, 44.1kHz sample rate

### Requirement 5

**User Story:** As a user, I want to see my emergency contacts displayed below the SOS button, so that I can verify who will be notified during an emergency.

#### Acceptance Criteria

1. WHEN user is logged in THEN the system SHALL display the EmergencyContacts() widget below the SOS button
2. WHEN user is a guest THEN the system SHALL display the guestEcCard(context) widget instead
3. WHEN emergency contacts are displayed THEN the system SHALL use the existing emergency contacts functionality
4. WHEN the page layout is rendered THEN the system SHALL maintain proper spacing using SizeConfig values

### Requirement 6

**User Story:** As a user on iOS, I want the audio recording to work even if the app goes to background, so that my emergency recording isn't interrupted.

#### Acceptance Criteria

1. WHEN recording starts on iOS THEN the system SHALL configure audio session for background recording
2. WHEN app goes to background during recording THEN the system SHALL continue recording without interruption
3. WHEN background recording is active THEN the system SHALL track the background recording state
4. WHEN recording completes THEN the system SHALL properly clean up background audio session
5. WHEN audio session configuration fails THEN the system SHALL log the error and continue with foreground recording

### Requirement 7

**User Story:** As a user, I want the SOS interface to follow the app's design system, so that it feels consistent with the rest of the application.

#### Acceptance Criteria

1. WHEN the page renders THEN the system SHALL use AppColors for all color values
2. WHEN text is displayed THEN the system SHALL use AppTypography styles for consistent typography
3. WHEN spacing is applied THEN the system SHALL use SizeConfig for all dimensions, paddings, and margins
4. WHEN the page title is shown THEN the system SHALL display "Stay Safe" using titleLarge style
5. WHEN the subtitle is shown THEN the system SHALL display "Hold 3 secs to trigger alert!" using default text style
6. WHEN snackbars are shown THEN the system SHALL use Utilis.showSnackBar for consistent messaging
7. WHEN the button is styled THEN the system SHALL use Theme.of(context).colorScheme for primary colors