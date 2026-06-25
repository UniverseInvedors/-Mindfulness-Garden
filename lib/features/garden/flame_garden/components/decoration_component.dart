import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '../garden_world.dart';

class DecorationComponent extends PositionComponent with HasGameRef, TapCallbacks {
  final DecorationType decorationType;
  bool isSelected = false;

  DecorationComponent({
    required Vector2 position,
    required this.decorationType,
  }) : super(position: position, size: Vector2.all(50.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add hit box for interaction
    add(RectangleHitbox());
    
    // Render the decoration based on type
    _renderDecoration();
  }

  void _renderDecoration() {
    switch (decorationType) {
      case DecorationType.rock:
        _renderRock();
        break;
      case DecorationType.path:
        _renderPath();
        break;
      case DecorationType.bridge:
        _renderBridge();
        break;
      case DecorationType.fountain:
        _renderFountain();
        break;
      case DecorationType.lantern:
        _renderLantern();
        break;
      case DecorationType.bench:
        _renderBench();
        break;
      case DecorationType.statue:
        _renderStatue();
        break;
      case DecorationType.waterfall:
        _renderWaterfall();
        break;
    }
  }

  void _renderRock() {
    final rockPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;

    final rock = CircleComponent(
      radius: 20.0,
      position: Vector2(25.0, 25.0),
      paint: rockPaint,
    );
    add(rock);
    
    // Add some texture
    final texturePaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;
    
    final texture = CircleComponent(
      radius: 8.0,
      position: Vector2(20.0, 20.0),
      paint: texturePaint,
    );
    add(texture);
  }

  void _renderPath() {
    final pathPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    final path = RectangleComponent(
      size: Vector2(60.0, 40.0),
      position: Vector2(-5.0, 5.0),
      paint: pathPaint,
    );
    add(path);
    
    // Add stepping stones
    final stonePaint = Paint()
      ..color = const Color(0xFFA1887F)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final stone = CircleComponent(
        radius: 6.0,
        position: Vector2(10.0 + i * 20.0, 25.0),
        paint: stonePaint,
      );
      add(stone);
    }
  }

  void _renderBridge() {
    final bridgePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    // Bridge deck
    final deck = RectangleComponent(
      size: Vector2(80.0, 15.0),
      position: Vector2(-15.0, 17.5),
      paint: bridgePaint,
    );
    add(deck);
    
    // Railings
    final railPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.fill;
    
    final leftRail = RectangleComponent(
      size: Vector2(5.0, 25.0),
      position: Vector2(-15.0, 12.5),
      paint: railPaint,
    );
    add(leftRail);
    
    final rightRail = RectangleComponent(
      size: Vector2(5.0, 25.0),
      position: Vector2(60.0, 12.5),
      paint: railPaint,
    );
    add(rightRail);
  }

  void _renderFountain() {
    final basePaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;

    final base = CircleComponent(
      radius: 25.0,
      position: Vector2(25.0, 25.0),
      paint: basePaint,
    );
    add(base);
    
    // Water
    final waterPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final water = CircleComponent(
      radius: 18.0,
      position: Vector2(25.0, 25.0),
      paint: waterPaint,
    );
    add(water);
    
    // Center spout
    final spoutPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;

    final spout = RectangleComponent(
      size: Vector2(6.0, 15.0),
      position: Vector2(22.0, 10.0),
      paint: spoutPaint,
    );
    add(spout);
  }

  void _renderLantern() {
    final postPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    final post = RectangleComponent(
      size: Vector2(8.0, 30.0),
      position: Vector2(21.0, 20.0),
      paint: postPaint,
    );
    add(post);
    
    // Lantern body
    final lanternPaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..style = PaintingStyle.fill;

    final lantern = RectangleComponent(
      size: Vector2(20.0, 20.0),
      position: Vector2(15.0, 0.0),
      paint: lanternPaint,
    );
    add(lantern);
    
    // Glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final glow = CircleComponent(
      radius: 15.0,
      position: Vector2(25.0, 10.0),
      paint: glowPaint,
    );
    add(glow);
  }

  void _renderBench() {
    final benchPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    // Seat
    final seat = RectangleComponent(
      size: Vector2(50.0, 8.0),
      position: Vector2(0.0, 25.0),
      paint: benchPaint,
    );
    add(seat);
    
    // Back
    final back = RectangleComponent(
      size: Vector2(50.0, 15.0),
      position: Vector2(0.0, 10.0),
      paint: benchPaint,
    );
    add(back);
    
    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.fill;

    final leftLeg = RectangleComponent(
      size: Vector2(6.0, 15.0),
      position: Vector2(5.0, 33.0),
      paint: legPaint,
    );
    add(leftLeg);
    
    final rightLeg = RectangleComponent(
      size: Vector2(6.0, 15.0),
      position: Vector2(39.0, 33.0),
      paint: legPaint,
    );
    add(rightLeg);
  }

  void _renderStatue() {
    final statuePaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.fill;

    // Base
    final base = RectangleComponent(
      size: Vector2(30.0, 10.0),
      position: Vector2(10.0, 40.0),
      paint: statuePaint,
    );
    add(base);
    
    // Body
    final body = CircleComponent(
      radius: 15.0,
      position: Vector2(25.0, 25.0),
      paint: statuePaint,
    );
    add(body);
    
    // Head
    final head = CircleComponent(
      radius: 8.0,
      position: Vector2(25.0, 5.0),
      paint: statuePaint,
    );
    add(head);
  }

  void _renderWaterfall() {
    // Water source
    final sourcePaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;

    final source = RectangleComponent(
      size: Vector2(40.0, 20.0),
      position: Vector2(5.0, -5.0),
      paint: sourcePaint,
    );
    add(source);
    
    // Water stream
    final waterPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final stream = RectangleComponent(
      size: Vector2(20.0, 50.0),
      position: Vector2(15.0, 15.0),
      paint: waterPaint,
    );
    add(stream);
    
    // Pool at bottom
    final poolPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final pool = CircleComponent(
      radius: 25.0,
      position: Vector2(25.0, 65.0),
      paint: poolPaint,
    );
    add(pool);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }

  void onTap() {
    // Handle decoration interaction
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
