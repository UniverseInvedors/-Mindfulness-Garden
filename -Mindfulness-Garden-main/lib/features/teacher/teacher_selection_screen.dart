// lib/features/teacher/teacher_selection_screen.dart
//
// Teacher Studio — the dedicated screen for choosing & customising your guide.
// Accessed ONLY from Settings → "Open Teacher Studio" button.
//
// What this screen does that Settings does NOT:
//   • Full-screen animated teacher preview (live avatar)
//   • Voice tone slider (pitch / rate via VoiceService)
//   • Scene environment & time-of-day picker
//   • "Hear this guide" live TTS preview
//   • Trait pills + full description
//
// Settings still shows the compact 3-tile picker for quick switching.
// This screen is the deep-customisation hub.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/widgets/character/teacher_avatar.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/widgets/sound_button.dart';

class TeacherSelectionScreen extends ConsumerStatefulWidget {
  const TeacherSelectionScreen({super.key});

  @override
  ConsumerState<TeacherSelectionScreen> createState() =>
      _TeacherSelectionScreenState();
}

class _TeacherSelectionScreenState extends ConsumerState<TeacherSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  bool _isSpeaking = false;

  // Local customisation state (persisted on apply)
  double _voicePitch = 1.0; // 0.5 – 2.0
  double _voiceRate = 0.45; // 0.1 – 1.0
  SceneEnvironment _env = SceneEnvironment.forest;
  SceneTimeOfDay _time = SceneTimeOfDay.morning;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Load current scene prefs
    final themeSettings = ref.read(themePreferenceProvider);
    _env = themeSettings.environment;
    _time = themeSettings.timeOfDay;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _previewVoice(TeacherPersonality teacher) async {
    setState(() => _isSpeaking = true);
    await VoiceService().speak(_previewLine(teacher));
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _applyAndClose() async {
    await ref.read(themePreferenceProvider.notifier).setTheme(_env, _time);
    await VoiceService().setRate(_voiceRate);
    await VoiceService().setPitch(_voicePitch);
    SoundService().playSuccess();
    if (mounted) context.pop();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final teacher = ref.watch(teacherPreferenceProvider);
    final appearance = TeacherAppearance.personalities[teacher]!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : cs.onSurface;
    final subtleColor = isDark ? Colors.white70 : cs.onSurface.withAlpha(160);
    final cardColor =
        isDark ? Colors.white.withAlpha(13) : cs.onSurface.withAlpha(8);
    final borderColor =
        isDark ? Colors.white.withAlpha(30) : cs.onSurface.withAlpha(40);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appearance.auraPrimary.withAlpha(isDark ? 30 : 15),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, textColor, subtleColor),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live avatar preview
                      _buildAvatarHero(context, teacher, appearance, isDark),
                      const SizedBox(height: 24),

                      // Teacher selector row
                      _sectionLabel('Choose Your Guide', textColor),
                      const SizedBox(height: 12),
                      _buildTeacherRow(context, teacher, cs, isDark),
                      const SizedBox(height: 24),

                      // Description card
                      _buildDescriptionCard(context, teacher, appearance,
                          cardColor, borderColor, textColor, subtleColor),
                      const SizedBox(height: 24),

                      // Voice customisation
                      _sectionLabel('Voice Tone', textColor),
                      const SizedBox(height: 4),
                      Text('Adjust how your guide sounds during sessions.',
                          style: TextStyle(color: subtleColor, fontSize: 13)),
                      const SizedBox(height: 12),
                      _buildVoiceCard(context, appearance, cardColor,
                          borderColor, textColor, subtleColor, cs),
                      const SizedBox(height: 24),

                      // Scene environment
                      _sectionLabel('Scene Environment', textColor),
                      const SizedBox(height: 12),
                      _buildEnvironmentPicker(context, cs, textColor, isDark),
                      const SizedBox(height: 16),

                      // Time of day
                      _sectionLabel('Time of Day', textColor),
                      const SizedBox(height: 12),
                      _buildTimePicker(context, cs, textColor, isDark),
                      const SizedBox(height: 32),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _applyAndClose,
                          icon: const Icon(Icons.check_rounded,
                              color: Colors.white),
                          label: const Text('Apply & Close',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appearance.auraPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
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
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, Color textColor, Color subtleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          SoundInkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teacher Studio',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                Text('Personalise your guide',
                    style: TextStyle(color: subtleColor, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar hero ───────────────────────────────────────────────────────────

  Widget _buildAvatarHero(BuildContext context, TeacherPersonality teacher,
      TeacherAppearance appearance, bool isDark) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                appearance.auraPrimary
                    .withAlpha((50 + (_pulseCtrl.value * 30)).round()),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: appearance.auraPrimary
                    .withAlpha((60 + (_pulseCtrl.value * 40)).round()),
                blurRadius: 30 + _pulseCtrl.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: TeacherAvatar(
              teacher: teacher,
              isSpeaking: _isSpeaking,
              selected: true,
              background: false,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Teacher selector row ──────────────────────────────────────────────────

  Widget _buildTeacherRow(BuildContext context, TeacherPersonality current,
      ColorScheme cs, bool isDark) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TeacherPersonality.values.map((p) {
          final ap = TeacherAppearance.personalities[p]!;
          final sel = p == current;
          return SoundInkWell(
            onTap: () async {
              await ref.read(teacherPreferenceProvider.notifier).setTeacher(p);
              SoundService().playZen();
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 88,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: sel
                    ? ap.auraPrimary.withAlpha(30)
                    : (isDark
                        ? Colors.white.withAlpha(10)
                        : cs.onSurface.withAlpha(8)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: sel ? ap.auraPrimary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: ap.auraPrimary.withAlpha(60), blurRadius: 12)
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: TeacherAvatar(
                        teacher: p, selected: sel, background: false),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ap.name,
                    style: TextStyle(
                      color: sel
                          ? ap.auraPrimary
                          : (isDark
                              ? Colors.white70
                              : cs.onSurface.withAlpha(180)),
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Description card ──────────────────────────────────────────────────────

  Widget _buildDescriptionCard(
      BuildContext context,
      TeacherPersonality teacher,
      TeacherAppearance appearance,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color subtleColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                appearance.name,
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: appearance.auraPrimary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: appearance.auraPrimary.withAlpha(80)),
                ),
                child: Text(
                  teacher.role,
                  style: TextStyle(
                      color: appearance.auraPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _description(teacher),
            style: TextStyle(color: subtleColor, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          // Trait chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _traits(teacher)
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: appearance.auraSecondary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: appearance.auraSecondary.withAlpha(80)),
                      ),
                      child: Text(t,
                          style: TextStyle(
                              color: appearance.auraSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Preview voice button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSpeaking ? null : () => _previewVoice(teacher),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSpeaking
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: appearance.auraPrimary),
                      )
                    : Icon(Icons.volume_up_rounded,
                        key: const ValueKey('icon'),
                        color: appearance.auraPrimary,
                        size: 18),
              ),
              label: Text(
                _isSpeaking ? 'Speaking…' : 'Hear this guide',
                style: TextStyle(
                    color: appearance.auraPrimary, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: appearance.auraPrimary.withAlpha(120)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Voice card ────────────────────────────────────────────────────────────

  Widget _buildVoiceCard(
      BuildContext context,
      TeacherAppearance appearance,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color subtleColor,
      ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _voiceSlider(
            label: 'Pitch',
            icon: Icons.graphic_eq_rounded,
            value: _voicePitch,
            min: 0.5,
            max: 2.0,
            lowLabel: 'Deep',
            highLabel: 'High',
            color: appearance.auraPrimary,
            textColor: textColor,
            subtleColor: subtleColor,
            onChanged: (v) => setState(() => _voicePitch = v),
          ),
          const SizedBox(height: 12),
          _voiceSlider(
            label: 'Speed',
            icon: Icons.speed_rounded,
            value: _voiceRate,
            min: 0.1,
            max: 1.0,
            lowLabel: 'Slow',
            highLabel: 'Fast',
            color: appearance.auraSecondary,
            textColor: textColor,
            subtleColor: subtleColor,
            onChanged: (v) => setState(() => _voiceRate = v),
          ),
        ],
      ),
    );
  }

  Widget _voiceSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String lowLabel,
    required String highLabel,
    required Color color,
    required Color textColor,
    required Color subtleColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(value.toStringAsFixed(2),
                style: TextStyle(color: subtleColor, fontSize: 12)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withAlpha(40),
            overlayColor: color.withAlpha(30),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        Row(
          children: [
            Text(lowLabel, style: TextStyle(color: subtleColor, fontSize: 10)),
            const Spacer(),
            Text(highLabel, style: TextStyle(color: subtleColor, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  // ─── Environment picker ────────────────────────────────────────────────────

  Widget _buildEnvironmentPicker(
      BuildContext context, ColorScheme cs, Color textColor, bool isDark) {
    final envData = {
      SceneEnvironment.forest: ('🌲', 'Forest'),
      SceneEnvironment.ocean: ('🌊', 'Ocean'),
      SceneEnvironment.mountain: ('⛰️', 'Mountain'),
      SceneEnvironment.cosmic: ('🌌', 'Cosmic'),
      SceneEnvironment.desert: ('🏜️', 'Desert'),
      SceneEnvironment.zenTemple: ('🏯', 'Zen Temple'),
      SceneEnvironment.garden: ('🌸', 'Garden'),
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: envData.entries.map((e) {
        final sel = _env == e.key;
        return SoundInkWell(
          onTap: () => setState(() => _env = e.key),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel
                  ? cs.primary.withAlpha(30)
                  : (isDark
                      ? Colors.white.withAlpha(10)
                      : cs.onSurface.withAlpha(8)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel
                    ? cs.primary
                    : (isDark
                        ? Colors.white.withAlpha(25)
                        : cs.onSurface.withAlpha(30)),
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.value.$1, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  e.value.$2,
                  style: TextStyle(
                    color: sel ? cs.primary : textColor,
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Time of day picker ────────────────────────────────────────────────────

  Widget _buildTimePicker(
      BuildContext context, ColorScheme cs, Color textColor, bool isDark) {
    final timeData = {
      SceneTimeOfDay.dawn: ('🌅', 'Dawn'),
      SceneTimeOfDay.morning: ('☀️', 'Morning'),
      SceneTimeOfDay.afternoon: ('🌤️', 'Afternoon'),
      SceneTimeOfDay.dusk: ('🌇', 'Dusk'),
      SceneTimeOfDay.night: ('🌙', 'Night'),
    };

    return Row(
      children: timeData.entries.map((e) {
        final sel = _time == e.key;
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: e.key == SceneTimeOfDay.night ? 0 : 8),
            child: SoundInkWell(
              onTap: () => setState(() => _time = e.key),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel
                      ? cs.secondary.withAlpha(30)
                      : (isDark
                          ? Colors.white.withAlpha(10)
                          : cs.onSurface.withAlpha(8)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel
                        ? cs.secondary
                        : (isDark
                            ? Colors.white.withAlpha(25)
                            : cs.onSurface.withAlpha(30)),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      e.value.$2,
                      style: TextStyle(
                        color: sel ? cs.secondary : textColor,
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, Color color) => Text(
        text,
        style:
            TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
      );

  String _description(TeacherPersonality p) {
    switch (p) {
      case TeacherPersonality.buddha:
        return 'Ancient wisdom and peaceful guidance for deep meditation, inner peace, and emotional healing.';
      case TeacherPersonality.zeno:
        return 'Modern coaching energy with motivational spirit and practical mindfulness for everyday life.';
      case TeacherPersonality.monk:
        return 'Traditional discipline and structured practice for building lasting meditation habits.';
      case TeacherPersonality.shiva:
        return 'Cosmic transformation and inner fire — guides you through transcendence and awakening.';
      case TeacherPersonality.tiger:
        return 'Warrior spirit and raw courage — harnesses power, focus, and fierce determination.';
    }
  }

  List<String> _traits(TeacherPersonality p) {
    switch (p) {
      case TeacherPersonality.buddha:
        return ['Compassion', 'Stillness', 'Wisdom', 'Equanimity'];
      case TeacherPersonality.zeno:
        return ['Energy', 'Motivation', 'Modern', 'Coaching'];
      case TeacherPersonality.monk:
        return ['Discipline', 'Focus', 'Tradition', 'Breathwork'];
      case TeacherPersonality.shiva:
        return ['Cosmic', 'Transformation', 'Fire', 'Transcendence'];
      case TeacherPersonality.tiger:
        return ['Power', 'Courage', 'Warrior', 'Intensity'];
    }
  }

  String _previewLine(TeacherPersonality p) {
    switch (p) {
      case TeacherPersonality.buddha:
        return 'Welcome. Let us find calm through breath and stillness.';
      case TeacherPersonality.zeno:
        return 'Hi, I am Zeno. Let us move, breathe, and grow stronger together.';
      case TeacherPersonality.monk:
        return 'Begin with one steady breath. Focus grows through patient practice.';
      case TeacherPersonality.shiva:
        return 'I am Shiva. Let the old dissolve. Let the new arise. Breathe.';
      case TeacherPersonality.tiger:
        return 'Warrior, your breath is your weapon. Focus. Strike with calm.';
    }
  }
}
