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
    final pulseIntensity = breathPhase == BreathPhase.inhale ? 1.2 : 
                          breathPhase == BreathPhase.exhale ? 0.8 : 1.0;
    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          appearance.auraPrimary.withAlpha((40 * auraIntensity * pulseIntensity).toInt()),
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
    final breathe = sin(envT * pi * 2) * 2.0;
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
    final legShadow = Paint()
      ..color = Colors.black.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    // Cross-legged position with better proportions
    final leftLegPath = Path()
      ..moveTo(-6, -6)
      ..cubicTo(-32, -2, -38, 12, -12, 24)
      ..cubicTo(-4, 26, 4, 24, 10, 22);
    
    final rightLegPath = Path()
      ..moveTo(6, -6)
      ..cubicTo(32, -2, 38, 12, 12, 24)
      ..cubicTo(4, 26, -4, 24, -10, 22);
    
    // Draw shadows
    canvas.drawPath(leftLegPath.shift(const Offset(2, 3)), legShadow);
    canvas.drawPath(rightLegPath.shift(const Offset(2, 3)), legShadow);
    
    // Draw legs with gradient
    final legPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [appearance.clothPrimary, appearance.clothSecondary],
      ).createShader(const Rect.fromLTWH(-40, -10, 80, 40));
    
    canvas.drawPath(leftLegPath, legPaint);
    canvas.drawPath(rightLegPath, legPaint);
    
    // Add cloth folds
    _drawClothFolds(canvas, leftLegPath, appearance.clothAccent);
    _drawClothFolds(canvas, rightLegPath, appearance.clothAccent);
  }
  
  void _drawPremiumTorso(Canvas canvas, double chestLift, double shoulderLift) {
    final torsoHeight = 85.0 * appearance.torsoScale;
    final torsoWidth = 44.0 * appearance.torsoScale;
    
    final torsoPath = Path()
      ..moveTo(-torsoWidth / 2, -torsoHeight + chestLift)
      ..cubicTo(
        -torsoWidth * 0.8, -torsoHeight * 0.6 + chestLift,
        -torsoWidth * 0.7, -torsoHeight * 0.3 + chestLift,
        -torsoWidth * 0.5, -torsoHeight * 0.1 + chestLift,
      )
      ..quadraticBezierTo(0, 5 + chestLift, torsoWidth * 0.5, -torsoHeight * 0.1 + chestLift)
      ..cubicTo(
        torsoWidth * 0.7, -torsoHeight * 0.3 + chestLift,
        torsoWidth * 0.8, -torsoHeight * 0.6 + chestLift,
        torsoWidth / 2, -torsoHeight + chestLift,
      )
      ..quadraticBezierTo(0, -torsoHeight * 1.1 + chestLift, -torsoWidth / 2, -torsoHeight + chestLift)
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
      ).createShader(Rect.fromLTWH(-torsoWidth, -torsoHeight, torsoWidth * 2, torsoHeight + 20));
    
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
    }
  }
  
  void _drawPremiumArms(Canvas canvas, double chestLift, double shoulderLift) {
    final armLength = 45.0 * appearance.limbScale;
    final armWidth = 12.0 * appearance.limbScale;
    
    // Left arm
    final leftArmPath = Path()
      ..moveTo(-20 * appearance.torsoScale, -60 * appearance.torsoScale + chestLift + shoulderLift)
      ..cubicTo(
        -35, -45 + shoulderLift,
        -32, -20,
        -15, -15,
      );
    
    // Right arm
    final rightArmPath = Path()
      ..moveTo(20 * appearance.torsoScale, -60 * appearance.torsoScale + chestLift + shoulderLift)
      ..cubicTo(
        35, -45 + shoulderLift,
        32, -20,
        15, -15,
      );
    
    final armPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [appearance.clothPrimary, appearance.clothSecondary],
      ).createShader(const Rect.fromLTWH(-40, -70, 80, 60));
    
    canvas.drawPath(leftArmPath, armPaint);
    canvas.drawPath(rightArmPath, armPaint);
    
    // Hands
    _drawHand(canvas, const Offset(-15, -15), appearance.skinPrimary);
    _drawHand(canvas, const Offset(15, -15), appearance.skinPrimary);
  }
  
  void _drawHand(Canvas canvas, Offset position, Color skinColor) {
    final handPaint = Paint()
      ..color = skinColor;
    canvas.drawOval(
      Rect.fromCenter(center: position, width: 10, height: 12),
      handPaint,
    );
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
      Rect.fromCenter(center: headCenter, width: headSize * 1.8, height: headSize * 2.0),
      headPaint,
    );
    
    // Hair based on personality
    _drawPremiumHair(canvas, headCenter, headSize);
    
    // Face features
    _drawPremiumFace(canvas, headCenter, headSize);
  }
  
  void _drawPremiumHair(Canvas canvas, Offset headCenter, double headSize) {
    final hairPaint = Paint()
      ..color = appearance.hairPrimary;
    
    switch (appearance.personality) {
      case TeacherPersonality.buddha:
        // Bun/jata style
        final bunPath = Path()
          ..moveTo(-headSize * 0.8, headCenter.dy - 5)
          ..cubicTo(
            -headSize, headCenter.dy - headSize * 0.8,
            -headSize * 0.3, headCenter.dy - headSize * 1.2,
            0, headCenter.dy - headSize * 1.1,
          )
          ..cubicTo(
            headSize * 0.3, headCenter.dy - headSize * 1.2,
            headSize, headCenter.dy - headSize * 0.8,
            headSize * 0.8, headCenter.dy - 5,
          )
          ..close();
        canvas.drawPath(bunPath, hairPaint);
        
        // Top bun
        canvas.drawCircle(
          Offset(headCenter.dx, headCenter.dy - headSize * 1.15),
          headSize * 0.35,
          Paint()..color = appearance.hairSecondary,
        );
        break;
        
      case TeacherPersonality.zeno:
        // Modern short hair
        final hairPath = Path()
          ..moveTo(-headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..lineTo(-headSize * 0.85, headCenter.dy - headSize * 0.7)
          ..quadraticBezierTo(0, headCenter.dy - headSize * 0.95, headSize * 0.85, headCenter.dy - headSize * 0.7)
          ..lineTo(headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;
        
      case TeacherPersonality.monk:
        // Shaved with slight stubble
        final stubblePaint = Paint()
          ..color = appearance.hairPrimary.withAlpha(80);
        canvas.drawCircle(
          headCenter,
          headSize * 0.95,
          stubblePaint,
        );
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
        Rect.fromCenter(center: Offset(-headSize * 0.25, eyeY), width: eyeSize * 2, height: eyeSize * 1.5),
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
        Rect.fromCenter(center: Offset(headSize * 0.25, eyeY), width: eyeSize * 2, height: eyeSize * 1.5),
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
      pi, pi, false, browPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(headSize * 0.15, browY + browLift, headSize * 0.25, 4),
      pi, pi, false, browPaint,
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
        Rect.fromLTWH(headCenter.dx - mouthWidth, mouthY, mouthWidth * 2, 4 + smileAmount),
        0.1, pi - 0.2, false, mouthPaint,
      );
    }
    
    // Cheeks (subtle blush)
    final cheekPaint = Paint()
      ..color = const Color(0xFFf28a91).withAlpha(40);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-headSize * 0.5, headCenter.dy + headSize * 0.2), width: 6, height: 4),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headSize * 0.5, headCenter.dy + headSize * 0.2), width: 6, height: 4),
      cheekPaint,
    );
  }
}
