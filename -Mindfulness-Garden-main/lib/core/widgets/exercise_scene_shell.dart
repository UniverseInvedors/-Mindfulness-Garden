// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExerciseSceneShell
//
// Wraps any breathing exercise screen with a full-screen 2.5D environment.
// The teacher (Zeno/Buddha) is always visible in the background, reacting to
// the current breath phase. The exercise UI sits in a frosted-glass panel at
// the bottom of the screen.
//
// Usage — replace each exercise screen's Scaffold with:
//
//   ExerciseSceneShell(
//     title: 'Box Breathing',
//     breathPhase: _scenePhase,          // BreathPhase from meditation_scene_widget
//     instruction: _currentInstruction,  // shown in teacher speech bubble
//     onBack: () => context.go('/breathing'),
//     headerActions: [...],              // optional icon buttons top-right
//     bottomPanel: _buildExercisePanel(), // your existing exercise UI
//   )
// ─────────────────────────────────────────────────────────────────────────────

class ExerciseSceneShell extends ConsumerWidget {
  final String title;
  final BreathPhase breathPhase;
  final String instruction;
  final bool isActive;
  final VoidCallback onBack;
  final List<Widget> headerActions;
  final Widget bottomPanel;

  /// Initial environment — user can change it via the picker
  final SceneEnvironment initialEnvironment;
  final SceneTimeOfDay initialTimeOfDay;

  const ExerciseSceneShell({
    super.key,
    required this.title,
    required this.breathPhase,
    required this.instruction,
    required this.isActive,
    required this.onBack,
    required this.bottomPanel,
    this.headerActions = const [],
    this.initialEnvironment = SceneEnvironment.forest,
    this.initialTimeOfDay = SceneTimeOfDay.morning,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExerciseSceneShellContent(
      title: title,
      breathPhase: breathPhase,
      instruction: instruction,
      isActive: isActive,
      onBack: onBack,
      headerActions: headerActions,
      bottomPanel: bottomPanel,
      initialEnvironment: initialEnvironment,
      initialTimeOfDay: initialTimeOfDay,
    );
  }
}

class _ExerciseSceneShellContent extends StatefulWidget {
  final String title;
  final BreathPhase breathPhase;
  final String instruction;
  final bool isActive;
  final VoidCallback onBack;
  final List<Widget> headerActions;
  final Widget bottomPanel;
  final SceneEnvironment initialEnvironment;
  final SceneTimeOfDay initialTimeOfDay;

  const _ExerciseSceneShellContent({
    required this.title,
    required this.breathPhase,
    required this.instruction,
    required this.isActive,
    required this.onBack,
    required this.bottomPanel,
    this.headerActions = const [],
    this.initialEnvironment = SceneEnvironment.forest,
    this.initialTimeOfDay = SceneTimeOfDay.morning,
  });

  @override
  State<_ExerciseSceneShellContent> createState() => _ExerciseSceneShellContentState();
}

class _ExerciseSceneShellContentState extends State<_ExerciseSceneShellContent> {
  late SceneEnvironment _env;
  late SceneTimeOfDay _time;
  bool _showEnvPicker = false;

  static const _envs = [
    (env: SceneEnvironment.forest, emoji: '🌲', label: 'Forest'),
    (env: SceneEnvironment.ocean, emoji: '🌊', label: 'Ocean'),
    (env: SceneEnvironment.mountain, emoji: '⛰️', label: 'Mountain'),
    (env: SceneEnvironment.cosmic, emoji: '🌌', label: 'Cosmic'),
    (env: SceneEnvironment.desert, emoji: '🏜️', label: 'Desert'),
    (env: SceneEnvironment.zenTemple, emoji: '🏯', label: 'Temple'),
    (env: SceneEnvironment.garden, emoji: '🌸', label: 'Garden'),
  ];

  static const _times = [
    (time: SceneTimeOfDay.dawn, emoji: '🌅'),
    (time: SceneTimeOfDay.morning, emoji: '☀️'),
    (time: SceneTimeOfDay.afternoon, emoji: '🌤️'),
    (time: SceneTimeOfDay.dusk, emoji: '🌇'),
    (time: SceneTimeOfDay.night, emoji: '🌙'),
  ];

  @override
  void initState() {
    super.initState();
    _env = widget.initialEnvironment;
    _time = widget.initialTimeOfDay;
  }

  @override
  Widget build(BuildContext context) {
    print('EXERCISE SCENE SHELL: build called, title: ${widget.title}');
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Full-screen 2.5D scene ─────────────────────────────────
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  final themeSettings = ref.watch(themePreferenceProvider);
                  return MeditationSceneWidget(
                    breathPhase: widget.breathPhase,
                    pose: ZenoPose.sitting,
                    environment: _env,
                    timeOfDay: _time,
                    instruction: widget.instruction,
                    isActive: widget.isActive,
                    height: double.infinity,
                    teacher: ref.watch(teacherPreferenceProvider),
                  );
                },
              ),
            ),

            // ── Top bar ────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Row(
                        children: [
                          // Back button
                          _glassButton(
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 16),
                            onTap: widget.onBack,
                          ),
                          const SizedBox(width: 4),
                          // Title
                          Expanded(
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 8)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Environment picker toggle
                          _glassButton(
                            child: Text(
                              _envs.firstWhere((e) => e.env == _env).emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => setState(
                                () => _showEnvPicker = !_showEnvPicker),
                          ),
                          const SizedBox(width: 2),
                          // Time picker
                          _glassButton(
                            child: Text(
                              _times.firstWhere((t) => t.time == _time).emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              final idx =
                                  _times.indexWhere((t) => t.time == _time);
                              setState(() => _time =
                                  _times[(idx + 1) % _times.length].time);
                            },
                          ),
                          // Extra actions
                          ...widget.headerActions.map((a) => Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: a,
                              )),
                        ],
                      ),
                    ),

                    // Environment picker row (slides in)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _showEnvPicker
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(140),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.white.withAlpha(30)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: _envs.map((e) {
                                    final sel = e.env == _env;
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        _env = e.env;
                                        _showEnvPicker = false;
                                      }),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? Colors.white.withAlpha(40)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: sel
                                              ? Border.all(
                                                  color: Colors.white
                                                      .withAlpha(80))
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(e.emoji,
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                            Text(e.label,
                                                style: TextStyle(
                                                  color: sel
                                                      ? Colors.white
                                                      : Colors.white60,
                                                  fontSize: 9,
                                                  fontWeight: sel
                                                      ? FontWeight.w700
                                                      : FontWeight.normal,
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom exercise panel ──────────────────────────────────
            // Uses MediaQuery bottom padding directly so system nav buttons
            // are never covered. The panel fades to transparent at the top
            // so the 2.5D scene bleeds through.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomPanel(child: widget.bottomPanel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomPanel
//
// A frosted-glass exercise panel that:
//   • Never covers system navigation buttons (uses viewPadding.bottom)
//   • Fades to transparent at the top so the 2.5D scene bleeds through
//   • Has a max height of 55% of screen so the teacher is always visible
//   • Has a subtle top border + drag handle for polish
// ─────────────────────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final Widget child;
  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Respect system nav bar height — never overlap it
    final bottomInset = mq.viewPadding.bottom;
    final maxH = mq.size.height * 0.55;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Stack(
        children: [
          // ── Frosted gradient background ──────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(0),
                      Colors.black.withAlpha(35),
                      Colors.black.withAlpha(70),
                      Colors.black.withAlpha(120),
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Content with bottom inset padding ───────────────────────
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Exercise content — scrollable if it overflows
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
