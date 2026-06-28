// lib/features/breathing/exercises/diaphragmatic_breathing_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/services/audio_service.dart';
import 'package:pranaverse/core/services/tts_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'dart:async';

class DiaphragmaticBreathingScreen extends StatefulWidget {
  const DiaphragmaticBreathingScreen({super.key});

  @override
  State<DiaphragmaticBreathingScreen> createState() =>
      _DiaphragmaticBreathingScreenState();
}

class _DiaphragmaticBreathingScreenState
    extends State<DiaphragmaticBreathingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _adTimer;
  int _sessionSeconds = 0;
  bool _adShown = false;
  static const int _adTriggerSeconds = 180;

  int _cycleCount = 0;
  bool _isActive = false;
  String _currentPhase = 'inhale';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentPhase = 'exhale');
        _ttsService.speak("Exhale slowly through your mouth");
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentPhase = 'inhale';
          _cycleCount++;
        });
        if (_isActive && _cycleCount < 20) {
          _ttsService.speak("Breathe in deeply through your nose");
          _controller.forward();
        } else if (_cycleCount >= 20) {
          _completeExercise();
        }
      }
    });

    _startAdTimer();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _sessionSeconds++;
      if (!_adShown && _sessionSeconds >= _adTriggerSeconds) {
        _adShown = true;
        t.cancel();
        AdService().showInterstitial();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _adTimer?.cancel();
    _audioService.stopSound();
    _ttsService.stop();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _cycleCount = 0;
      _currentPhase = 'inhale';
    });
    _audioService.setVolume(0.3);
    _audioService.playSound('ocean');
    _ttsService.speak(
        "Place one hand on your chest and one on your belly. Breathe in deeply through your nose.");
    _controller.forward();
  }

  void _pauseExercise() {
    setState(() => _isActive = false);
    _controller.stop();
    _audioService.pauseSound();
    _ttsService.stop();
  }

  void _resumeExercise() {
    setState(() => _isActive = true);
    _audioService.resumeSound();
    if (_currentPhase == 'inhale') {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _resetExercise() {
    setState(() {
      _isActive = false;
      _cycleCount = 0;
      _currentPhase = 'inhale';
    });
    _controller.reset();
    _audioService.stopSound();
    _ttsService.stop();
  }

  void _completeExercise() {
    _controller.reset();
    _audioService.stopSound();
    _ttsService.speak(
        "Wonderful! You have completed 20 cycles of diaphragmatic breathing.");
    setState(() => _isActive = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppCopy.of(context, 'Great Job!'),
            style: const TextStyle(color: Colors.white)),
        content: Text(
          AppCopy.of(context,
              'You have completed 20 cycles of diaphragmatic breathing.'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.canPop() ? context.pop() : context.go('/main');
            },
            child: Text(AppCopy.of(context, 'Done'),
                style: const TextStyle(color: Color(0xFF4361ee))),
          ),
        ],
      ),
    );
  }

  BreathPhase get _scenePhase {
    if (!_isActive) return BreathPhase.idle;
    if (_currentPhase == 'inhale') return BreathPhase.inhale;
    if (_currentPhase == 'hold') return BreathPhase.hold;
    return BreathPhase.exhale;
  }

  String get _sceneInstruction {
    if (!_isActive) return AppCopy.of(context, 'Begin when ready...');
    if (_currentPhase == 'inhale') {
      return AppCopy.of(context, 'Breathe deep into your belly...');
    }
    if (_currentPhase == 'hold') return AppCopy.of(context, 'Hold gently...');
    return AppCopy.of(context, 'Release slowly...');
  }

  @override
  Widget build(BuildContext context) {
    const phaseColor = Color(0xFF4361ee);
    final isInhale = _currentPhase == 'inhale';
    return ExerciseSceneShell(
      title: AppCopy.of(context, 'Deep Diaphragmatic'),
      breathPhase: _scenePhase,
      instruction: _sceneInstruction,
      isActive: _isActive,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
      headerActions: [
        GestureDetector(
          onTap: _isActive
              ? _pauseExercise
              : (_cycleCount == 0 ? _startExercise : _resumeExercise),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Icon(_isActive ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 20),
          ),
        ),
      ],
      bottomPanel: _buildPanel(phaseColor, isInhale),
    );
  }

  Widget _buildPanel(Color phaseColor, bool isInhale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final s = 0.7 + _controller.value * 0.6;
              return Container(
                width: 120 * s,
                height: 120 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: phaseColor.withAlpha(60),
                  border: Border.all(color: phaseColor, width: 2),
                  boxShadow: [
                    BoxShadow(color: phaseColor.withAlpha(80), blurRadius: 20)
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isInhale ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.white, size: 26),
                      Text(
                        isInhale
                            ? AppCopy.of(context, 'Inhale').toUpperCase()
                            : (_currentPhase == 'hold'
                                ? AppCopy.of(context, 'Hold').toUpperCase()
                                : AppCopy.of(context, 'Exhale').toUpperCase()),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(AppCopy.of(context, 'Cycles: {count}',
                  vars: {'count': _cycleCount}),
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isActive && _cycleCount == 0)
                _btn(Icons.play_arrow, AppCopy.of(context, 'Start'),
                    Colors.green, _startExercise)
              else if (!_isActive)
                _btn(Icons.play_arrow, AppCopy.of(context, 'Resume'),
                    Colors.orange, _resumeExercise)
              else
                _btn(Icons.pause, AppCopy.of(context, 'Pause'), Colors.red,
                    _pauseExercise),
              if (_cycleCount > 0 || _isActive) ...[
                const SizedBox(width: 12),
                _btn(Icons.refresh, AppCopy.of(context, 'Reset'), Colors.blue,
                    _resetExercise),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withAlpha(120)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
