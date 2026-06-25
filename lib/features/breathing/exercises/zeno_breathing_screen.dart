import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/services/audio_service.dart';
import 'package:pranaverse/core/services/tts_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/services/localization_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/presentation/providers/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/l10n/app_localizations.dart';
import 'dart:async';

class ZenoBreathingScreen extends ConsumerStatefulWidget {
  final SceneEnvironment environment;
  final SceneTimeOfDay timeOfDay;

  const ZenoBreathingScreen({
    super.key,
    this.environment = SceneEnvironment.zenTemple,
    this.timeOfDay = SceneTimeOfDay.morning,
  });

  @override
  ConsumerState<ZenoBreathingScreen> createState() => _ZenoBreathingScreenState();
}

class _ZenoBreathingScreenState extends ConsumerState<ZenoBreathingScreen>
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

  // Ad timer
  Timer? _adTimer;
  int _sessionSeconds = 0;
  bool _adShown = false;
  static const int _adTriggerSeconds = 180;

  @override
  void initState() {
    super.initState();
    print('ZENO BREATHING SCREEN: initState called');

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
    final l10n = AppLocalizations.of(context)!;
    // Language is now managed globally by AppSettingsProvider
    // Buddha intro
    await VoiceService().speakBreathingIntro();

    // Start with intro
    _setPhase(BreathingPhase.intro);
    await _speak(l10n.zenoIntro);

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
        final l10n = AppLocalizations.of(context)!;
        await _speak(l10n.complete);
        await Future.delayed(const Duration(seconds: 5));
        _setPhase(BreathingPhase.complete);
        _completeSession();
        return;
      }

      if (!_isPaused) {
        _cycleCount++;

        // Inhale phase
        final l10n = AppLocalizations.of(context)!;
        _setInstruction(l10n.inhale);
        await _speak(l10n.inhale);
        VoiceService().speakInhale();
        await _animateBreath(inhale: true);
        await Future.delayed(const Duration(seconds: 2));

        // Hold phase
        _setInstruction(l10n.hold);
        await _speak(l10n.hold);
        VoiceService().speakHold();
        await Future.delayed(const Duration(seconds: 3));

        // Exhale phase
        _setInstruction(l10n.exhale);
        await _speak(l10n.exhale);
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
        final l10n = AppLocalizations.of(context)!;
        _setInstruction(l10n.pause);
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
    final l10n = AppLocalizations.of(context)!;
    if (_currentInstruction == l10n.inhale) {
      return BreathPhase.inhale;
    }
    if (_currentInstruction == l10n.hold) {
      return BreathPhase.hold;
    }
    if (_currentInstruction == l10n.exhale) {
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
    final l10n = AppLocalizations.of(context)!;
    print('ZENO BREATHING SCREEN: build called, phase: $_phase, isPlaying: $_isPlaying');
    return ExerciseSceneShell(
      title: 'Zeno Breathing',
      breathPhase: _sceneBreathPhase,
      instruction: _currentInstruction.isEmpty
          ? l10n.tapStartToBegin
          : _currentInstruction,
      isActive: _isPlaying && !_isPaused,
      initialEnvironment: widget.environment,
      initialTimeOfDay: widget.timeOfDay,
      onBack: () => context.canPop() ? context.pop() : context.go('/main'),
      headerActions: [
        GestureDetector(
          onTap: _isPlaying ? _togglePause : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white, size: 14),
          ),
        ),
      ],
      bottomPanel: _buildBottomPanel(),
    );
  }

  void _showBenefits() {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = context.read<AppSettingsProvider>();
    final text = LocalizationService.translate('benefits_breathing', appSettings.language);
    // Speak and show a dialog
    VoiceService().speak(text);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.benefits,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close,
                    style: const TextStyle(color: Colors.white70)))
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final l10n = AppLocalizations.of(context)!;
    print('ZENO BREATHING SCREEN: _buildBottomPanel called, phase: $_phase');
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 400;
    
    final circleSize = isSmallScreen ? 90.0 : (isLargeScreen ? 110.0 : 100.0);
    final iconSize = isSmallScreen ? 24.0 : (isLargeScreen ? 32.0 : 28.0);
    final buttonTextSize = isSmallScreen ? 14.0 : (isLargeScreen ? 17.0 : 16.0);
    final buttonPadding = isSmallScreen ? 14.0 : (isLargeScreen ? 18.0 : 16.0);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 20, 
        8, 
        isSmallScreen ? 16 : 20, 
        20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Phase indicator
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Container(
                width: circleSize * _scaleAnimation.value,
                height: circleSize * _scaleAnimation.value,
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
                      Icon(_getPhaseIcon(), size: iconSize, color: Colors.white),
                      const SizedBox(height: 6),
                      Text('${l10n.cycleCount} $_cycleCount/4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white70, 
                              fontSize: isSmallScreen ? 11.0 : 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Voice line
          if (_currentVoiceLine.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 14 : 16, 
                vertical: isSmallScreen ? 10 : 12
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(20), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over,
                      color: Colors.white60, 
                      size: isSmallScreen ? 16 : 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_currentVoiceLine,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 12.0 : 13.0,
                            height: 1.3,
                            letterSpacing: 0.1,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Controls
          if (_phase == BreathingPhase.complete)
            Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _playAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00b4d8),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(l10n.playAgain,
                      style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
              TextButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/main'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                ),
                child: Text(l10n.backToExercises,
                    style: TextStyle(
                        color: Colors.white70, 
                        fontSize: isSmallScreen ? 13.0 : 14.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2)),
              ),
            ])
          else if (_phase == BreathingPhase.rest)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(l10n.restNow,
                    style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            )
          else if (!_isPlaying)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(l10n.start,
                    style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaused ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(_isPaused ? l10n.resume : l10n.pause,
                    style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}

enum BreathingPhase { intro, breathing, rest, complete }
