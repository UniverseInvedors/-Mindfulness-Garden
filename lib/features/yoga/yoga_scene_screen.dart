import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/services/localization_service.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// YogaSceneScreen
//
// A full-screen 2.5D yoga experience. Zeno guides the user through a pose
// sequence inside a selectable environment. The scene reacts to each pose
// transition and the breathing phase in real time.
// ─────────────────────────────────────────────────────────────────────────────

class YogaSceneScreen extends ConsumerStatefulWidget {
  const YogaSceneScreen({super.key});

  @override
  ConsumerState<YogaSceneScreen> createState() => _YogaSceneScreenState();
}

class _YogaSceneScreenState extends ConsumerState<YogaSceneScreen>
    with TickerProviderStateMixin {
  // ── Session state ──────────────────────────────────────────────────────────
  bool _isActive = false;
  bool _isPaused = false;
  int _poseIndex = 0;
  int _holdSecondsLeft = 0;
  int _totalSeconds = 0;
  BreathPhase _breathPhase = BreathPhase.idle;
  SceneEnvironment _environment = SceneEnvironment.forest;
  SceneTimeOfDay _timeOfDay = SceneTimeOfDay.morning;

  // ── Timers ─────────────────────────────────────────────────────────────────
  Timer? _poseTimer;
  Timer? _breathTimer;
  Timer? _sessionTimer;

  // ── Breath cycle ───────────────────────────────────────────────────────────
  static const _inhaleSeconds = 4;
  static const _holdSeconds = 2;
  static const _exhaleSeconds = 6;

  // ── Pose sequence ──────────────────────────────────────────────────────────
  static const _sequence = [
    _PoseStep(
        pose: ZenoPose.mountain,
        name: 'Mountain Pose',
        holdSec: 20,
        instruction: 'Stand tall, breathe deep'),
    _PoseStep(
        pose: ZenoPose.warrior,
        name: 'Warrior I',
        holdSec: 30,
        instruction: 'Ground your feet, reach up'),
    _PoseStep(
        pose: ZenoPose.tree,
        name: 'Tree Pose',
        holdSec: 30,
        instruction: 'Find your balance'),
    _PoseStep(
        pose: ZenoPose.warrior,
        name: 'Warrior I (other)',
        holdSec: 30,
        instruction: 'Switch sides, stay strong'),
    _PoseStep(
        pose: ZenoPose.downwardDog,
        name: 'Downward Dog',
        holdSec: 30,
        instruction: 'Lengthen your spine'),
    _PoseStep(
        pose: ZenoPose.childPose,
        name: "Child's Pose",
        holdSec: 30,
        instruction: 'Rest and restore'),
    _PoseStep(
        pose: ZenoPose.lotus,
        name: 'Lotus Meditation',
        holdSec: 60,
        instruction: 'Breathe and be still'),
  ];

  // ── Environment options ────────────────────────────────────────────────────
  static const _environments = [
    _EnvOption(
        env: SceneEnvironment.forest,
        label: 'Forest',
        icon: Icons.park,
        color: Color(0xFF38b000)),
    _EnvOption(
        env: SceneEnvironment.ocean,
        label: 'Ocean',
        icon: Icons.waves,
        color: Color(0xFF0077b6)),
    _EnvOption(
        env: SceneEnvironment.mountain,
        label: 'Mountain',
        icon: Icons.landscape,
        color: Color(0xFF4cc9f0)),
    _EnvOption(
        env: SceneEnvironment.cosmic,
        label: 'Cosmic',
        icon: Icons.star,
        color: Color(0xFF9d4edd)),
    _EnvOption(
        env: SceneEnvironment.desert,
        label: 'Desert',
        icon: Icons.wb_sunny,
        color: Color(0xFFf77f00)),
    _EnvOption(
        env: SceneEnvironment.zenTemple,
        label: 'Zen Temple',
        icon: Icons.temple_buddhist,
        color: Color(0xFFe9c46a)),
    _EnvOption(
        env: SceneEnvironment.garden,
        label: 'Garden',
        icon: Icons.local_florist,
        color: Color(0xFFf72585)),
  ];

  static const _times = [
    _TimeOption(
        time: SceneTimeOfDay.dawn, label: 'Dawn', icon: Icons.wb_twilight),
    _TimeOption(
        time: SceneTimeOfDay.morning,
        label: 'Morning',
        icon: Icons.wb_sunny_outlined),
    _TimeOption(
        time: SceneTimeOfDay.afternoon,
        label: 'Afternoon',
        icon: Icons.wb_sunny),
    _TimeOption(
        time: SceneTimeOfDay.dusk,
        label: 'Dusk',
        icon: Icons.nights_stay_outlined),
    _TimeOption(
        time: SceneTimeOfDay.night, label: 'Night', icon: Icons.nightlight),
  ];

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _breathBarCtrl;
  late Animation<double> _breathBarAnim;

  @override
  void initState() {
    super.initState();
    _breathBarCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: _inhaleSeconds));
    _breathBarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _breathBarCtrl, curve: Curves.easeInOut),
    );
    _holdSecondsLeft = _sequence[0].holdSec;
  }

  @override
  void dispose() {
    _poseTimer?.cancel();
    _breathTimer?.cancel();
    _sessionTimer?.cancel();
    _breathBarCtrl.dispose();
    super.dispose();
  }

  // ── Session control ────────────────────────────────────────────────────────

  void _startSession() {
    HapticFeedback.mediumImpact();
    VoiceService().sessionStart('yoga');
    setState(() {
      _isActive = true;
      _isPaused = false;
      _poseIndex = 0;
      _totalSeconds = 0;
      _holdSecondsLeft = _sequence[0].holdSec;
    });
    _startBreathCycle();
    _startPoseCountdown();
    _startSessionTimer();
  }

  void _pauseResume() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _poseTimer?.cancel();
      _breathTimer?.cancel();
      _sessionTimer?.cancel();
      _breathBarCtrl.stop();
      setState(() => _breathPhase = BreathPhase.rest);
    } else {
      _startBreathCycle();
      _startPoseCountdown();
      _startSessionTimer();
    }
  }

  void _endSession() {
    HapticFeedback.heavyImpact();
    _poseTimer?.cancel();
    _breathTimer?.cancel();
    _sessionTimer?.cancel();
    _breathBarCtrl.stop();
    setState(() {
      _isActive = false;
      _isPaused = false;
      _breathPhase = BreathPhase.idle;
      _poseIndex = 0;
      _holdSecondsLeft = _sequence[0].holdSec;
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _totalSeconds++);
    });
  }

  void _startPoseCountdown() {
    _poseTimer?.cancel();
    _poseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      setState(() {
        _holdSecondsLeft--;
        if (_holdSecondsLeft <= 0) {
          _advancePose();
        }
      });
    });
  }

  void _advancePose() {
    HapticFeedback.mediumImpact();
    if (_poseIndex < _sequence.length - 1) {
      setState(() {
        _poseIndex++;
        _holdSecondsLeft = _sequence[_poseIndex].holdSec;
      });
      // Buddha announces the new pose
      VoiceService().speakPoseInstruction(_sequence[_poseIndex].name);
      VoiceService().speakPoseTransition();
    } else {
      // Sequence complete
      _poseTimer?.cancel();
      _breathTimer?.cancel();
      _sessionTimer?.cancel();
      VoiceService().sessionComplete(_totalSeconds ~/ 60);
      setState(() {
        _breathPhase = BreathPhase.complete;
        _isActive = false;
      });
    }
  }

  void _startBreathCycle() {
    _breathTimer?.cancel();
    _runBreathPhase();
  }

  void _runBreathPhase() async {
    if (!mounted || _isPaused) return;

    // Inhale
    setState(() => _breathPhase = BreathPhase.inhale);
    _breathBarCtrl.duration = const Duration(seconds: _inhaleSeconds);
    _breathBarCtrl.forward(from: 0);
    await Future.delayed(const Duration(seconds: _inhaleSeconds));
    if (!mounted || _isPaused) return;

    // Hold
    setState(() => _breathPhase = BreathPhase.hold);
    await Future.delayed(const Duration(seconds: _holdSeconds));
    if (!mounted || _isPaused) return;

    // Exhale
    setState(() => _breathPhase = BreathPhase.exhale);
    _breathBarCtrl.duration = const Duration(seconds: _exhaleSeconds);
    _breathBarCtrl.reverse();
    await Future.delayed(const Duration(seconds: _exhaleSeconds));
    if (!mounted || _isPaused) return;

    // Loop
    _runBreathPhase();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _breathLabel {
    switch (_breathPhase) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.hold:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.rest:
        return 'Paused';
      case BreathPhase.complete:
        return 'Complete ✓';
      case BreathPhase.idle:
        return 'Ready';
    }
  }

  Color get _breathColor {
    switch (_breathPhase) {
      case BreathPhase.inhale:
        return const Color(0xFF00b4d8);
      case BreathPhase.hold:
        return const Color(0xFF9d4edd);
      case BreathPhase.exhale:
        return const Color(0xFF38b000);
      case BreathPhase.rest:
        return const Color(0xFFffb700);
      case BreathPhase.complete:
        return const Color(0xFF38b000);
      case BreathPhase.idle:
        return const Color(0xFF4cc9f0);
    }
  }

  _PoseStep get _currentStep => _sequence[_poseIndex];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Column(
        children: [
          // Top safe area only
          SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),
          // ── 2.5D Scene (hero) ──────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Consumer(
              builder: (context, ref, _) {
                final themeSettings = ref.watch(themePreferenceProvider);
                return MeditationSceneWidget(
                  breathPhase: _breathPhase,
                  pose: _currentStep.pose,
                  environment: _isActive ? _environment : themeSettings.environment,
                  timeOfDay: _isActive ? _timeOfDay : themeSettings.timeOfDay,
                  instruction: _isActive
                      ? _currentStep.instruction
                      : 'Choose your environment',
                  isActive: _isActive && !_isPaused,
                  height: double.infinity,
                  teacher: ref.watch(teacherPreferenceProvider),
                );
              },
            ),
          ),
          // ── Controls panel — bottom safe area handled here ─────────────
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(0),
                    Colors.black.withAlpha(160),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: _isActive ? _buildActivePanel() : _buildSetupPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isActive) _endSession();
              context.canPop() ? context.pop() : context.go('/main');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yoga with Zeno',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text('2.5D immersive experience',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          if (_isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTime(_totalSeconds),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'RobotoMono'),
              ),
            ),
        ],
      ),
    );
  }

  // ── Setup panel (before session starts) ───────────────────────────────────

  Widget _buildSetupPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ENVIRONMENT'),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _environments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final opt = _environments[i];
                final selected = opt.env == _environment;
                return GestureDetector(
                  onTap: () => setState(() => _environment = opt.env),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      color: selected
                          ? opt.color.withAlpha(60)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            selected ? opt.color : Colors.white.withAlpha(30),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(opt.icon,
                            color: selected ? opt.color : Colors.white54,
                            size: 22),
                        const SizedBox(height: 4),
                        Text(opt.label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel('TIME OF DAY'),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _times.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final opt = _times[i];
                final selected = opt.time == _timeOfDay;
                return GestureDetector(
                  onTap: () => setState(() => _timeOfDay = opt.time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF9d4edd).withAlpha(60)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF9d4edd)
                            : Colors.white.withAlpha(30),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(opt.icon,
                            size: 14,
                            color: selected
                                ? const Color(0xFF9d4edd)
                                : Colors.white54),
                        const SizedBox(width: 6),
                        Text(opt.label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel('TEACHER'),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: TeacherPersonality.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final personality = TeacherPersonality.values[i];
                final appearance = TeacherAppearance.personalities[personality]!;
                final currentTeacher = ref.watch(teacherPreferenceProvider);
                final selected = personality == currentTeacher;
                return GestureDetector(
                  onTap: () async {
                    await ref.read(teacherPreferenceProvider.notifier).setTeacher(personality);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      color: selected
                          ? appearance.auraPrimary.withAlpha(60)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? appearance.auraPrimary
                            : Colors.white.withAlpha(30),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getTeacherIcon(personality),
                          color: selected ? appearance.auraPrimary : Colors.white54,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appearance.name,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('SEQUENCE PREVIEW'),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sequence.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final step = _sequence[i];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(step.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      Text('${step.holdSec}s',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9d4edd),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: const Color(0xFF9d4edd).withAlpha(100),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Begin Yoga Session',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _showBenefits,
              child: const Text('Benefits',
                  style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBenefits() {
    final l10n = AppLocalizations.of(context)!;
    final text = l10n.benefitsBreathing;
    VoiceService().speak(text);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.benefitsBreathing,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(l10n.breathingBenefits,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.back,
                    style: const TextStyle(color: Colors.white70)))
          ]),
        ),
      ),
    );
  }

  // ── Active session panel ───────────────────────────────────────────────────

  Widget _buildActivePanel() {
    final step = _currentStep;
    final progress = 1 - (_holdSecondsLeft / step.holdSec);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pose name + hold timer
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(step.instruction,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _breathColor, width: 2.5),
                  color: _breathColor.withAlpha(20),
                ),
                child: Center(
                  child: Text('$_holdSecondsLeft',
                      style: TextStyle(
                          color: _breathColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pose progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(_breathColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pose ${_poseIndex + 1} of ${_sequence.length}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text('${_holdSecondsLeft}s remaining',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),

          // Breath indicator
          AnimatedBuilder(
            animation: _breathBarAnim,
            builder: (_, __) {
              return Column(
                children: [
                  Row(
                    children: [
                      Text(_breathLabel,
                          style: TextStyle(
                            color: _breathColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          )),
                      const Spacer(),
                      Text('$_inhaleSeconds-$_holdSeconds-$_exhaleSeconds',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _breathPhase == BreathPhase.exhale
                          ? _breathBarAnim.value
                          : (_breathPhase == BreathPhase.inhale
                              ? _breathBarAnim.value
                              : 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white.withAlpha(15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _breathColor.withAlpha(200)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Pose dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_sequence.length, (i) {
              final done = i < _poseIndex;
              final current = i == _poseIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: current ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFF38b000)
                      : current
                          ? _breathColor
                          : Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Control buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pauseResume,
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                      size: 18),
                  label: Text(_isPaused ? 'Resume' : 'Pause'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withAlpha(40)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _advancePose,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Next Pose'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9d4edd),
                    side: const BorderSide(color: Color(0xFF9d4edd)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _endSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.stop, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF00b4d8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5));

  IconData _getTeacherIcon(TeacherPersonality personality) {
    switch (personality) {
      case TeacherPersonality.buddha:
        return Icons.self_improvement;
      case TeacherPersonality.zeno:
        return Icons.person;
      case TeacherPersonality.monk:
        return Icons.accessibility;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _PoseStep {
  final ZenoPose pose;
  final String name;
  final int holdSec;
  final String instruction;
  const _PoseStep(
      {required this.pose,
      required this.name,
      required this.holdSec,
      required this.instruction});
}

class _EnvOption {
  final SceneEnvironment env;
  final String label;
  final IconData icon;
  final Color color;
  const _EnvOption(
      {required this.env,
      required this.label,
      required this.icon,
      required this.color});
}

class _TimeOption {
  final SceneTimeOfDay time;
  final String label;
  final IconData icon;
  const _TimeOption(
      {required this.time, required this.label, required this.icon});
}
