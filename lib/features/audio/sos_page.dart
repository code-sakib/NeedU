// sos_page_and_audio_services.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/audio/emergency_contacts.dart';
import 'package:needu/profile_page.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:needu/utilis/snackbar.dart';

/// ---------------------------------------------------------------------------
/// Updates Summary:
/// - Recording now starts ONLY after 3s trigger, lasts for 30s (handled in AudioServices2 via new recordAndUpload method).
/// - Service handles: start, 30s delay, stop, upload, returns URL or null (success/failure).
/// - Page calls service after trigger, awaits result, shows snackbars for recording start, upload success/fail.
/// - Removed UI changes: No mic icon, no 'REC Xs' text in button, no recording status below button.
/// - States updated: Added _isProcessing to disable button during recording/upload (prevent multiple triggers).
/// - Particles: Increased base radius to 150 + 50*sin (100-200 range) to spread out beyond button (button radius 100).
///   - Made nicely visible: Increased size to 12x12, opacity 0.8 + 0.2*sin, boxShadow blur 10/spread 2/color with alpha 0.5.
/// - No _isRecording or _recordingSeconds in page (handled in service, no UI display).
/// - Flow: Press -> 3s countdown -> trigger (snackbar), start recording (snackbar), 30s record -> upload -> snackbar success/fail, reset.
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// SOSPage - Updated for 30s recording after trigger, minimal UI changes
/// ---------------------------------------------------------------------------
class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> with TickerProviderStateMixin {
  // _isPressed: Tracks if the SOS button is currently being pressed down (for visual scaling during 3s countdown).
  bool _isPressed = false;
  // _sosTriggered: Becomes true after 3s countdown finishes (SOS is "triggered", starts processing).
  bool _sosTriggered = false;
  // _isProcessing: True during recording/upload after trigger (disables button to prevent multiple presses).
  bool _isProcessing = false;

  // _glowController: Animation for glowing effect around button (repeats for visual feedback).
  AnimationController? _glowController;
  // _particleController: Animation for particle effects around button (repeats for dynamic visuals).
  AnimationController? _particleController;
  // _timerController: Controls the 3s countdown animation (progress circle and number).
  AnimationController? _timerController;

