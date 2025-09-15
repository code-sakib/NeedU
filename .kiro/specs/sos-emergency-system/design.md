# Design Document

## Overview

The SOS Emergency System is designed as a two-component architecture consisting of a user interface (SOSPage) and a service layer (AudioServices). The system provides a hold-to-activate emergency button with visual feedback, automatic audio recording in safe chunks, and cloud storage integration. The design emphasizes user safety, reliability, and seamless integration with the existing Flutter app architecture.

## Architecture

### Component Structure
```
SOSPage (UI Layer)
├── Visual Components
│   ├── SOS Button with animations
│   ├── Countdown timer with progress circle
│   ├── Particle effects and glow animations
│   └── Emergency contacts display
└── State Management
    ├── Button press states (_isPressed, _sosTriggered, _isProcessing)
    ├── Animation controllers (glow, particles, timer)
    └── User feedback handling

AudioServices (Service Layer)
├── Recording Management
│   ├── Microphone permission handling
│   ├── Audio session configuration (iOS background)
│   └── Safe chunk recording (5s segments)
├── Cloud Storage Integration
│   ├── Firebase Storage uploads
│   ├── Structured path organization
│   └── Error handling and retry logic
└── Singleton Pattern
    └── Instance management for app-wide access
```

### Data Flow
1. **User Interaction**: User presses and holds SOS button
2. **Visual Feedback**: Countdown animation and visual effects activate
3. **Trigger Point**: After 3 seconds, SOS triggers with haptic feedback
4. **Service Activation**: AudioServices begins recording in background
5. **Chunk Processing**: 5-second chunks recorded and uploaded sequentially
6. **User Feedback**: Snackbars provide status updates throughout process
7. **State Reset**: System returns to ready state after completion

## Components and Interfaces

### SOSPage Widget

**State Variables:**
- `_isPressed: bool` - Tracks button press state for visual scaling
- `_sosTriggered: bool` - Indicates SOS has been activated after 3s countdown
- `_isProcessing: bool` - Prevents multiple triggers during recording/upload

**Animation Controllers:**
- `_glowController` - Continuous pulsing glow effect (1.5s duration, repeating)
- `_particleController` - Particle movement animation (4s duration, repeating)
- `_timerController` - 3-second countdown progress (2s duration, single use)

**Key Methods:**
- `_startSOSTimer()` - Initiates countdown when button pressed
- `_cancelSOSTimer()` - Cancels countdown if button released early
- `_onSOSTriggered()` - Handles SOS activation after countdown completion
- `_resetSosState()` - Resets all states to initial values

**Visual Components:**
- **SOS Button**: 200x200px circular button with gradient background
- **Progress Circle**: Animated stroke around button showing countdown progress
- **Particles**: 12 animated particles in 100-200px radius with glow effects
- **Countdown Display**: Large numbers (3, 2, 1) shown during countdown

### AudioServices Singleton

**Core Properties:**
- `_recorder: AudioRecorder` - Handles audio recording functionality
- `_player: AudioPlayer` - Manages audio playback for testing
- `lastFilePath: String?` - Stores path to most recent recording
- `_isBackgroundRecording: bool` - Tracks background recording state

**Public Methods:**
```dart
Future<bool> hasPermission() // Check microphone permissions
Future<String?> startRecording({bool backgroundMode}) // Begin recording
Future<String?> stopRecording() // End recording and return file path
Future<String?> uploadRecording(String? localPath) // Upload to Firebase
Future<List<String>> recordInSafeChunks({...}) // Main SOS recording method
Future<void> playRecording() // Play last recorded file
```

**Recording Configuration:**
- **Format**: AAC-LC encoding for broad compatibility
- **Quality**: 128kbps bitrate, 44.1kHz sample rate
- **Chunk Size**: 5-second segments for reliability
- **Total Duration**: 30 seconds (6 chunks)

### Firebase Storage Integration

**Storage Path Structure:**
```
sos_recordings/
└── {user_uid}/
    └── Triggered_on_{YYYY-MM-DD}/
        ├── rec_HH.MM.SS.m4a
        ├── rec_HH.MM.SS.m4a
        └── ...
```

**Upload Strategy:**
- Sequential chunk uploads (not parallel) to avoid overwhelming connection
- Immediate upload after each chunk completion
- Error handling with graceful degradation
- Structured naming for easy retrieval and organization

## Data Models

### Recording Chunk Model
```dart
class RecordingChunk {
  final String localPath;      // Local file system path
  final String? uploadUrl;     // Firebase download URL after upload
  final DateTime timestamp;    // When chunk was recorded
  final int chunkIndex;        // Sequential chunk number (0-5)
  final bool uploadSuccess;    // Upload completion status
}
```

