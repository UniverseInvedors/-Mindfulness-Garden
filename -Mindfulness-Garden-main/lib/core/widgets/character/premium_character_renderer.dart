import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'teacher_personality.dart';

// Premium 2.5D character renderer with improved proportions and animations
class PremiumCharacterRenderer {
  final TeacherAppearance appearance;
  final double bodyScale;
  final double auraIntensity;
  final BreathPhase breathPhase;
  final double envT; // Environment animation time
  final bool isSpeaking;
  final double lipT;

  PremiumCharacterRenderer({
    required this.appearance,
    required this.bodyScale,
    required this.auraIntensity,
    required this.breathPhase,
    required this.envT,
    required this.isSpeaking,
    required this.lipT,
  });

  // Draw the complete premium character
  // Note: Caller should handle canvas translation to desired position
  void drawCharacter(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(bodyScale * appearance.overallScale);

    // Draw enhanced aura with multiple layers
    _drawPremiumAura(canvas);

    // Draw shadow
    _drawShadow(canvas);

    // Draw character body with improved proportions
    _drawPremiumBody(canvas);

    canvas.restore();
  }

  void _drawPremiumAura(Canvas canvas) {
    // Multi-layered aura with gradient and glow
    final layers = 5;
    for (int i = layers; i >= 1; i--) {
      final radius = 50.0 + i * 18 * auraIntensity;
      final alpha = (15 * auraIntensity * (layers - i + 1) / layers).toInt();

      final auraPaint = Paint()
        ..color = appearance.auraPrimary.withAlpha(alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 + i * 2);

      canvas.drawCircle(Offset.zero, radius, auraPaint);

      // Secondary color ring
      if (i % 2 == 0) {
        final ringPaint = Paint()
          ..color = appearance.auraSecondary.withAlpha(alpha ~/ 2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset.zero, radius * 0.85, ringPaint);
      }
    }

    // Inner glow with breathing pulse
    final pulseIntensity = breathPhase == BreathPhase.inhale
        ? 1.2
        : breathPhase == BreathPhase.exhale
            ? 0.8
            : 1.0;
    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          appearance.auraPrimary
              .withAlpha((40 * auraIntensity * pulseIntensity).toInt()),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 60));
    canvas.drawCircle(Offset.zero, 60, innerGlow);
  }

  void _drawShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 75, height: 18),
      shadowPaint,
    );
  }

  void _drawPremiumBody(Canvas canvas) {
    // Breathing animation values
    final chestLift = _getChestLift();
    final shoulderLift = _getShoulderLift();

    // Draw legs with improved proportions
    _drawPremiumLegs(canvas, chestLift);

    // Draw torso with better shape
    _drawPremiumTorso(canvas, chestLift, shoulderLift);

    // Draw arms with natural joints
    _drawPremiumArms(canvas, chestLift, shoulderLift);

    // Draw premium head with detailed features
    _drawPremiumHead(canvas, chestLift);
  }

  double _getChestLift() {
    switch (breathPhase) {
      case BreathPhase.inhale:
        return -3.0;
      case BreathPhase.hold:
        return -1.5;
      case BreathPhase.exhale:
        return 2.0;
      case BreathPhase.rest:
        return 1.0;
      case BreathPhase.complete:
        return -0.5;
      case BreathPhase.idle:
        return 0.0;
    }
  }

  double _getShoulderLift() {
    switch (breathPhase) {
      case BreathPhase.inhale:
        return -2.0;
      case BreathPhase.hold:
        return -1.0;
      case BreathPhase.exhale:
        return 1.5;
      case BreathPhase.rest:
        return 0.5;
      case BreathPhase.complete:
        return -0.5;
      case BreathPhase.idle:
        return 0.0;
    }
  }

  void _drawPremiumLegs(Canvas canvas, double chestLift) {
    final ts = appearance.torsoScale;
    final legShadow = Paint()
      ..color = Colors.black.withAlpha(45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // ── Cloth gradient shared across leg surfaces ─────────────────────────
    final clothGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          appearance.clothPrimary,
          appearance.clothSecondary,
          Color.lerp(appearance.clothSecondary, Colors.black, 0.2)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTWH(-52, -18, 104, 52));

    final clothHighlight = Paint()
      ..color = Colors.white.withAlpha(28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final foldPaint = Paint()
      ..color = appearance.clothSecondary.withAlpha(110)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final skinPaint = Paint()
      ..shader = RadialGradient(
        colors: [appearance.skinPrimary, appearance.skinSecondary],
        center: const Alignment(-0.2, -0.3),
      ).createShader(const Rect.fromLTWH(-14, 8, 28, 20));

    final skinShadowPaint = Paint()
      ..color = appearance.skinShadow.withAlpha(80)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // ═════════════════════════════════════════════════════════════════════
    // LEFT LEG  (viewer's right) — crossed in front
    // thigh runs from hip out-left, bends at knee, lower leg tucks under
    // ═════════════════════════════════════════════════════════════════════

    // Upper thigh — thick, rounded, tapers at knee
    final lThigh = Path()
      ..moveTo(-8 * ts, -8) // inner hip
      ..cubicTo(-14 * ts, -12, -36, -8, -44, 4) // sweeping outward
      ..cubicTo(-46, 10, -42, 18, -36, 22) // around outer knee
      ..cubicTo(-30, 26, -22, 26, -14, 24) // across kneecap shelf
      ..cubicTo(-8, 22, -4, 14, -4, 6) // back to inner thigh
      ..cubicTo(-4, 0, -6, -6, -8 * ts, -8)
      ..close();

    canvas.drawPath(lThigh.shift(const Offset(1.5, 2.5)), legShadow);
    canvas.drawPath(lThigh, clothGrad);

    // Kneecap highlight
    final lKneePath = Path()
      ..addOval(Rect.fromCenter(
          center: const Offset(-36, 10), width: 14, height: 10));
    canvas.drawPath(
        lKneePath,
        Paint()
          ..color = appearance.clothPrimary.withAlpha(70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Lower leg — curves inward and tucks under
    final lLower = Path()
      ..moveTo(-36, 22)
      ..cubicTo(-30, 26, -18, 30, -8, 34) // shin curving inward
      ..cubicTo(-2, 36, 4, 36, 10, 34) // across ankle/foot top
      ..cubicTo(6, 30, 0, 26, -6, 24) // underside of lower leg
      ..cubicTo(-14, 22, -26, 22, -36, 22)
      ..close();

    canvas.drawPath(lLower.shift(const Offset(1, 2)), legShadow);
    canvas.drawPath(lLower, clothGrad);

    // Left foot — visible at the right side (toes pointing right)
    final lFoot = Path()
      ..moveTo(6, 28) // ankle
      ..cubicTo(12, 26, 20, 24, 26, 25) // top of foot
      ..cubicTo(28, 26, 28, 30, 26, 32) // toe tip curve
      ..cubicTo(20, 34, 12, 34, 6, 32) // sole
      ..cubicTo(4, 31, 4, 29, 6, 28)
      ..close();

    canvas.drawPath(lFoot.shift(const Offset(1, 2)), legShadow);
    canvas.drawPath(lFoot, skinPaint);
    // Toe separation lines
    for (int i = 0; i < 3; i++) {
      final tx = 20.0 + i * 2.5;
      canvas.drawLine(Offset(tx, 25.5), Offset(tx + 1, 32.5), skinShadowPaint);
    }
    // Foot highlight
    canvas.drawArc(
      const Rect.fromLTWH(8, 25, 14, 5),
      3.14,
      3.14,
      false,
      clothHighlight,
    );

    // Cloth folds on left thigh
    canvas.drawLine(const Offset(-28, 4), const Offset(-22, 18), foldPaint);
    canvas.drawLine(const Offset(-18, 2), const Offset(-12, 16), foldPaint);
    canvas.drawLine(const Offset(-38, 14), const Offset(-30, 24), foldPaint);

    // ═════════════════════════════════════════════════════════════════════
    // RIGHT LEG — crosses behind left, visible on outer right side
    // ═════════════════════════════════════════════════════════════════════

    // Draw right leg first (behind) — slightly smaller/dimmer for depth
    final depthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(appearance.clothPrimary, Colors.black, 0.15)!,
          Color.lerp(appearance.clothSecondary, Colors.black, 0.25)!,
        ],
      ).createShader(const Rect.fromLTWH(-52, -14, 104, 50));

    final rThigh = Path()
      ..moveTo(8 * ts, -8)
      ..cubicTo(14 * ts, -12, 38, -8, 46, 4)
      ..cubicTo(48, 10, 44, 18, 38, 22)
      ..cubicTo(30, 26, 20, 26, 12, 24)
      ..cubicTo(6, 22, 2, 14, 2, 6)
      ..cubicTo(2, 0, 4, -6, 8 * ts, -8)
      ..close();

    canvas.drawPath(rThigh.shift(const Offset(1.5, 2.5)), legShadow);
    canvas.drawPath(rThigh, depthPaint);

    // Right lower leg
    final rLower = Path()
      ..moveTo(38, 22)
      ..cubicTo(30, 26, 18, 30, 8, 34)
      ..cubicTo(2, 36, -4, 36, -10, 34)
      ..cubicTo(-6, 30, 0, 26, 6, 24)
      ..cubicTo(14, 22, 26, 22, 38, 22)
      ..close();

    canvas.drawPath(rLower.shift(const Offset(1, 2)), legShadow);
    canvas.drawPath(rLower, depthPaint);

    // Right foot — tucks under, visible at left
    final rFoot = Path()
      ..moveTo(-8, 28)
      ..cubicTo(-14, 26, -22, 24, -28, 25)
      ..cubicTo(-30, 26, -30, 30, -28, 32)
      ..cubicTo(-22, 34, -14, 34, -8, 32)
      ..cubicTo(-6, 31, -6, 29, -8, 28)
      ..close();

    canvas.drawPath(rFoot.shift(const Offset(1, 2)), legShadow);
    canvas.drawPath(rFoot, skinPaint);
    for (int i = 0; i < 3; i++) {
      final tx = -22.0 - i * 2.5;
      canvas.drawLine(Offset(tx, 25.5), Offset(tx - 1, 32.5), skinShadowPaint);
    }

    // Cloth folds on right thigh
    canvas.drawLine(const Offset(26, 4), const Offset(20, 18), foldPaint);
    canvas.drawLine(const Offset(16, 2), const Offset(10, 16), foldPaint);
    canvas.drawLine(const Offset(36, 14), const Offset(28, 24), foldPaint);

    // ── Lap centre overlap cloth — where legs cross in the middle ─────────
    final lapPath = Path()
      ..moveTo(-10, -4)
      ..cubicTo(-8, 8, -4, 20, 0, 26)
      ..cubicTo(4, 20, 8, 8, 10, -4)
      ..cubicTo(6, -8, -6, -8, -10, -4)
      ..close();

    canvas.drawPath(
        lapPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appearance.clothPrimary.withAlpha(200),
              appearance.clothSecondary.withAlpha(220),
            ],
          ).createShader(const Rect.fromLTWH(-12, -10, 24, 40)));

    // Central fold crease
    canvas.drawLine(
        const Offset(0, -2),
        const Offset(0, 22),
        Paint()
          ..color = appearance.clothSecondary.withAlpha(80)
          ..strokeWidth = 1.0);
  }

  void _drawPremiumTorso(Canvas canvas, double chestLift, double shoulderLift) {
    final torsoHeight = 85.0 * appearance.torsoScale;
    final torsoWidth = 44.0 * appearance.torsoScale;

    final torsoPath = Path()
      ..moveTo(-torsoWidth / 2, -torsoHeight + chestLift)
      ..cubicTo(
        -torsoWidth * 0.8,
        -torsoHeight * 0.6 + chestLift,
        -torsoWidth * 0.7,
        -torsoHeight * 0.3 + chestLift,
        -torsoWidth * 0.5,
        -torsoHeight * 0.1 + chestLift,
      )
      ..quadraticBezierTo(
          0, 5 + chestLift, torsoWidth * 0.5, -torsoHeight * 0.1 + chestLift)
      ..cubicTo(
        torsoWidth * 0.7,
        -torsoHeight * 0.3 + chestLift,
        torsoWidth * 0.8,
        -torsoHeight * 0.6 + chestLift,
        torsoWidth / 2,
        -torsoHeight + chestLift,
      )
      ..quadraticBezierTo(0, -torsoHeight * 1.1 + chestLift, -torsoWidth / 2,
          -torsoHeight + chestLift)
      ..close();

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(torsoPath.shift(const Offset(3, 4)), shadowPaint);

    // Torso gradient
    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          appearance.clothPrimary,
          appearance.clothSecondary,
          appearance.clothAccent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(
          -torsoWidth, -torsoHeight, torsoWidth * 2, torsoHeight + 20));

    canvas.drawPath(torsoPath, torsoPaint);

    // Add cloth details based on personality
    _drawClothDetails(canvas, torsoPath, chestLift);
  }

  void _drawClothFolds(Canvas canvas, Path path, Color accentColor) {
    final foldPaint = Paint()
      ..color = accentColor.withAlpha(80)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Simple fold lines
    canvas.drawLine(const Offset(-20, 8), const Offset(-10, 18), foldPaint);
    canvas.drawLine(const Offset(20, 8), const Offset(10, 18), foldPaint);
  }

  void _drawClothDetails(Canvas canvas, Path torsoPath, double chestLift) {
    switch (appearance.personality) {
      case TeacherPersonality.buddha:
        // Saffron robe details
        final detailPaint = Paint()
          ..color = appearance.clothAccent.withAlpha(100)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(-15, -70 + chestLift),
          Offset(-8, -30 + chestLift),
          detailPaint,
        );
        canvas.drawLine(
          Offset(15, -70 + chestLift),
          Offset(8, -30 + chestLift),
          detailPaint,
        );
        break;
      case TeacherPersonality.zeno:
        // Modern geometric patterns
        final patternPaint = Paint()
          ..color = appearance.clothAccent.withAlpha(60);
        canvas.drawCircle(
          Offset(0, -50 + chestLift),
          4,
          patternPaint,
        );
        break;
      case TeacherPersonality.monk:
        // Traditional robe folds
        final foldPaint = Paint()
          ..color = appearance.clothSecondary.withAlpha(120)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < 3; i++) {
          final y = -65 + i * 20 + chestLift;
          canvas.drawLine(
            Offset(-18, y),
            Offset(18, y),
            foldPaint,
          );
        }
        break;
      case TeacherPersonality.shiva:
        // Crescent moon mark on forehead (drawn on torso level as accent)
        // and serpent coil on wrist area
        final crescentPaint = Paint()
          ..color = Colors.white.withAlpha(180)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        // Sacred ash tripundra lines on chest
        for (int i = 0; i < 3; i++) {
          final y = -60 + i * 10 + chestLift;
          canvas.drawLine(Offset(-12, y), Offset(12, y), crescentPaint);
        }
        // Blue glow circle (third eye on forehead level)
        final thirdEyePaint = Paint()
          ..color = const Color(0xFF00e5ff).withAlpha(200);
        canvas.drawCircle(Offset(0, -52 + chestLift), 3.5, thirdEyePaint);
        break;
      case TeacherPersonality.tiger:
        // Tiger stripe pattern on torso
        final stripePaint = Paint()
          ..color = appearance.clothSecondary.withAlpha(140)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        // Diagonal stripes
        for (int i = 0; i < 4; i++) {
          final y = -72 + i * 18 + chestLift;
          canvas.drawLine(
            Offset(-20, y),
            Offset(-8, y + 12),
            stripePaint,
          );
          canvas.drawLine(
            Offset(8, y),
            Offset(20, y + 12),
            stripePaint,
          );
        }
        break;
    }
  }

  void _drawPremiumArms(Canvas canvas, double chestLift, double shoulderLift) {
    final ts = appearance.torsoScale;

    final armShadow = Paint()
      ..color = Colors.black.withAlpha(35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final armPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [appearance.clothPrimary, appearance.clothSecondary],
      ).createShader(const Rect.fromLTWH(-44, -72, 88, 70));

    // ── Left arm ─────────────────────────────────────────────────────────
    // Upper arm from shoulder down to elbow, forearm rests on left knee
    final lUpper = Path()
      ..moveTo(-20 * ts, -60 * ts + chestLift + shoulderLift)
      ..cubicTo(-28, -52 + shoulderLift, -36, -40, -38, -26)
      ..cubicTo(-40, -20, -40, -14, -38, -10)
      ..cubicTo(-34, -8, -28, -8, -24, -10)
      ..cubicTo(-20, -14, -18, -22, -18, -30)
      ..cubicTo(
          -18, -44, -16, -56, -20 * ts, -60 * ts + chestLift + shoulderLift)
      ..close();

    canvas.drawPath(lUpper.shift(const Offset(1.5, 2.5)), armShadow);
    canvas.drawPath(lUpper, armPaint);

    // Left forearm — angled down onto left knee, resting naturally
    final lFore = Path()
      ..moveTo(-38, -10) // elbow
      ..cubicTo(-40, -4, -38, 6, -34, 14) // forearm curving onto knee
      ..cubicTo(-30, 18, -22, 20, -16, 18)
      ..cubicTo(-12, 16, -12, 10, -14, 4)
      ..cubicTo(-16, -2, -20, -8, -24, -10)
      ..close();

    canvas.drawPath(lFore.shift(const Offset(1.5, 2.5)), armShadow);
    canvas.drawPath(lFore, armPaint);

    // ── Right arm ────────────────────────────────────────────────────────
    final rUpper = Path()
      ..moveTo(20 * ts, -60 * ts + chestLift + shoulderLift)
      ..cubicTo(28, -52 + shoulderLift, 36, -40, 38, -26)
      ..cubicTo(40, -20, 40, -14, 38, -10)
      ..cubicTo(34, -8, 28, -8, 24, -10)
      ..cubicTo(20, -14, 18, -22, 18, -30)
      ..cubicTo(18, -44, 16, -56, 20 * ts, -60 * ts + chestLift + shoulderLift)
      ..close();

    canvas.drawPath(rUpper.shift(const Offset(1.5, 2.5)), armShadow);
    canvas.drawPath(rUpper, armPaint);

    // Right forearm
    final rFore = Path()
      ..moveTo(38, -10)
      ..cubicTo(40, -4, 38, 6, 34, 14)
      ..cubicTo(30, 18, 22, 20, 16, 18)
      ..cubicTo(12, 16, 12, 10, 14, 4)
      ..cubicTo(16, -2, 20, -8, 24, -10)
      ..close();

    canvas.drawPath(rFore.shift(const Offset(1.5, 2.5)), armShadow);
    canvas.drawPath(rFore, armPaint);

    // ── Hands resting on knees ─────────────────────────────────────────
    // Left hand — gyan mudra (index to thumb, rest extended)
    _drawMeditationHand(canvas, const Offset(-20, 18), appearance.skinPrimary,
        appearance.skinSecondary, appearance.skinShadow, false);

    // Right hand — gyan mudra mirrored
    _drawMeditationHand(canvas, const Offset(20, 18), appearance.skinPrimary,
        appearance.skinSecondary, appearance.skinShadow, true);

    // Cloth fold accents on forearms
    final foldPaint = Paint()
      ..color = appearance.clothAccent.withAlpha(70)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-34, -6), const Offset(-26, 10), foldPaint);
    canvas.drawLine(const Offset(-30, -4), const Offset(-22, 12), foldPaint);
    canvas.drawLine(const Offset(34, -6), const Offset(26, 10), foldPaint);
    canvas.drawLine(const Offset(30, -4), const Offset(22, 12), foldPaint);
  }

  void _drawMeditationHand(Canvas canvas, Offset center, Color skin,
      Color skinMid, Color skinDark, bool isRight) {
    final flip = isRight ? 1.0 : -1.0;
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Palm
    final palmPaint = Paint()
      ..shader = RadialGradient(
        colors: [skin, skinMid],
        center: const Alignment(-0.2, -0.3),
      ).createShader(Rect.fromCenter(center: center, width: 18, height: 14));

    final palm = Path()
      ..addOval(Rect.fromCenter(center: center, width: 16, height: 12));
    canvas.drawPath(palm.shift(const Offset(1, 1.5)), shadowPaint);
    canvas.drawPath(palm, palmPaint);

    // Fingers — four small rounded stubs side by side
    for (int i = 0; i < 4; i++) {
      final fx = center.dx + flip * (i * 3.5 - 5.0);
      final fy = center.dy - 7;
      final fingerPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(fx, fy), width: 3.2, height: 6),
          const Radius.circular(2),
        ));
      canvas.drawPath(fingerPath, Paint()..color = skin);
      canvas.drawPath(
          fingerPath,
          Paint()
            ..color = skinDark.withAlpha(40)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
    }

    // Thumb — angled outward
    final thumbPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + flip * 9, center.dy - 2),
          width: 5,
          height: 3,
        ),
        const Radius.circular(2),
      ));
    canvas.drawPath(thumbPath, Paint()..color = skin);
  }

  void _drawPremiumHead(Canvas canvas, double chestLift) {
    final headY = -95 * appearance.headScale + chestLift;
    final headSize = 22.0 * appearance.headScale;

    // Head bob when speaking
    final headBob = isSpeaking ? sin(envT * pi * 12) * 0.8 : 0.0;
    final headCenter = Offset(0, headY + headBob);

    // Neck
    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [appearance.skinPrimary, appearance.skinSecondary],
      ).createShader(Rect.fromLTWH(-8, headY + 15, 16, 18));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-7, headY + 16, 14, 14),
        const Radius.circular(5),
      ),
      neckPaint,
    );

    // Head shadow
    final headShadow = Paint()
      ..color = Colors.black.withAlpha(20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      headCenter + const Offset(2, 3),
      headSize + 2,
      headShadow,
    );

    // Head with gradient
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          appearance.skinPrimary,
          appearance.skinSecondary,
          appearance.skinShadow,
        ],
        center: const Alignment(-0.2, -0.2),
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headSize));

    canvas.drawOval(
      Rect.fromCenter(
          center: headCenter, width: headSize * 1.8, height: headSize * 2.0),
      headPaint,
    );

    // Hair based on personality
    _drawPremiumHair(canvas, headCenter, headSize);

    // Face features
    _drawPremiumFace(canvas, headCenter, headSize);
  }

  void _drawPremiumHair(Canvas canvas, Offset headCenter, double headSize) {
    final hairPaint = Paint()..color = appearance.hairPrimary;

    switch (appearance.personality) {
      case TeacherPersonality.buddha:
        final bunPath = Path()
          ..moveTo(-headSize * 0.8, headCenter.dy - 5)
          ..cubicTo(-headSize, headCenter.dy - headSize * 0.8, -headSize * 0.3,
              headCenter.dy - headSize * 1.2, 0, headCenter.dy - headSize * 1.1)
          ..cubicTo(headSize * 0.3, headCenter.dy - headSize * 1.2, headSize,
              headCenter.dy - headSize * 0.8, headSize * 0.8, headCenter.dy - 5)
          ..close();
        canvas.drawPath(bunPath, hairPaint);
        canvas.drawCircle(
            Offset(headCenter.dx, headCenter.dy - headSize * 1.15),
            headSize * 0.35,
            Paint()..color = appearance.hairSecondary);
        break;

      case TeacherPersonality.zeno:
        final hairPath = Path()
          ..moveTo(-headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..lineTo(-headSize * 0.85, headCenter.dy - headSize * 0.7)
          ..quadraticBezierTo(0, headCenter.dy - headSize * 0.95,
              headSize * 0.85, headCenter.dy - headSize * 0.7)
          ..lineTo(headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case TeacherPersonality.monk:
        canvas.drawCircle(headCenter, headSize * 0.95,
            Paint()..color = appearance.hairPrimary.withAlpha(80));
        break;

      case TeacherPersonality.shiva:
        // Matted jata piled high with crescent moon
        final jataPath = Path()
          ..moveTo(-headSize * 0.9, headCenter.dy - headSize * 0.4)
          ..cubicTo(
              -headSize * 1.1,
              headCenter.dy - headSize * 1.0,
              -headSize * 0.5,
              headCenter.dy - headSize * 1.6,
              0,
              headCenter.dy - headSize * 1.5)
          ..cubicTo(
              headSize * 0.5,
              headCenter.dy - headSize * 1.6,
              headSize * 1.1,
              headCenter.dy - headSize * 1.0,
              headSize * 0.9,
              headCenter.dy - headSize * 0.4)
          ..close();
        canvas.drawPath(jataPath, hairPaint);
        // Crescent moon
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(headCenter.dx - headSize * 0.1,
                  headCenter.dy - headSize * 1.3),
              width: headSize * 0.5,
              height: headSize * 0.4),
          3.14,
          3.14,
          false,
          Paint()
            ..color = Colors.white.withAlpha(220)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        // Ganga river flowing from hair
        canvas.drawLine(
          Offset(headSize * 0.6, headCenter.dy - headSize * 0.6),
          Offset(headSize * 0.8, headCenter.dy + headSize * 0.2),
          Paint()
            ..color = const Color(0xFF00e5ff).withAlpha(120)
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke,
        );
        break;

      case TeacherPersonality.tiger:
        // Warrior topknot
        final topknotPath = Path()
          ..moveTo(-headSize * 0.85, headCenter.dy - headSize * 0.5)
          ..cubicTo(
              -headSize * 0.7,
              headCenter.dy - headSize * 0.9,
              -headSize * 0.2,
              headCenter.dy - headSize * 1.0,
              0,
              headCenter.dy - headSize * 0.98)
          ..cubicTo(
              headSize * 0.2,
              headCenter.dy - headSize * 1.0,
              headSize * 0.7,
              headCenter.dy - headSize * 0.9,
              headSize * 0.85,
              headCenter.dy - headSize * 0.5)
          ..close();
        canvas.drawPath(topknotPath, hairPaint);
        canvas.drawCircle(
            Offset(headCenter.dx, headCenter.dy - headSize * 1.05),
            headSize * 0.22,
            Paint()..color = appearance.hairSecondary);
        // Tiger stripe face paint
        final facePaintBrush = Paint()
          ..color = const Color(0xFFff6d00).withAlpha(160)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
            Offset(-headSize * 0.7, headCenter.dy + headSize * 0.1),
            Offset(-headSize * 0.35, headCenter.dy + headSize * 0.2),
            facePaintBrush);
        canvas.drawLine(
            Offset(headSize * 0.35, headCenter.dy + headSize * 0.1),
            Offset(headSize * 0.7, headCenter.dy + headSize * 0.2),
            facePaintBrush);
        break;
    }
  }

  void _drawPremiumFace(Canvas canvas, Offset headCenter, double headSize) {
    // Eyes with blinking
    final blink = sin(envT * pi * 2 * 0.5) > 0.97;
    final eyeSize = 3.5 * appearance.eyeSize;
    final eyeY = headCenter.dy - headSize * 0.15;

    if (blink) {
      // Closed eyes
      final eyePaint = Paint()
        ..color = appearance.skinShadow
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(-headSize * 0.35, eyeY),
        Offset(-headSize * 0.15, eyeY),
        eyePaint,
      );
      canvas.drawLine(
        Offset(headSize * 0.15, eyeY),
        Offset(headSize * 0.35, eyeY),
        eyePaint,
      );
    } else {
      // Open eyes with detail
      final eyeWhite = Paint()..color = Colors.white;
      final eyeIris = Paint()..color = const Color(0xFF4a3728);
      final eyePupil = Paint()..color = Colors.black;

      // Left eye
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-headSize * 0.25, eyeY),
            width: eyeSize * 2,
            height: eyeSize * 1.5),
        eyeWhite,
      );
      canvas.drawCircle(
        Offset(-headSize * 0.25, eyeY),
        eyeSize * 0.6,
        eyeIris,
      );
      canvas.drawCircle(
        Offset(-headSize * 0.25, eyeY),
        eyeSize * 0.3,
        eyePupil,
      );

      // Right eye
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(headSize * 0.25, eyeY),
            width: eyeSize * 2,
            height: eyeSize * 1.5),
        eyeWhite,
      );
      canvas.drawCircle(
        Offset(headSize * 0.25, eyeY),
        eyeSize * 0.6,
        eyeIris,
      );
      canvas.drawCircle(
        Offset(headSize * 0.25, eyeY),
        eyeSize * 0.3,
        eyePupil,
      );

      // Eye highlight
      final highlightPaint = Paint()..color = Colors.white.withAlpha(200);
      canvas.drawCircle(
        Offset(-headSize * 0.25 - 1, eyeY - 1),
        1.0,
        highlightPaint,
      );
      canvas.drawCircle(
        Offset(headSize * 0.25 - 1, eyeY - 1),
        1.0,
        highlightPaint,
      );
    }

    // Eyebrows
    final browPaint = Paint()
      ..color = appearance.hairPrimary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final browY = eyeY - headSize * 0.2;
    final browLift = breathPhase == BreathPhase.inhale ? -2.0 : 0.0;
    canvas.drawArc(
      Rect.fromLTWH(-headSize * 0.4, browY + browLift, headSize * 0.25, 4),
      pi,
      pi,
      false,
      browPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(headSize * 0.15, browY + browLift, headSize * 0.25, 4),
      pi,
      pi,
      false,
      browPaint,
    );

    // Nose
    final nosePaint = Paint()
      ..color = appearance.skinShadow.withAlpha(150)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final noseSize = 4.0 * appearance.noseSize;
    final nosePath = Path()
      ..moveTo(headCenter.dx, headCenter.dy + headSize * 0.1)
      ..lineTo(headCenter.dx, headCenter.dy + headSize * 0.25)
      ..lineTo(headCenter.dx - noseSize * 0.5, headCenter.dy + headSize * 0.25);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth with speaking animation
    final mouthY = headCenter.dy + headSize * 0.35;
    final mouthWidth = 6.0 * appearance.mouthWidth;

    if (isSpeaking) {
      final mouthOpen = 0.3 + lipT * 0.7;
      final mouthPaint = Paint()..color = appearance.skinShadow;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headCenter.dx, mouthY),
          width: mouthWidth + lipT * 3,
          height: 3 + mouthOpen * 5,
        ),
        mouthPaint,
      );
    } else {
      final mouthPaint = Paint()
        ..color = appearance.skinShadow
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final smileAmount = breathPhase == BreathPhase.complete ? 3.0 : 1.5;
      canvas.drawArc(
        Rect.fromLTWH(headCenter.dx - mouthWidth, mouthY, mouthWidth * 2,
            4 + smileAmount),
        0.1,
        pi - 0.2,
        false,
        mouthPaint,
      );
    }

    // Cheeks (subtle blush)
    final cheekPaint = Paint()..color = const Color(0xFFf28a91).withAlpha(40);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-headSize * 0.5, headCenter.dy + headSize * 0.2),
          width: 6,
          height: 4),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headSize * 0.5, headCenter.dy + headSize * 0.2),
          width: 6,
          height: 4),
      cheekPaint,
    );
  }
}
