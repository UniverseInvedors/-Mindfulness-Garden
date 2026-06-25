import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '../garden_world.dart';

class NPCComponent extends PositionComponent with HasGameRef, TapCallbacks {
  final NPCType npcType;
  bool isSelected = false;
  Vector2? targetPosition;

  NPCComponent({
    required Vector2 position,
    required this.npcType,
  }) : super(position: position, size: Vector2.all(30.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add hit box for interaction
    add(RectangleHitbox());
    
    // Render the NPC based on type
    _renderNPC();
    
    // Add idle animation
    _addIdleAnimation();
  }

  void _renderNPC() {
    switch (npcType) {
      case NPCType.gardener:
        _renderGardener();
        break;
      case NPCType.butterfly:
        _renderButterfly();
        break;
      case NPCType.bird:
        _renderBird();
        break;
      case NPCType.rabbit:
        _renderRabbit();
        break;
      case NPCType.turtle:
        _renderTurtle();
        break;
    }
  }

  void _renderGardener() {
    final skinPaint = Paint()
      ..color = const Color(0xFFFFCC80)
      ..style = PaintingStyle.fill;

    final clothesPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    // Body
    final body = CircleComponent(
      radius: 12.0,
      position: Vector2(15.0, 18.0),
      paint: clothesPaint,
    );
    add(body);
    
    // Head
    final head = CircleComponent(
      radius: 8.0,
      position: Vector2(15.0, 5.0),
      paint: skinPaint,
    );
    add(head);
    
    // Hat
    final hatPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final hat = CircleComponent(
      radius: 10.0,
      position: Vector2(15.0, 2.0),
      paint: hatPaint,
    );
    add(hat);
  }

  void _renderButterfly() {
    final wingPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    final bodyPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    // Body
    final body = RectangleComponent(
      size: Vector2(3.0, 15.0),
      position: Vector2(13.5, 7.5),
      paint: bodyPaint,
    );
    add(body);
    
    // Wings
    final leftWing = CircleComponent(
      radius: 10.0,
      position: Vector2(5.0, 10.0),
      paint: wingPaint,
    );
    add(leftWing);
    
    final rightWing = CircleComponent(
      radius: 10.0,
      position: Vector2(25.0, 10.0),
      paint: wingPaint,
    );
    add(rightWing);
  }

  void _renderBird() {
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.fill;

    final wingPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;

    // Body
    final body = CircleComponent(
      radius: 10.0,
      position: Vector2(15.0, 15.0),
      paint: bodyPaint,
    );
    add(body);
    
    // Wings
    final leftWing = CircleComponent(
      radius: 8.0,
      position: Vector2(5.0, 12.0),
      paint: wingPaint,
    );
    add(leftWing);
    
    final rightWing = CircleComponent(
      radius: 8.0,
      position: Vector2(25.0, 12.0),
      paint: wingPaint,
    );
    add(rightWing);
    
    // Beak
    final beakPaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..style = PaintingStyle.fill;

    final beak = RectangleComponent(
      size: Vector2(8.0, 3.0),
      position: Vector2(22.0, 8.0),
      paint: beakPaint,
    );
    add(beak);
  }

  void _renderRabbit() {
    final furPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;

    // Body
    final body = CircleComponent(
      radius: 12.0,
      position: Vector2(15.0, 18.0),
      paint: furPaint,
    );
    add(body);
    
    // Head
    final head = CircleComponent(
      radius: 10.0,
      position: Vector2(15.0, 5.0),
      paint: furPaint,
    );
    add(head);
    
    // Ears
    final leftEar = RectangleComponent(
      size: Vector2(4.0, 15.0),
      position: Vector2(10.0, -5.0),
      paint: furPaint,
    );
    add(leftEar);
    
    final rightEar = RectangleComponent(
      size: Vector2(4.0, 15.0),
      position: Vector2(16.0, -5.0),
      paint: furPaint,
    );
    add(rightEar);
    
    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    final leftEye = CircleComponent(
      radius: 2.0,
      position: Vector2(12.0, 5.0),
      paint: eyePaint,
    );
    add(leftEye);
    
    final rightEye = CircleComponent(
      radius: 2.0,
      position: Vector2(18.0, 5.0),
      paint: eyePaint,
    );
    add(rightEye);
  }

  void _renderTurtle() {
    final shellPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFF8BC34A)
      ..style = PaintingStyle.fill;

    // Shell
    final shell = CircleComponent(
      radius: 15.0,
      position: Vector2(15.0, 15.0),
      paint: shellPaint,
    );
    add(shell);
    
    // Head
    final head = CircleComponent(
      radius: 6.0,
      position: Vector2(30.0, 10.0),
      paint: skinPaint,
    );
    add(head);
    
    // Legs
    final frontLeftLeg = CircleComponent(
      radius: 4.0,
      position: Vector2(5.0, 20.0),
      paint: skinPaint,
    );
    add(frontLeftLeg);
    
    final frontRightLeg = CircleComponent(
      radius: 4.0,
      position: Vector2(25.0, 20.0),
      paint: skinPaint,
    );
    add(frontRightLeg);
    
    final backLeftLeg = CircleComponent(
      radius: 4.0,
      position: Vector2(8.0, 28.0),
      paint: skinPaint,
    );
    add(backLeftLeg);
    
    final backRightLeg = CircleComponent(
      radius: 4.0,
      position: Vector2(22.0, 28.0),
      paint: skinPaint,
    );
    add(backRightLeg);
  }

  void _addIdleAnimation() {
    // Add gentle bobbing animation
    final bobEffect = MoveEffect.by(
      Vector2(0, -5),
      EffectController(
        duration: 1.5,
        reverseDuration: 1.5,
        infinite: true,
      ),
    );
    add(bobEffect);
  }

  void moveTo(Vector2 target) {
    targetPosition = target;
    final moveEffect = MoveEffect.to(
      target,
      EffectController(duration: 2.0),
    );
    add(moveEffect);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }

  void onTap() {
    // Handle NPC interaction
    isSelected = !isSelected;
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }
}