  @override
  void initState() {
    super.initState();

    // Initialize glow animation: Duration 2s, repeats with reverse for pulsing effect.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Initialize particle animation: Duration 4s, repeats for continuous movement.
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Initialize timer animation: Duration 3s for countdown.
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Add listener to timer: When 3s completes, trigger SOS and start processing.
    _timerController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Countdown done: Call method to handle SOS trigger and start recording/upload.
        _onSOSTriggered();
      }
    });
  }

  /// Called when 3s countdown completes: Marks SOS as triggered, provides haptic feedback, shows snackbar,
  /// starts recording and upload process via service.
  void _onSOSTriggered() async {
    // Haptic feedback: Heavy impact for user confirmation.
    HapticFeedback.heavyImpact();

    // Update state: SOS triggered, release press visual (shrink button).

    //kept it here so that guest could enjoy the little animation 🥲
    if (isGuest) {
      Utilis.showSnackBar('Login to trigger SOS 🙂', isErr: true);
      return;
    }

    setState(() {
      _sosTriggered = true;
      _isPressed = false;
      _isProcessing = true; // Disable button during processing.
    });

    // Show trigger success snackbar.
    Utilis.showSnackBar('Service Triggered!!');

    // Start recording and upload via service (handles 30s internally).
    Utilis.showSnackBar('Recording emergency message...');
    // final url = await AudioServices2.instance.recordInSafeChunks();

    // Update UI based on result: Show success or failure snackbar.
    // if (finalPath != null) {
    //   Utilis.showSnackBar('Recording uploaded successfully');
    //   debugPrint('Uploaded sos recording: $finalPath');
    // } else {
    //   Utilis.showSnackBar('Recording or upload failed', isErr: true);
    // }

    // Reset states after processing.
    _resetSosState();
  }

  /// Starts the SOS countdown: Sets press state, starts 3s animation (no recording yet).
  void _startSOSTimer() async {
    // If already processing, ignore press.
    if (_isProcessing) return;

    // Update state: Button pressed, reset triggered flag.
    setState(() {
      _isPressed = true;
      _sosTriggered = false;
    });

    // Start the 3s countdown animation (visual progress circle).
    _timerController!.forward(from: 0.0);
  }

  /// Cancels the SOS if not yet triggered: Reverses animation, resets press state (no processing to stop).
  void _cancelSOSTimer() {
    // If not pressed, nothing to cancel.
    if (!_isPressed) return;

    // If SOS already triggered (after 3s), do not cancel — processing must complete.
    if (_sosTriggered) return;

    // Update state: Release press visual.
    setState(() => _isPressed = false);
    // Reverse the countdown animation.
    _timerController!.reverse();
    // No processing started yet, so no need to stop anything else.
  }

  /// Resets all SOS states to initial (ready for next press).
  void _resetSosState() {
    setState(() {
      _sosTriggered = false;
      _isPressed = false;
      _isProcessing = false; // Re-enable button.
    });
  }

  @override
  void dispose() {
    // Dispose animations to free resources.
    _glowController?.dispose();
    _particleController?.dispose();
    _timerController?.dispose();
    super.dispose();
  }

  /// Builds a single particle widget: Animates position and opacity for effect.
  Widget _buildParticle(int index) {
    // Use particle controller for animation value.
    final animation = _particleController!;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // t: Current animation progress (0-1).
        final t = animation.value;
        // angle: Particle's base angle + rotation over time.
        final angle = (index / 12) * 2 * pi + t * 2 * pi;
        // radius: Increased to 150 + 50*sin for spread out (100-200 range, beyond button radius 100).
        final radius = 80 + (30 * sin((t * 2 * pi) + index));
        // dx, dy: Calculate offset from center.
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            // opacity: Increased base to 0.8 + 0.2*sin for better visibility.
            opacity: 0.8 + 0.2 * sin(t * 2 * pi + index),
            child: Container(
              // Increased size to 12x12 for nicer visibility.
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                // Enhanced shadow: blur 10, spread 2, color with alpha 0.5 for glow effect.
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(128), // alpha 0.5
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // theme: Current app theme for colors/text styles.
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.screenVPadding,
            horizontal: SizeConfig.screenHPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stay Safe 2', style: theme.textTheme.titleLarge),
                  IconButton(
                    onPressed: () => context.go('/profilePage'),
                    icon: const Icon(Icons.person_2_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Hold 3 secs to trigger alert!'),

              const SizedBox(height: 24),

              Center(
                child: SizedBox(
                  height: SizeConfig.blockHeight * 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.8,
                          end: 1.1,
                        ).animate(_glowController!),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.25,
                                ),
                                theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.25,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(140),
                          ),
                        ),
                      ),

                      ...List.generate(12, (i) => _buildParticle(i)),

                      Positioned(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _timerController!,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: const Size(220, 220),
                                    painter: _TimerPainter(
                                      _timerController!.value,
                                      theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),

                              if (_isPressed && !_sosTriggered)
                                AnimatedBuilder(
                                  animation: _timerController!,
                                  builder: (context, child) {
                                    // remain: Calculate remaining seconds in countdown (ceil to int), shown during press before trigger.
                                    final remain =
                                        (3 - (_timerController!.value * 3))
                                            .ceil();
                                    return Text(
                                      '$remain',
                                      style: theme.textTheme.headlineMedium!
                                          .copyWith(
                                            color: theme.colorScheme.primary,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    );
                                  },
                                ),

                              GestureDetector(
                                // onTapDown: Start SOS countdown (if not processing).
                                onTapDown: (_) => _startSOSTimer(),
                                // onTapUp: Attempt cancel (only if before trigger).
                                onTapUp: (_) => _cancelSOSTimer(),
                                // onTapCancel: Attempt cancel (for gestures).
                                onTapCancel: () => _cancelSOSTimer(),
                                child: AnimatedScale(
                                  // scale: Shrink button slightly when pressed.
                                  scale: _isPressed ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Opacity(
                                    // Dim button slightly during processing (visual feedback without changing icon/text).
                                    opacity: _isProcessing ? 0.7 : 1.0,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primaryContainer,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shield,
                                              size: 64,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'SOS',
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .surface,
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.defaultHeight2),
              isGuest ? guestEcCard(context) : EmergencyContacts(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  // progress: Fraction of countdown completed (0-1).
  final double progress;
  // color: Color for the progress arc.
  final Color color;
  _TimerPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // center: Center point of the circle.
    final center = Offset(size.width / 2, size.height / 2);
    // radius: Circle radius, adjusted for stroke width.
    final radius = min(size.width, size.height) / 2 - 6;

    // basePaint: For the background circle (faint).
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // arcPaint: For the progress arc.
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Draw base circle.
    canvas.drawCircle(center, radius, basePaint);

    // sweep: Angle of progress arc (full circle at 2*pi).
    final sweep = 2 * pi * progress;
    // Draw progress arc starting from top (-pi/2).
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
