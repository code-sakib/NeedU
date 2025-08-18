import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needu/profile_page.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;

  AnimationController? _glowController;
  AnimationController? _particleController;
  AnimationController? _timerController; // 3s countdown

  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _timerController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // pretend SOS triggered
        HapticFeedback.heavyImpact();
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚨 Emergency SOS Activated!")),
        );
      }
    });
  }

  void _startSOSTimer() {
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);

    // start fake recording
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _recordingSeconds++);
      if (_recordingSeconds >= 10) {
        _stopRecording();
      }
    });

    _timerController!.forward(from: 0.0);
  }

  void _cancelSOSTimer() {
    setState(() => _isPressed = false);
    _timerController!.reverse();
    _stopRecording();
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
  }

  @override
  void dispose() {
    _glowController?.dispose();
    _particleController?.dispose();
    _timerController?.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  Widget _buildParticle(int index) {
    final animation = _particleController!;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final angle = (index / 12) * 2 * pi + t * 2 * pi;
        final radius = 80 + (20 * sin((t * 2 * pi) + index));
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: 0.6 + 0.4 * sin(t * 2 * pi + index),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 6, spreadRadius: 1)],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  ),
                  icon: Icon(Icons.person_2_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stay Safe', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Press and hold SOS for 3 seconds to activate emergency alert',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 380,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(
                        begin: 0.8,
                        end: 1.1,
                      ).animate(_glowController!),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.25),
                              theme.colorScheme.primaryContainer.withOpacity(
                                0.25,
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

                            if (_isPressed)
                              AnimatedBuilder(
                                animation: _timerController!,
                                builder: (context, child) {
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
                              onTapDown: (_) => _startSOSTimer(),
                              onTapUp: (_) => _cancelSOSTimer(),
                              onTapCancel: () => _cancelSOSTimer(),
                              child: AnimatedScale(
                                scale: _isPressed ? 0.95 : 1.0,
                                duration: const Duration(milliseconds: 150),
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
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isRecording
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.mic,
                                                size: 60,
                                                color:
                                                    theme.colorScheme.onPrimary,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'REC ${_recordingSeconds}s',
                                                style: theme
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onPrimary,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Column(
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
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .background,
                                                      fontSize: 48,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
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

              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recording emergency message...',
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: const [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Location will be shared if available',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: const [
                                  Icon(Icons.mic),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Audio message will be recorded if available',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Emergency Contacts',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: const [
                            Icon(Icons.person, size: 32),
                            SizedBox(height: 8),
                            Text('No emergency contacts added'),
                            SizedBox(height: 4),
                            Text('Add contacts in your Profile'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  _TimerPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 6;

    final basePaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, basePaint);

    final sweep = 2 * pi * progress;
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
