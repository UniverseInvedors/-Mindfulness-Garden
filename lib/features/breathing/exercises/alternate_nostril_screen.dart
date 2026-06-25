// lib/features/breathing/exercises/alternate_nostril_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/services/audio_service.dart';
import 'package:pranaverse/core/services/tts_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'dart:async';

class AlternateNostrilScreen extends StatefulWidget {
  const AlternateNostrilScreen({super.key});

  @override
  State<AlternateNostrilScreen> createState() => _AlternateNostrilScreenState();
}

class _AlternateNostrilScreenState extends State<AlternateNostrilScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathController;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _adTimer;
  int _sessionSeconds = 0;
  bool _adShown = false;
  static const int _adTriggerSeconds = 180;

  int _currentPhase = 0;
  int _roundsCompleted = 0;
  final int _totalRounds = 10;
  bool _isActive = false;

  final List<String> _phaseInstructions = [
    "Close right nostril\nInhale through left",
    "Hold breath\n(both nostrils closed)",
    "Close left nostril\nExhale through right",
    "Inhale through\nright nostril",
    "Hold breath",
    "Exhale through\nleft nostril",
  ];

  final List<String> _ttsInstructions = [
    "Close your right nostril and inhale through the left",
    "Hold your breath",
    "Close your left nostril and exhale through the right",
    "Inhale through your right nostril",
    "Hold your breath",
    "Exhale through your left nostril",
  ];

  final List<Color> _phaseColors = [
    const Color(0xFF00b4d8),
    const Color(0xFF9d4edd),
    const Color(0xFF38b000),
    const Color(0xFF00b4d8),
    const Color(0xFF9d4edd),
    const Color(0xFF38b000),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

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
    _pulseController.dispose();
    _breathController.dispose();
    _adTimer?.cancel();
    _audioService.stopSound();
    _ttsService.stop();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _roundsCompleted = 0;
      _currentPhase = 0;
    });
    _audioService.setVolume(0.3);
    _audioService.playSound('bowl');
    _startPhase(0);
  }

  void _startPhase(int phase) {
    if (!mounted) return;
    setState(() => _currentPhase = phase);
    _ttsService.speak(_ttsInstructions[phase]);
    _breathController.duration = const Duration(seconds: 4);
    _breathController.forward(from: 0).then((_) {
      if (_isActive) _nextPhase();
    });
  }

  void _nextPhase() {
    if (!_isActive || !mounted) return;
    int next = _currentPhase + 1;
    if (next >= 6) {
      next = 0;
      setState(() => _roundsCompleted++);
      if (_roundsCompleted >= _totalRounds) {
        _completeExercise();
        return;
      }
    }
    _startPhase(next);
  }

  void _pauseExercise() {
    setState(() => _isActive = false);
    _breathController.stop();
    _audioService.pauseSound();
    _ttsService.stop();
  }

  void _resumeExercise() {
    setState(() => _isActive = true);
    _audioService.resumeSound();
    _breathController.forward();
  }

  void _resetExercise() {
    setState(() {
      _isActive = false;
      _roundsCompleted = 0;
      _currentPhase = 0;
    });
    _breathController.reset();
    _audioService.stopSound();
    _ttsService.stop();
  }

  void _completeExercise() {
    _breathController.reset();
    _audioService.stopSound();
    _ttsService.speak(
        "Excellent! You have completed 10 rounds of alternate nostril breathing.");
    setState(() => _isActive = false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exercise Complete!',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Great job! You\'ve completed 10 rounds of Alternate Nostril Breathing.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.canPop() ? context.pop() : context.go('/main');
            },
            child:
                const Text('Done', style: TextStyle(color: Color(0xFF9d4edd))),
          ),
        ],
      ),
    );
  }

  BreathPhase get _scenePhase {
    if (!_isActive) return BreathPhase.idle;
    // phases 0,3 = inhale; 1,4 = hold; 2,5 = exhale
    if (_currentPhase == 0 || _currentPhase == 3) return BreathPhase.inhale;
    if (_currentPhase == 1 || _currentPhase == 4) return BreathPhase.hold;
    return BreathPhase.exhale;
  }

  String get _sceneInstruction =>
      _phaseInstructions[_currentPhase].replaceAll('\n', ' ');

  Color get _currentColor => _phaseColors[_currentPhase];

  @override
  Widget build(BuildContext context) {
    return ExerciseSceneShell(
      title: 'Alternate Nostril',
      breathPhase: _scenePhase,
      instruction: _sceneInstruction,
      isActive: _isActive,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
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

          // Instruction card
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _currentColor.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _currentColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                Text(_phaseInstructions[_currentPhase],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
                const SizedBox(height: 10),
                // Phase dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      6,
                      (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentPhase ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _currentPhase
                                  ? _currentColor
                                  : Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _roundsCompleted / _totalRounds,
                    minHeight: 6,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(_currentColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$_roundsCompleted/$_totalRounds',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),

          const SizedBox(height: 12),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isActive && _roundsCompleted == 0)
                _buildBtn(
                    Icons.play_arrow, 'Start', Colors.green, _startExercise)
              else if (!_isActive)
                _buildBtn(
                    Icons.play_arrow, 'Resume', Colors.orange, _resumeExercise)
              else
                _buildBtn(Icons.pause, 'Pause', Colors.red, _pauseExercise),
              if (_roundsCompleted > 0 || _isActive) ...[
                const SizedBox(width: 12),
                _buildBtn(Icons.refresh, 'Reset', Colors.blue, _resetExercise),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}
