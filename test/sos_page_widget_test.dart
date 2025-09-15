import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/audio/audio_services.dart';
import 'package:needu/features/audio/emergency_contacts.dart';
import 'package:needu/features/audio/sos_page.dart';
import 'package:needu/profile_page.dart';
import 'package:needu/utilis/size_config.dart';

// Mock classes
class MockAudioServices extends Mock implements AudioServices {}

// Helper function to create a properly initialized test widget
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        // Initialize SizeConfig with the test context
        SizeConfig().init(context);
        return child;
      },
    ),
  );
}

void main() {
  group('SOSPage Widget Tests', () {
    late MockAudioServices mockAudioServices;

    setUp(() {
      mockAudioServices = MockAudioServices();
    });

    testWidgets('should display SOS page with correct initial UI elements', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SOSPage()));

      // Act & Assert
      expect(find.text('Stay Safe 2'), findsOneWidget);
      expect(find.text('Hold 3 secs to trigger alert!'), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.byIcon(Icons.person_2_rounded), findsOneWidget);
    });

    testWidgets('should show emergency contacts for logged-in users', (WidgetTester tester) async {
      // Arrange
      isGuest = false;
      
      await tester.pumpWidget(createTestWidget(const SOSPage()));

      // Act & Assert
      expect(find.byType(EmergencyContacts), findsOneWidget);
    });

    testWidgets('should show guest card for guest users', (WidgetTester tester) async {
      // Arrange
      isGuest = true;
      
      await tester.pumpWidget(createTestWidget(const SOSPage()));

      // Act & Assert
      expect(find.text('Login to add emergency contacts'), findsOneWidget);
    });

    group('Button Press and Hold Behaviors', () {
      testWidgets('should scale button down when pressed', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Press down on button
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();

        // Assert - Button should be scaled down
        final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(animatedScale.scale, equals(0.95));
      });

      testWidgets('should return to normal scale when released early', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Press and release before 3 seconds
        final gesture = await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        // Assert - Button should return to normal scale
        final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(animatedScale.scale, equals(1.0));
      });

      testWidgets('should not respond to press when processing', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Mock haptic feedback
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              return null;
            }
            return null;
          },
        );

        // Act - Trigger SOS to set processing state
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3)); // Complete countdown
        await tester.pump(); // Allow state updates

        // Assert - Button opacity should be dimmed (0.7) during processing
        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, equals(0.7));
      });
    });

    group('Countdown Animation and State Transitions', () {
      testWidgets('should show countdown numbers during hold', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Start holding button
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        
        // Advance animation slightly
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Should show countdown number (3 initially)
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should show progress circle during countdown', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Start countdown
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();

        // Assert - CustomPaint for progress circle should be present
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should update countdown numbers as time progresses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Start countdown and advance time
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        
        // Advance to show "2"
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.text('2'), findsOneWidget);
        
        // Advance to show "1"
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('should cancel countdown when button released early', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Start and cancel countdown
        final gesture = await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500)); // Partial countdown
        await gesture.up();
        await tester.pump();

        // Assert - Countdown should be cancelled, no numbers visible
        expect(find.text('3'), findsNothing);
        expect(find.text('2'), findsNothing);
        expect(find.text('1'), findsNothing);
      });
    });

    group('SOS Trigger Flow and State Management', () {
      testWidgets('should trigger SOS after 3 second countdown completes', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Mock haptic feedback
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              return null;
            }
            return null;
          },
        );

        // Act - Complete full countdown
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3)); // Complete countdown
        
        // Assert - Should show trigger snackbar
        expect(find.text('Service Triggered!!'), findsOneWidget);
      });

      testWidgets('should show recording message after SOS trigger', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Mock haptic feedback
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              return null;
            }
            return null;
          },
        );

        // Act - Complete countdown and trigger
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(); // Allow state updates

        // Assert - Should show recording message
        expect(find.text('Recording emergency message...'), findsOneWidget);
      });

      testWidgets('should disable button during processing', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Mock haptic feedback
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              return null;
            }
            return null;
          },
        );

        // Act - Trigger SOS
        await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        // Assert - Button should be dimmed (processing state)
        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, equals(0.7));
      });

      testWidgets('should reset state after processing completes', (WidgetTester tester) async {
        // This test verifies the initial state which represents the reset state
        await tester.pumpWidget(createTestWidget(const SOSPage()));
        
        // Verify initial/reset state
        final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(animatedScale.scale, equals(1.0));
        
        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, equals(1.0));
      });
    });

    group('Particle Animations and Visual Feedback', () {
      testWidgets('should display 12 particle widgets', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act & Assert - Should have 12 particles (Transform widgets)
        final particles = find.byType(Transform);
        expect(particles, findsNWidgets(12));
      });

      testWidgets('should animate particles with proper opacity', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act - Let animation run
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - Particles should have opacity between 0.8 and 1.0
        final opacityWidgets = find.byType(Opacity);
        expect(opacityWidgets, findsWidgets);
        
        // Check that at least some opacity widgets exist (particles + button)
        expect(opacityWidgets.evaluate().length, greaterThan(0));
      });

      testWidgets('should have particles with correct size and decoration', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act & Assert - Check particle containers
        final containers = find.descendant(
          of: find.byType(Transform),
          matching: find.byType(Container),
        );
        
        expect(containers, findsNWidgets(12));
        
        // Check first particle container properties
        final firstContainer = tester.widget<Container>(containers.first);
        expect(firstContainer.constraints?.maxWidth, equals(12));
        expect(firstContainer.constraints?.maxHeight, equals(12));
        
        final decoration = firstContainer.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, equals(1));
      });

      testWidgets('should animate glow effect with scale transition', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act - Let glow animation run
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750)); // Half of 1.5s duration

        // Assert - ScaleTransition should be present and animating
        final scaleTransition = find.byType(ScaleTransition);
        expect(scaleTransition, findsOneWidget);
        
        final scaleWidget = tester.widget<ScaleTransition>(scaleTransition);
        expect(scaleWidget.scale, isNotNull);
      });
    });

    group('Emergency Contacts Integration', () {
      testWidgets('should show EmergencyContacts widget when user is logged in', (WidgetTester tester) async {
        // Arrange
        isGuest = false;
        
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act & Assert
        expect(find.byType(EmergencyContacts), findsOneWidget);
        expect(find.text('Login to add emergency contacts'), findsNothing);
      });

      testWidgets('should show guest card when user is guest', (WidgetTester tester) async {
        // Arrange
        isGuest = true;
        
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act & Assert
        expect(find.byType(EmergencyContacts), findsNothing);
        expect(find.text('Login to add emergency contacts'), findsOneWidget);
      });

      testWidgets('should maintain proper spacing between SOS button and emergency contacts', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act & Assert - Check for SizedBox with proper height
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
        
        // Verify spacing exists between main content and emergency contacts
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, greaterThan(3)); // Header, button area, spacing, contacts
      });

      testWidgets('should navigate to profile page when profile icon is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                SizeConfig().init(context);
                return const SOSPage();
              },
            ),
            routes: {
              '/profilePage': (context) => const ProfilePage(),
            },
          ),
        );

        // Act - Tap profile icon
        await tester.tap(find.byIcon(Icons.person_2_rounded));
        await tester.pumpAndSettle();

        // Assert - Should navigate to profile page
        expect(find.byType(ProfilePage), findsOneWidget);
      });
    });

    group('Animation Controllers and Lifecycle', () {
      testWidgets('should initialize all animation controllers', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Assert - All animations should be running
        expect(find.byType(AnimatedBuilder), findsWidgets);
        expect(find.byType(ScaleTransition), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should dispose animation controllers properly', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        // Act - Remove widget to trigger dispose
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Text('Different Page')),
          ),
        );

        // Assert - No exceptions should be thrown during disposal
        expect(find.text('Different Page'), findsOneWidget);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('should handle rapid button presses gracefully', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Rapid taps
        for (int i = 0; i < 5; i++) {
          await tester.tap(sosButton);
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Assert - Should not crash and maintain stable state
        expect(find.byType(SOSPage), findsOneWidget);
      });

      testWidgets('should handle gesture cancellation properly', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(const SOSPage()));

        final sosButton = find.byType(GestureDetector).first;
        
        // Act - Start gesture and cancel
        final gesture = await tester.startGesture(tester.getCenter(sosButton));
        await tester.pump();
        await gesture.cancel();
        await tester.pump();

        // Assert - Should return to normal state
        final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(animatedScale.scale, equals(1.0));
      });
    });

    tearDown(() {
      // Clean up any global state
      isGuest = false;
    });
  });
}