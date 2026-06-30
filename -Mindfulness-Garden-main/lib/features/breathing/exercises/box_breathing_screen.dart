import 'package:flutter/material.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/services/audio_service.dart';
import 'package:pranaverse/core/services/tts_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/presentation/providers/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _cycleTimer;
  Timer? _adTimer;
  int _currentSecond = 0;
  int _totalCycles = 0;
  BoxPhase _phase = BoxPhase.inhale;
  bool _isRunning = true;
  bool _showVisualGuide = true;

  // Ad: show interstitial after 3 minutes of use
  static const int _adTriggerSeconds = 180;
  int _sessionSeconds = 0;
  bool _adShown = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    );

    _borderAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.25), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.25, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 0.75), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.75, end: 1.0), weight: 1),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF00b4d8),
      end: const Color(0xFF38b000),
    ).animate(_controller);

    _playAmbientSound();
    _startBoxBreathing();
    _startAdTimer();
  }

  void _playAmbientSound() async {
    await _audioService.setVolume(0.3); // low background volume
    await _audioService.playSound('piano');
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      if (!_adShown && _sessionSeconds >= _adTriggerSeconds) {
        _adShown = true;
        timer.cancel();
        AdService().showInterstitial();
      }
    });
  }

  void _startBoxBreathing() {
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      setState(() {
        _currentSecond++;

        if (_currentSecond <= 4) {
          _phase = BoxPhase.inhale;
          if (_currentSecond == 1) {
            _ttsService.speak("Inhale for 4 seconds");
            _controller.animateTo(0.25, duration: const Duration(seconds: 4));
          }
        } else if (_currentSecond <= 8) {
          _phase = BoxPhase.holdInhale;
          if (_currentSecond == 5) {
            _ttsService.speak("Hold breath for 4 seconds");
          }
        } else if (_currentSecond <= 12) {
          _phase = BoxPhase.exhale;
          if (_currentSecond == 9) {
            _ttsService.speak("Exhale for 4 seconds");
            _controller.animateTo(0.75, duration: const Duration(seconds: 4));
          }
        } else if (_currentSecond <= 16) {
          _phase = BoxPhase.holdExhale;
          if (_currentSecond == 13) {
            _ttsService.speak("Hold empty for 4 seconds");
          }
        } else {
          _currentSecond = 0;
          _totalCycles++;
          _ttsService.speak("Box $_totalCycles complete");

          if (_totalCycles >= 4) {
            timer.cancel();
            _ttsService
                .speak("Excellent! 4 boxes complete. You're focused and calm!");
            setState(() => _phase = BoxPhase.complete);
            _controller.animateTo(1.0, duration: const Duration(seconds: 1));
            _completeSession();
          }
        }
      });
    });
  }

  String _getPhaseText() {
    switch (_phase) {
      case BoxPhase.inhale:
        return AppCopy.of(context, 'Inhale').toUpperCase();
      case BoxPhase.holdInhale:
        return AppCopy.of(context, 'Hold').toUpperCase();
      case BoxPhase.exhale:
        return AppCopy.of(context, 'Exhale').toUpperCase();
      case BoxPhase.holdExhale:
        return AppCopy.of(context, 'Hold Empty').toUpperCase();
      case BoxPhase.complete:
        return AppCopy.of(context, 'Complete').toUpperCase();
    }
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case BoxPhase.inhale:
        return const Color(0xFF00b4d8);
      case BoxPhase.holdInhale:
        return const Color(0xFF9d4edd);
      case BoxPhase.exhale:
        return const Color(0xFF38b000);
      case BoxPhase.holdExhale:
        return const Color(0xFFffb700);
      case BoxPhase.complete:
        return const Color(0xFFff6d00);
    }
  }

  IconData _getPhaseIcon() {
    switch (_phase) {
      case BoxPhase.inhale:
        return Icons.arrow_upward;
      case BoxPhase.holdInhale:
        return Icons.pause;
      case BoxPhase.exhale:
        return Icons.arrow_downward;
      case BoxPhase.holdExhale:
        return Icons.pause;
      case BoxPhase.complete:
        return Icons.check_circle;
    }
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startBoxBreathing();
      } else {
        _cycleTimer?.cancel();
        _ttsService.speak("Paused");
      }
    });
  }

  void _toggleGuide() => setState(() => _showVisualGuide = !_showVisualGuide);

  void _reset() {
    _cycleTimer?.cancel();
    setState(() {
      _currentSecond = 0;
      _totalCycles = 0;
      _phase = BoxPhase.inhale;
      _isRunning = true;
    });
    _controller.reset();
    _startBoxBreathing();
  }

  void _completeSession() {
    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.saveSession(
        durationMinutes: 5, meditationType: 'Box Breathing');
    VoiceService().speakComplete();
  }

  /// Maps BoxPhase → BreathPhase for the 2.5D scene
  BreathPhase get _scenePhase {
    switch (_phase) {
      case BoxPhase.inhale:
        return BreathPhase.inhale;
      case BoxPhase.holdInhale:
        return BreathPhase.hold;
      case BoxPhase.exhale:
        return BreathPhase.exhale;
      case BoxPhase.holdExhale:
        return BreathPhase.rest;
      case BoxPhase.complete:
        return BreathPhase.complete;
    }
  }

  String get _sceneInstruction {
    switch (_phase) {
      case BoxPhase.inhale:
        return AppCopy.of(context, 'Breathe in...');
      case BoxPhase.holdInhale:
        return AppCopy.of(context, 'Hold gently...');
      case BoxPhase.exhale:
        return AppCopy.of(context, 'Release...');
      case BoxPhase.holdExhale:
        return AppCopy.of(context, 'Hold empty...');
      case BoxPhase.complete:
        return AppCopy.of(context, 'Well done');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cycleTimer?.cancel();
    _adTimer?.cancel();
    _audioService.stopSound();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseColor = _getPhaseColor();

    return ExerciseSceneShell(
      title: AppCopy.of(context, 'Box Breathing'),
      breathPhase: _scenePhase,
      instruction: _sceneInstruction,
      isActive: _isRunning,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
      headerActions: [
        GestureDetector(
          onTap: _toggleGuide,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Icon(
              _showVisualGuide ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ),
        GestureDetector(
          onTap: _togglePause,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
      bottomPanel: _buildBottomPanel(phaseColor),
    );
  }

  Widget _buildBottomPanel(Color phaseColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Guide banner
          if (_showVisualGuide)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppCopy.of(context,
                    'Inhale 4s -> Hold 4s -> Exhale 4s -> Hold 4s  ·  Repeat 4x'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),

          // Box visualisation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: BoxPainter(
                    progress: _borderAnimation.value,
                    color: _colorAnimation.value ?? Colors.blue,
                    phase: _phase,
                    labels: [
                      AppCopy.of(context, 'Inhale'),
                      AppCopy.of(context, 'Hold'),
                      AppCopy.of(context, 'Exhale'),
                      AppCopy.of(context, 'Hold'),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Phase label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getPhaseIcon(), color: phaseColor, size: 22),
              const SizedBox(width: 8),
              Text(
                _getPhaseText(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: phaseColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentSecond % 17}s  ·  Box $_totalCycles/4',
                style: const TextStyle(fontSize: 14, color: Colors.white60),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Phase timeline
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBoxPhase(
                    AppCopy.of(context, 'Inhale'), 4, BoxPhase.inhale),
                _buildBoxPhase(
                    AppCopy.of(context, 'Hold'), 4, BoxPhase.holdInhale),
                _buildBoxPhase(
                    AppCopy.of(context, 'Exhale'), 4, BoxPhase.exhale),
                _buildBoxPhase(
                    AppCopy.of(context, 'Hold'), 4, BoxPhase.holdExhale),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Buttons
          if (_phase == BoxPhase.complete)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff6d00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(AppCopy.of(context, 'BOX BREATHE AGAIN'),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/main'),
                  child: Text(AppCopy.of(context, 'TRY ANOTHER EXERCISE'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(AppCopy.of(context, 'RESTART'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoxPhase(String label, int seconds, BoxPhase phase) {
    final isActive = _phase == phase;
    final color = _getPhaseColorForPhase(phase);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: isActive ? 1.0 : 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$seconds',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Color _getPhaseColorForPhase(BoxPhase phase) {
    switch (phase) {
      case BoxPhase.inhale:
        return const Color(0xFF00b4d8);
      case BoxPhase.holdInhale:
        return const Color(0xFF9d4edd);
      case BoxPhase.exhale:
        return const Color(0xFF38b000);
      case BoxPhase.holdExhale:
        return const Color(0xFFffb700);
      case BoxPhase.complete:
        return const Color(0xFFff6d00);
    }
  }
}

enum BoxPhase { inhale, holdInhale, exhale, holdExhale, complete }

class BoxPainter extends CustomPainter {
  final double progress;
  final Color color;
  final BoxPhase phase;
  final List<String> labels;

  BoxPainter(
      {required this.progress,
      required this.color,
      required this.phase,
      required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boxSize = size.width * 0.8;

    // Background box outline
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: boxSize, height: boxSize),
      bgPaint,
    );

    // Corner labels
    final textStyle =
        TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11);
    final labelPositions = [
      Offset(center.dx, center.dy - boxSize / 2 - 16),
      Offset(center.dx + boxSize / 2 + 4, center.dy),
      Offset(center.dx, center.dy + boxSize / 2 + 16),
      Offset(center.dx - boxSize / 2 - 4, center.dy),
    ];
    for (int i = 0; i < 4; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPositions[i] - Offset(tp.width / 2, tp.height / 2));
    }

    // Progress path
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final left = center.dx - boxSize / 2;
    final right = center.dx + boxSize / 2;
    final top = center.dy - boxSize / 2;
    final bottom = center.dy + boxSize / 2;

    if (progress <= 0.25) {
      path.moveTo(left, top);
      path.lineTo(left + (progress * 4 * boxSize), top);
    } else if (progress <= 0.5) {
      path.moveTo(left, top);
      path.lineTo(right, top);
      path.lineTo(right, top + ((progress - 0.25) * 4 * boxSize));
    } else if (progress <= 0.75) {
      path.moveTo(left, top);
      path.lineTo(right, top);
      path.lineTo(right, bottom);
      path.lineTo(right - ((progress - 0.5) * 4 * boxSize), bottom);
    } else {
      path.moveTo(left, top);
      path.lineTo(right, top);
      path.lineTo(right, bottom);
      path.lineTo(left, bottom);
      path.lineTo(left, bottom - ((progress - 0.75) * 4 * boxSize));
    }
    canvas.drawPath(path, progressPaint);

    // Moving dot
    Offset dot;
    if (progress <= 0.25) {
      dot = Offset(left + (progress * 4 * boxSize), top);
    } else if (progress <= 0.5) {
      dot = Offset(right, top + ((progress - 0.25) * 4 * boxSize));
    } else if (progress <= 0.75) {
      dot = Offset(right - ((progress - 0.5) * 4 * boxSize), bottom);
    } else {
      dot = Offset(left, bottom - ((progress - 0.75) * 4 * boxSize));
    }
    canvas.drawCircle(dot, 10, Paint()..color = color);
    canvas.drawCircle(
        dot,
        10,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant BoxPainter old) =>
      progress != old.progress ||
      color != old.color ||
      phase != old.phase ||
      labels != old.labels;
}
