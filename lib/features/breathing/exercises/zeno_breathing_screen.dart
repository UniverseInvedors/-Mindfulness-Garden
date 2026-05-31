import 'package:flutter/material.dart';
import 'package:mindfulness_garden/core/services/audio_service.dart';
import 'package:mindfulness_garden/core/services/tts_service.dart';
import 'package:mindfulness_garden/core/services/ad_service.dart';
import 'package:mindfulness_garden/core/services/localization_service.dart';
import 'package:mindfulness_garden/core/services/voice_service.dart';
import 'package:mindfulness_garden/core/widgets/exercise_scene_shell.dart';
import 'package:mindfulness_garden/core/widgets/meditation_scene_widget.dart';
import 'package:mindfulness_garden/presentation/providers/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class ZenoBreathingScreen extends StatefulWidget {
  final SceneEnvironment environment;
  final SceneTimeOfDay timeOfDay;

  const ZenoBreathingScreen({
    super.key,
    this.environment = SceneEnvironment.zenTemple,
    this.timeOfDay = SceneTimeOfDay.morning,
  });

  @override
  State<ZenoBreathingScreen> createState() => _ZenoBreathingScreenState();
}

class _ZenoBreathingScreenState extends State<ZenoBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final AudioService _audioService = AudioService();
  final TtsService _ttsService = TtsService();

  Timer? _breathTimer;
  int _cycleCount = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  BreathingPhase _phase = BreathingPhase.intro;
  String _currentInstruction = '';
  String _currentVoiceLine = '';
  final List<String> _languages = [
    'English',
    'Hindi',
    'Bengali',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];
  String _selectedLanguage = 'English';

  // Ad timer
  Timer? _adTimer;
  int _sessionSeconds = 0;
  bool _adShown = false;
  static const int _adTriggerSeconds = 180;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = VoiceService().appLanguage.displayName;

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _playAmbientSound();
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

  void _startExercise() async {
    // Set language for TTS and VoiceService
    final localeCode = _selectedLanguage == 'Spanish'
        ? 'es-ES'
        : _selectedLanguage == 'Hindi'
            ? 'hi-IN'
            : _selectedLanguage == 'Bengali'
                ? 'bn-IN'
                : _selectedLanguage == 'French'
                    ? 'fr-FR'
                    : _selectedLanguage == 'German'
                        ? 'de-DE'
                        : _selectedLanguage == 'Chinese'
                            ? 'zh-CN'
                            : 'en-US';
    await _ttsService.setLanguage(localeCode);
    await VoiceService().setAppLanguage(
      LocalizationService.languageFromCode(localeCode),
    );

    // Buddha intro
    await VoiceService().speakBreathingIntro();

    // Start with intro
    _setPhase(BreathingPhase.intro);
    await _speak(
      "Hi, it's Zeno. We are going to do breathing exercises now. "
      "You can do these anytime you are having a difficult time. "
      "Remember, Just breathe.",
    );

    await Future.delayed(const Duration(seconds: 2));

    // Start breathing cycles
    _startBreathingCycles();
  }

  void _startBreathingCycles() {
    setState(() {
      _isPlaying = true;
      _phase = BreathingPhase.breathing;
    });

    _breathTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_cycleCount >= 4) {
        timer.cancel();
        _setPhase(BreathingPhase.rest);
        await _speak("Great job! Rest now for 5 seconds.");
        await Future.delayed(const Duration(seconds: 5));
        _setPhase(BreathingPhase.complete);
        _completeSession();
        return;
      }

      if (!_isPaused) {
        _cycleCount++;

        // Inhale phase
        _setInstruction("Breathe in...");
        await _speak("Ok, let's inhale now");
        VoiceService().speakInhale();
        await _animateBreath(inhale: true);
        await Future.delayed(const Duration(seconds: 2));

        // Hold phase
        _setInstruction("Hold...");
        await _speak("Hold for a few seconds");
        VoiceService().speakHold();
        await Future.delayed(const Duration(seconds: 3));

        // Exhale phase
        _setInstruction("Let it go...");
        await _speak("Let it go, Let it go");
        VoiceService().speakExhale();
        await _animateBreath(inhale: false);

        await Future.delayed(const Duration(seconds: 2));
      }
    });
  }

  Future<void> _animateBreath({required bool inhale}) async {
    _controller.reset();
    if (inhale) {
      await _controller.forward();
    } else {
      await _controller.reverse();
    }
  }

  Future<void> _speak(String text) async {
    _setVoiceLine(text);
    await _ttsService.speak(text);
  }

  void _setPhase(BreathingPhase phase) {
    setState(() {
      _phase = phase;
    });
  }

  void _setInstruction(String instruction) {
    setState(() {
      _currentInstruction = instruction;
    });
  }

  void _setVoiceLine(String voiceLine) {
    setState(() {
      _currentVoiceLine = voiceLine;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _breathTimer?.cancel();
        _controller.stop();
        _setInstruction("Paused");
      } else {
        _startBreathingCycles();
      }
    });
  }

  void _completeSession() {
    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.saveSession(
      durationMinutes: 5,
      meditationType: 'Zeno Breathing',
    );
  }

  void _playAgain() {
    setState(() {
      _cycleCount = 0;
      _phase = BreathingPhase.intro;
      _isPlaying = false;
      _isPaused = false;
      _breathTimer?.cancel();
    });
    _startExercise();
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case BreathingPhase.intro:
        return Colors.purple;
      case BreathingPhase.breathing:
        return Colors.blue;
      case BreathingPhase.rest:
        return Colors.orange;
      case BreathingPhase.complete:
        return Colors.green;
    }
  }

  /// Maps the local BreathingPhase + instruction to the scene's BreathPhase.
  BreathPhase get _sceneBreathPhase {
    if (_phase == BreathingPhase.complete) return BreathPhase.complete;
    if (_phase == BreathingPhase.rest) return BreathPhase.rest;
    if (!_isPlaying) return BreathPhase.idle;
    if (_currentInstruction.contains('in') ||
        _currentInstruction.toLowerCase().contains('inhale')) {
      return BreathPhase.inhale;
    }
    if (_currentInstruction.toLowerCase().contains('hold')) {
      return BreathPhase.hold;
    }
    if (_currentInstruction.toLowerCase().contains('let') ||
        _currentInstruction.toLowerCase().contains('exhale')) {
      return BreathPhase.exhale;
    }
    return BreathPhase.idle;
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathTimer?.cancel();
    _adTimer?.cancel();
    _audioService.stopSound();
    _ttsService.stop();
    super.dispose();
  }

  IconData _getPhaseIcon() {
    switch (_phase) {
      case BreathingPhase.intro:
        return Icons.psychology;
      case BreathingPhase.breathing:
        return Icons.air;
      case BreathingPhase.rest:
        return Icons.bedtime;
      case BreathingPhase.complete:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseSceneShell(
      title: 'Zeno Breathing',
      breathPhase: _sceneBreathPhase,
      instruction: _currentInstruction.isEmpty
          ? 'Tap Start to begin'
          : _currentInstruction,
      isActive: _isPlaying && !_isPaused,
      initialEnvironment: widget.environment,
      initialTimeOfDay: widget.timeOfDay,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
      headerActions: [
        // Language selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: const Color(0xFF1a1a2e),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              isDense: true,
              items: _languages
                  .map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedLanguage = v);
                final localeCode = v == 'Spanish'
                    ? 'es-ES'
                    : v == 'Hindi'
                        ? 'hi-IN'
                        : v == 'Bengali'
                            ? 'bn-IN'
                            : v == 'French'
                                ? 'fr-FR'
                                : v == 'German'
                                    ? 'de-DE'
                                    : v == 'Chinese'
                                        ? 'zh-CN'
                                        : 'en-US';
                VoiceService().setAppLanguage(
                    LocalizationService.languageFromCode(localeCode));
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _isPlaying ? _togglePause : null,
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

          // Phase indicator
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Container(
              width: 120 * _scaleAnimation.value,
              height: 120 * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPhaseColor().withAlpha(80),
                border: Border.all(color: _getPhaseColor(), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getPhaseIcon(), size: 32, color: Colors.white),
                    const SizedBox(height: 4),
                    Text('Cycle $_cycleCount/4',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Voice line
          if (_currentVoiceLine.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over,
                      color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_currentVoiceLine,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Controls
          if (_phase == BreathingPhase.complete)
            Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _playAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00b4d8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('PLAY AGAIN',
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
          else if (_phase == BreathingPhase.rest)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('REST NOW',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            )
          else if (!_isPlaying)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('START',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaused ? Colors.green : Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_isPaused ? 'RESUME' : 'PAUSE',
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
}

enum BreathingPhase { intro, breathing, rest, complete }
