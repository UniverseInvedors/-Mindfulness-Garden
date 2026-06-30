import 'package:flutter/material.dart';
import 'package:pranaverse/core/widgets/character/premium_character_renderer.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';

class TeacherAvatar extends StatefulWidget {
  const TeacherAvatar({
    super.key,
    required this.teacher,
    this.isSpeaking = false,
    this.selected = false,
    this.background = true,
  });

  final TeacherPersonality teacher;
  final bool isSpeaking;
  final bool selected;
  final bool background;

  @override
  State<TeacherAvatar> createState() => _TeacherAvatarState();
}

class _TeacherAvatarState extends State<TeacherAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = TeacherAppearance.personalities[widget.teacher]!;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: widget.background
                  ? appearance.auraSecondary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: widget.selected
                  ? Border.all(color: appearance.auraPrimary, width: 2)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: _TeacherAvatarPainter(
                  appearance: appearance,
                  progress: _controller.value,
                  isSpeaking: widget.isSpeaking,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TeacherAvatarPainter extends CustomPainter {
  const _TeacherAvatarPainter({
    required this.appearance,
    required this.progress,
    required this.isSpeaking,
  });

  final TeacherAppearance appearance;
  final double progress;
  final bool isSpeaking;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.shortestSide / 180).clamp(0.16, 1.4);

    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.8);

    final renderer = PremiumCharacterRenderer(
      appearance: appearance,
      bodyScale: scale,
      auraIntensity: 0.82,
      breathPhase: BreathPhase.idle,
      envT: progress,
      isSpeaking: isSpeaking,
      lipT: progress,
    );
    renderer.drawCharacter(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TeacherAvatarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.appearance != appearance ||
        oldDelegate.isSpeaking != isSpeaking;
  }
}
