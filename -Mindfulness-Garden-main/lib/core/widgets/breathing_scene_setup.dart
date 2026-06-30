// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/services/voice_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BreathingSceneSetup
//
// A pre-session setup screen shown before any breathing exercise.
// The user picks environment + time of day, sees a live 2.5D preview,
// then taps Begin to enter the actual exercise.
//
// Usage:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => BreathingSceneSetup(
//       title: 'Box Breathing',
//       onBegin: (env, time) => Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (_) => BoxBreathingScreen(env: env, time: time)),
//       ),
//     ),
//   ));
// ─────────────────────────────────────────────────────────────────────────────

class BreathingSceneSetup extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final void Function(SceneEnvironment env, SceneTimeOfDay time) onBegin;

  const BreathingSceneSetup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBegin,
    this.accentColor = const Color(0xFF9d4edd),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BreathingSceneSetupContent(
      title: title,
      subtitle: subtitle,
      accentColor: accentColor,
      onBegin: onBegin,
    );
  }
}

class _BreathingSceneSetupContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final void Function(SceneEnvironment env, SceneTimeOfDay time) onBegin;

  const _BreathingSceneSetupContent({
    required this.title,
    required this.subtitle,
    required this.onBegin,
    this.accentColor = const Color(0xFF9d4edd),
  });

  @override
  State<_BreathingSceneSetupContent> createState() => _BreathingSceneSetupContentState();
}

class _BreathingSceneSetupContentState extends State<_BreathingSceneSetupContent> {
  SceneEnvironment _env = SceneEnvironment.forest;
  SceneTimeOfDay _time = SceneTimeOfDay.morning;

  static const _environments = [
    _EnvOpt(
        env: SceneEnvironment.forest,
        label: 'Forest',
        emoji: '🌲',
        color: Color(0xFF38b000)),
    _EnvOpt(
        env: SceneEnvironment.ocean,
        label: 'Ocean',
        emoji: '🌊',
        color: Color(0xFF0077b6)),
    _EnvOpt(
        env: SceneEnvironment.mountain,
        label: 'Mountain',
        emoji: '⛰️',
        color: Color(0xFF4cc9f0)),
    _EnvOpt(
        env: SceneEnvironment.cosmic,
        label: 'Cosmic',
        emoji: '🌌',
        color: Color(0xFF9d4edd)),
    _EnvOpt(
        env: SceneEnvironment.desert,
        label: 'Desert',
        emoji: '🏜️',
        color: Color(0xFFf77f00)),
    _EnvOpt(
        env: SceneEnvironment.zenTemple,
        label: 'Zen Temple',
        emoji: '🏯',
        color: Color(0xFFe9c46a)),
    _EnvOpt(
        env: SceneEnvironment.garden,
        label: 'Garden',
        emoji: '🌸',
        color: Color(0xFFf72585)),
  ];

  static const _times = [
    _TimeOpt(time: SceneTimeOfDay.dawn, label: 'Dawn', emoji: '🌅'),
    _TimeOpt(time: SceneTimeOfDay.morning, label: 'Morning', emoji: '☀️'),
    _TimeOpt(time: SceneTimeOfDay.afternoon, label: 'Afternoon', emoji: '🌤️'),
    _TimeOpt(time: SceneTimeOfDay.dusk, label: 'Dusk', emoji: '🌇'),
    _TimeOpt(time: SceneTimeOfDay.night, label: 'Night', emoji: '🌙'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text(widget.subtitle,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Live 2.5D preview ────────────────────────────────────
            Expanded(
              flex: 5,
              child: Consumer(
                builder: (context, ref, _) {
                  final themeSettings = ref.watch(themePreferenceProvider);
                  return MeditationSceneWidget(
                    breathPhase: BreathPhase.idle,
                    pose: ZenoPose.sitting,
                    environment: _env,
                    timeOfDay: _time,
                    instruction: 'Choose your world',
                    isActive: true,
                    height: double.infinity,
                    teacher: ref.watch(teacherPreferenceProvider),
                  );
                },
              ),
            ),

            // ── Pickers ──────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('ENVIRONMENT'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _environments.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final opt = _environments[i];
                          final sel = opt.env == _env;
                          return GestureDetector(
                            onTap: () => setState(() => _env = opt.env),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              decoration: BoxDecoration(
                                color: sel
                                    ? opt.color.withAlpha(60)
                                    : Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel
                                      ? opt.color
                                      : Colors.white.withAlpha(30),
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(opt.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(opt.label,
                                      style: TextStyle(
                                        color:
                                            sel ? Colors.white : Colors.white54,
                                        fontSize: 10,
                                        fontWeight: sel
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
                    const SizedBox(height: 14),
                    _label('TIME OF DAY'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _times.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final opt = _times[i];
                          final sel = opt.time == _time;
                          return GestureDetector(
                            onTap: () => setState(() => _time = opt.time),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? widget.accentColor.withAlpha(60)
                                    : Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: sel
                                      ? widget.accentColor
                                      : Colors.white.withAlpha(30),
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(opt.emoji,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(opt.label,
                                      style: TextStyle(
                                        color:
                                            sel ? Colors.white : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: sel
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          VoiceService().speakBreathingIntro();
                          widget.onBegin(_env, _time);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: widget.accentColor.withAlpha(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.air,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text('Begin ${widget.title}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ],
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
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF00b4d8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5));
}

class _EnvOpt {
  final SceneEnvironment env;
  final String label, emoji;
  final Color color;
  const _EnvOpt(
      {required this.env,
      required this.label,
      required this.emoji,
      required this.color});
}

class _TimeOpt {
  final SceneTimeOfDay time;
  final String label, emoji;
  const _TimeOpt(
      {required this.time, required this.label, required this.emoji});
}