### SOS Session Model
```dart
class SOSSession {
  final String sessionId;           // Unique session identifier
  final DateTime triggerTime;       // When SOS was activated
  final String userId;              // User who triggered SOS
  final List<String> uploadedUrls;  // Successfully uploaded chunk URLs
  final bool completed;             // Session completion status
}
```

## Error Handling

### Permission Handling
- **Microphone Access**: Check permissions before recording, show user-friendly error if denied
- **Storage Access**: Handle temporary directory access failures gracefully
- **Network Access**: Manage upload failures with appropriate user feedback

### Recording Failures
- **Device Limitations**: Handle cases where recording fails due to hardware issues
- **Storage Full**: Manage insufficient storage space scenarios
- **Background Interruption**: Handle phone calls or other audio interruptions

### Upload Failures
- **Network Issues**: Retry logic for temporary network failures
- **Authentication**: Handle Firebase auth token expiration
- **Storage Quota**: Manage Firebase Storage quota exceeded scenarios

### User Feedback Strategy
```dart
// Success Messages
"Service Triggered!!" // SOS activation confirmation
"Recording emergency message..." // Recording start notification

// Error Messages  
"Recording or upload failed" // General failure notification
"Login to trigger SOS 🙂" // Guest user limitation (if applicable)
```

## Testing Strategy

### Unit Testing
- **AudioServices Methods**: Test all public methods with mocked dependencies
- **Permission Handling**: Mock permission states and verify correct behavior
- **File Operations**: Test recording, stopping, and file management
- **Upload Logic**: Mock Firebase Storage and test upload success/failure scenarios

### Widget Testing
- **Button Interactions**: Test press, hold, and release behaviors
- **Animation States**: Verify animation controllers respond correctly to state changes
- **Visual Feedback**: Test countdown display, button scaling, and opacity changes
- **State Management**: Verify state transitions during SOS flow

### Integration Testing
- **End-to-End Flow**: Test complete SOS trigger → record → upload → reset cycle
- **Background Recording**: Test iOS background audio session handling
- **Firebase Integration**: Test actual uploads to Firebase Storage (with test data)
- **Permission Flow**: Test microphone permission request and handling

### Performance Testing
- **Memory Usage**: Monitor memory consumption during recording and upload
- **Battery Impact**: Measure battery drain during background recording
- **Animation Performance**: Ensure smooth 60fps animations on target devices
- **Upload Efficiency**: Test upload speed and reliability across network conditions

## Platform-Specific Considerations

### iOS Background Recording
- **Audio Session Configuration**: Configure AVAudioSession for background recording
- **App Lifecycle Management**: Handle app backgrounding during recording
- **Permission Requirements**: Ensure proper microphone usage description in Info.plist

### Android Considerations
- **Foreground Service**: May require foreground service for reliable background recording
- **Permission Handling**: Handle runtime permission requests appropriately
- **Battery Optimization**: Account for device-specific battery optimization settings

## Security and Privacy

### Data Protection
- **Local Storage**: Temporary files stored in secure app directory
- **Cloud Storage**: Firebase Security Rules to restrict access to user's own recordings
- **Data Retention**: Consider automatic cleanup of old recordings

### User Privacy
- **Permission Transparency**: Clear explanation of why microphone access is needed
- **Data Usage**: Transparent communication about what data is recorded and stored
- **User Control**: Ability to delete recordings if needed (future enhancement)

## Design System Integration

### Color Usage
- **Primary Actions**: `AppColors.primary` for SOS button and progress indicators
- **Background Elements**: `AppColors.background` and `AppColors.surface` for containers
- **Text Elements**: `AppColors.text` for primary text, `AppColors.textMuted` for secondary
- **Error States**: `AppColors.textErr` for error messages and failed states

### Typography
- **Page Title**: `AppTypography.titleLarge` for "Stay Safe" heading
- **Instructions**: Default body text for "Hold 3 secs to trigger alert!"
- **Button Text**: Large, bold text for "SOS" button label
- **Countdown**: Custom large text (32px) for countdown numbers

### Spacing and Layout
- **Screen Padding**: `SizeConfig.screenVPadding` and `SizeConfig.screenHPadding`
- **Component Spacing**: `SizeConfig.defaultHeight1` and `SizeConfig.defaultHeight2`
- **Button Dimensions**: Based on `SizeConfig.blockHeight` for responsive sizing
- **Particle Spread**: Calculated using screen dimensions for proper scaling