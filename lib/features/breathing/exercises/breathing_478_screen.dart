import 'package:flutter/material.dart';
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

class Breathing478Screen extends StatefulWidget {
  const Breathing478Screen({super.key});

  @override
  State<Breathing478Screen> createState() => _Breathing478ScreenState();
}

class _Breathing478ScreenState extends State<Breathing478Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _cycleTimer;
  int _currentSecond = 0;
  int _totalCycles = 0;
  BreathingPhase _phase = BreathingPhase.inhale;
  bool _isRunning = true;
  bool _showGuide = true;

  // Ad timer
  Timer? _adTimer;
  int _sessionSeconds = 0;
  bool _adShown = false;
  static const int _adTriggerSeconds = 180;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.8), weight: 1),
    ]).animate(_controller);

    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _playAmbientSound();
    _startBreathingCycle();
    _startAdTimer();
  }

  void _playAmbientSound() async {
    await _audioService.setVolume(0.3);
    await _audioService.playSound('piano');
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

  void _startBreathingCycle() {
    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      setState(() {
        _currentSecond++;

        // 4-7-8 breathing pattern
        if (_currentSecond <= 4) {
          _phase = BreathingPhase.inhale;
          if (_currentSecond == 1) {
            _ttsService.speak("Inhale for 4 seconds");
            _controller.forward();
          }
        } else if (_currentSecond <= 11) {
          _phase = BreathingPhase.hold;
          if (_currentSecond == 5) {
            _ttsService.speak("Hold for 7 seconds");
            _controller.animateTo(
              0.5,
              duration: const Duration(milliseconds: 500),
            );
          }
        } else if (_currentSecond <= 19) {
          _phase = BreathingPhase.exhale;
          if (_currentSecond == 12) {
            _ttsService.speak("Exhale slowly for 8 seconds");
            _controller.reverse();
          }
        } else {
          _currentSecond = 0;
          _totalCycles++;
          _ttsService.speak("Cycle $_totalCycles complete");

          if (_totalCycles >= 4) {
            timer.cancel();
            _ttsService.speak(
              "Excellent! 4 cycles complete. You're doing great!",
            );
            _phase = BreathingPhase.complete;
            _completeSession();
          }
        }
      });
    });
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case BreathingPhase.inhale:
        return Color.lerp(
          const Color(0xFF00b4d8),
          const Color(0xFF0077b6),
          _colorAnimation.value,
        )!;
      case BreathingPhase.hold:
        return const Color(0xFF9d4edd);
      case BreathingPhase.exhale:
        return Color.lerp(
          const Color(0xFF38b000),
          const Color(0xFF008000),
          _colorAnimation.value,
        )!;
      case BreathingPhase.complete:
        return const Color(0xFFffb700);
    }
  }

  String _getPhaseText() {
    switch (_phase) {
      case BreathingPhase.inhale:
        return 'INHALE';
      case BreathingPhase.hold:
        return 'HOLD';
      case BreathingPhase.exhale:
        return 'EXHALE';
      case BreathingPhase.complete:
        return 'COMPLETE';
    }
  }

  String _getTimeRemaining() {
    switch (_phase) {
      case BreathingPhase.inhale:
        return '${5 - _currentSecond}s';
      case BreathingPhase.hold:
        return '${12 - _currentSecond}s';
      case BreathingPhase.exhale:
        return '${20 - _currentSecond}s';
      case BreathingPhase.complete:
        return '';
    }
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startBreathingCycle();
      } else {
        _cycleTimer?.cancel();
        _ttsService.speak("Paused");
      }
    });
  }

  void _toggleGuide() {
    setState(() {
      _showGuide = !_showGuide;
    });
  }

  void _reset() {
    setState(() {
      _currentSecond = 0;
      _totalCycles = 0;
      _phase = BreathingPhase.inhale;
      _isRunning = true;
    });
    _cycleTimer?.cancel();
    _startBreathingCycle();
  }

  void _completeSession() {
    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.saveSession(
      durationMinutes: 4,
      meditationType: '4-7-8 Breathing',
    );
    VoiceService().speakComplete();
  }

  BreathPhase get _scenePhase {
    switch (_phase) {
      case BreathingPhase.inhale:
        return BreathPhase.inhale;
      case BreathingPhase.hold:
        return BreathPhase.hold;
      case BreathingPhase.exhale:
        return BreathPhase.exhale;
      case BreathingPhase.complete:
        return BreathPhase.complete;
    }
  }

  String get _sceneInstruction {
    switch (_phase) {
      case BreathingPhase.inhale:
        return 'Breathe in... 4 seconds';
      case BreathingPhase.hold:
        return 'Hold... 7 seconds';
      case BreathingPhase.exhale:
        return 'Release... 8 seconds';
      case BreathingPhase.complete:
        return 'Well done 🙏';
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
    return ExerciseSceneShell(
      title: '4-7-8 Breathing',
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
            child: Icon(_showGuide ? Icons.info : Icons.info_outline,
                color: Colors.white70, size: 18),
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
            child: Icon(_isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 20),
          ),
        ),
      ],
      bottomPanel: _buildBottomPanel(),
    );
  }

  Widget _buildBottomPanel() {
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

          if (_showGuide)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Inhale 4s → Hold 7s → Exhale 8s  ·  Repeat 4×',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),

          // Progress ring + phase display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _currentSecond / 20,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withAlpha(25),
                  valueColor: AlwaysStoppedAnimation(_getPhaseColor()),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPhaseColor().withAlpha(60),
                      border: Border.all(color: _getPhaseColor(), width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_getPhaseText(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.5)),
                          if (_phase != BreathingPhase.complete)
                            Text(_getTimeRemaining(),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                          Text('Cycle: $_totalCycles/4',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Phase indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPhaseIndicator('Inhale', '4s',
                  isActive: _phase == BreathingPhase.inhale,
                  color: const Color(0xFF00b4d8)),
              _buildPhaseIndicator('Hold', '7s',
                  isActive: _phase == BreathingPhase.hold,
                  color: const Color(0xFF9d4edd)),
              _buildPhaseIndicator('Exhale', '8s',
                  isActive: _phase == BreathingPhase.exhale,
                  color: const Color(0xFF38b000)),
            ],
          ),

          const SizedBox(height: 12),

          if (_phase == BreathingPhase.complete)
            Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFffb700),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('START AGAIN',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/main'),
                child: const Text('BACK TO EXERCISES',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ])
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
                child: const Text('RESET',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(String label, String time,
      {required bool isActive, required Color color}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.white.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(
                color: color.withAlpha(isActive ? 200 : 80), width: 2),
          ),
          child: Center(
            child: Text(time,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : color,
                )),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.white60,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            )),
      ],
    );
  }
}

enum BreathingPhase { inhale, hold, exhale, complete }
