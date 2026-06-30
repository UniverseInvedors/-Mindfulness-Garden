import 'package:flutter/material.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/services/audio_service.dart';
import 'package:pranaverse/core/services/tts_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/presentation/providers/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class BreathAwarenessScreen extends StatefulWidget {
  const BreathAwarenessScreen({super.key});

  @override
  State<BreathAwarenessScreen> createState() => _BreathAwarenessScreenState();
}

class _BreathAwarenessScreenState extends State<BreathAwarenessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _meditationTimer;
  Timer? _instructionTimer;
  int _remainingSeconds = 600; // 10 minutes
  bool _isPlaying = false;
  bool _isPaused = false;
  List<String> _instructions = [];
  int _currentInstruction = 0;
  MeditationPhase _phase = MeditationPhase.preparation;

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

    _breathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _setupInstructions();
    _playAmbientSound();
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

  void _setupInstructions() {
    _instructions = [
      "Find a comfortable position...",
      "Close your eyes gently...",
      "Bring your attention to your breath...",
      "Notice the natural rhythm of your breathing...",
      "Don't try to change it, just observe...",
      "Feel the air entering your nostrils...",
      "Notice the temperature of the breath...",
      "Feel your chest and abdomen rise and fall...",
      "If your mind wanders, gently bring it back...",
      "Continue observing your breath...",
      "Notice the space between breaths...",
      "Stay with the sensation of breathing...",
      "Observe without judgment...",
      "Allow thoughts to come and go...",
      "Return to the breath...",
      "Feel the present moment...",
      "Gently bring awareness back to your body...",
      "When you're ready, open your eyes...",
    ];
  }

  void _playAmbientSound() async {
    await _audioService.setVolume(0.3);
    await _audioService.playSound('piano');
  }

  void _startMeditation() {
    setState(() {
      _isPlaying = true;
      _phase = MeditationPhase.preparation;
    });

    // Start breathing animation
    _controller.repeat(reverse: true);

    // Start meditation timer
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;

            // Progress through phases
            if (_remainingSeconds == 540) {
              // After 1 minute
              _phase = MeditationPhase.focusing;
              _speakInstruction("Bring your attention to your breath...");
            } else if (_remainingSeconds == 300) {
              // After 5 minutes
              _phase = MeditationPhase.deepening;
              _speakInstruction("Notice the subtle sensations of breathing...");
            } else if (_remainingSeconds == 60) {
              // Last minute
              _phase = MeditationPhase.closing;
              _speakInstruction("Begin to bring your awareness back...");
            } else if (_remainingSeconds == 0) {
              _completeMeditation();
              timer.cancel();
            }

            // Give random gentle reminders
            if (_remainingSeconds % 120 == 0 && _remainingSeconds > 60) {
              _speakInstruction(
                _instructions[_currentInstruction % _instructions.length],
              );
              _currentInstruction++;
            }
          }
        });
      }
    });

    // Give initial instruction
    _speakInstruction("Let's begin our breath awareness practice...");
  }

  void _pauseMeditation() {
    setState(() {
      _isPaused = true;
      _controller.stop();
    });

    _ttsService.speak("Meditation paused");
  }

  void _resumeMeditation() {
    setState(() {
      _isPaused = false;
      _controller.repeat(reverse: true);
    });

    _ttsService.speak("Resuming meditation");
  }

  void _completeMeditation() {
    setState(() {
      _isPlaying = false;
      _phase = MeditationPhase.complete;
      _controller.stop();
    });

    // Save session
    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.saveSession(
      durationMinutes: 10,
      meditationType: 'Breath Awareness',
    );

    // Speak completion message
    _ttsService.speak("Meditation complete. Well done.");

    // Play completion sound
    _audioService.playSound('bowl');
  }

  Future<void> _speakInstruction(String text) async {
    await _ttsService.speak(text);
  }

  String _getPhaseTitle() {
    switch (_phase) {
      case MeditationPhase.preparation:
        return AppCopy.of(context, 'Preparation');
      case MeditationPhase.focusing:
        return AppCopy.of(context, 'Focusing');
      case MeditationPhase.deepening:
        return AppCopy.of(context, 'Deepening');
      case MeditationPhase.closing:
        return AppCopy.of(context, 'Closing');
      case MeditationPhase.complete:
        return AppCopy.of(context, 'Complete');
    }
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case MeditationPhase.preparation:
        return Colors.blue;
      case MeditationPhase.focusing:
        return Colors.green;
      case MeditationPhase.deepening:
        return Colors.purple;
      case MeditationPhase.closing:
        return Colors.orange;
      case MeditationPhase.complete:
        return Colors.green;
    }
  }

  String _getTimerText() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _meditationTimer?.cancel();
    _instructionTimer?.cancel();
    _adTimer?.cancel();
    _audioService.stopSound();
    _ttsService.stop();
    super.dispose();
  }

  BreathPhase get _scenePhase {
    switch (_phase) {
      case MeditationPhase.preparation:
        return BreathPhase.idle;
      case MeditationPhase.focusing:
        return BreathPhase.inhale;
      case MeditationPhase.deepening:
        return BreathPhase.hold;
      case MeditationPhase.closing:
        return BreathPhase.exhale;
      case MeditationPhase.complete:
        return BreathPhase.complete;
    }
  }

  String get _sceneInstruction {
    if (!_isPlaying) return AppCopy.of(context, 'Begin when ready...');
    switch (_phase) {
      case MeditationPhase.preparation:
        return AppCopy.of(context, 'Find stillness...');
      case MeditationPhase.focusing:
        return AppCopy.of(context, 'Focus on your breath...');
      case MeditationPhase.deepening:
        return AppCopy.of(context, 'Deepen your awareness...');
      case MeditationPhase.closing:
        return AppCopy.of(context, 'Gently return...');
      case MeditationPhase.complete:
        return AppCopy.of(context, 'Well done');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseSceneShell(
      title: AppCopy.of(context, 'Breath Awareness'),
      breathPhase: _scenePhase,
      instruction: _sceneInstruction,
      isActive: _isPlaying && !_isPaused,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
      headerActions: [
        if (_isPlaying)
          GestureDetector(
            onTap: _isPaused ? _resumeMeditation : _pauseMeditation,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white, size: 20),
            ),
          ),
      ],
      bottomPanel: _buildBottomPanel(),
    );
  }

  Widget _buildBottomPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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

          // Phase + timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPhaseColor().withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getPhaseColor().withAlpha(120)),
                ),
                child: Text(_getPhaseTitle(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPhaseColor())),
              ),
              const SizedBox(width: 16),
              Text(_getTimerText(),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white)),
            ],
          ),

          const SizedBox(height: 16),

          // Breathing circle
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Container(
              width: 100 + _breathAnimation.value * 60,
              height: 100 + _breathAnimation.value * 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPhaseColor().withAlpha(60),
                border: Border.all(color: _getPhaseColor(), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withAlpha(80),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: const Center(
                  child: Icon(Icons.air, size: 32, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 16),

          // Controls
          if (!_isPlaying && _phase != MeditationPhase.complete)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMeditation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(AppCopy.of(context, 'BEGIN MEDITATION'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            )
          else if (_phase == MeditationPhase.complete)
            Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _remainingSeconds = 600;
                      _phase = MeditationPhase.preparation;
                    });
                    _startMeditation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(AppCopy.of(context, 'MEDITATE AGAIN'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/main'),
                child: Text(AppCopy.of(context, 'BACK TO MENU'),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ]),
        ],
      ),
    );
  }
}

enum MeditationPhase { preparation, focusing, deepening, closing, complete }
