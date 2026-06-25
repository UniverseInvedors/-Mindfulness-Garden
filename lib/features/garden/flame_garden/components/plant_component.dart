import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '../garden_world.dart';

class PlantComponent extends PositionComponent with HasGameRef, TapCallbacks {
  final PlantType plantType;
  int growthStage = 0;
  final int maxGrowthStage = 5;
  bool isSelected = false;

  PlantComponent({
    required Vector2 position,
    required this.plantType,
  }) : super(position: position, size: Vector2.all(40.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add hit box for interaction
    add(RectangleHitbox());
    
    // Render the plant based on type
    _renderPlant();
    
    // Add growth animation
    _addGrowthAnimation();
  }

  void _renderPlant() {
    final paint = Paint()..style = PaintingStyle.fill;
    
    switch (plantType) {
      case PlantType.flower:
        paint.color = const Color(0xFFFF6B6B);
        _renderFlower(paint);
        break;
      case PlantType.tree:
        paint.color = const Color(0xFF2E7D32);
        _renderTree(paint);
        break;
      case PlantType.bush:
        paint.color = const Color(0xFF4CAF50);
        _renderBush(paint);
        break;
      case PlantType.grass:
        paint.color = const Color(0xFF8BC34A);
        _renderGrass(paint);
        break;
      case PlantType.fern:
        paint.color = const Color(0xFF66BB6A);
        _renderFern(paint);
        break;
      case PlantType.bamboo:
        paint.color = const Color(0xFF43A047);
        _renderBamboo(paint);
        break;
      case PlantType.lotus:
        paint.color = const Color(0xFFE91E63);
        _renderLotus(paint);
        break;
      case PlantType.cherryBlossom:
        paint.color = const Color(0xFFF48FB1);
        _renderCherryBlossom(paint);
        break;
    }
  }

  void _renderFlower(Paint paint) {
    // Stem
    final stem = RectangleComponent(
      size: Vector2(4.0, 30.0),
      position: Vector2(18.0, 10.0),
      paint: Paint()..color = const Color(0xFF4CAF50),
    );
    add(stem);
    
    // Petals
    final petalCount = 5;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 360 / petalCount) * 3.14159 / 180;
      final petal = CircleComponent(
        radius: 8.0,
        position: Vector2(
          20.0 + (angle.cos * 8),
          5.0 + (angle.sin * 8),
        ),
        paint: paint,
      );
      add(petal);
    }
    
    // Center
    final center = CircleComponent(
      radius: 5.0,
      position: Vector2(20.0, 5.0),
      paint: Paint()..color = const Color(0xFFFFD54F),
    );
    add(center);
  }

  void _renderTree(Paint paint) {
    // Trunk
    final trunk = RectangleComponent(
      size: Vector2(12.0, 40.0),
      position: Vector2(14.0, 0.0),
      paint: Paint()..color = const Color(0xFF795548),
    );
    add(trunk);
    
    // Foliage
    final foliage = CircleComponent(
      radius: 25.0,
      position: Vector2(20.0, -10.0),
      paint: paint,
    );
    add(foliage);
  }

  void _renderBush(Paint paint) {
    final bush = CircleComponent(
      radius: 20.0,
      position: Vector2(20.0, 20.0),
      paint: paint,
    );
    add(bush);
    
    // Add some leaves
    for (int i = 0; i < 3; i++) {
      final leaf = CircleComponent(
        radius: 8.0,
        position: Vector2(
          10.0 + i * 10.0,
          15.0 + (i % 2) * 10.0,
        ),
        paint: paint,
      );
      add(leaf);
    }
  }

  void _renderGrass(Paint paint) {
    for (int i = 0; i < 5; i++) {
      final blade = RectangleComponent(
        size: Vector2(3.0, 15.0 + i * 2.0),
        position: Vector2(5.0 + i * 8.0, 25.0),
        paint: paint,
      );
      add(blade);
    }
  }

  void _renderFern(Paint paint) {
    // Main stem
    final stem = RectangleComponent(
      size: Vector2(3.0, 35.0),
      position: Vector2(18.5, 5.0),
      paint: paint,
    );
    add(stem);
    
    // Leaves
    for (int i = 0; i < 4; i++) {
      final leaf = RectangleComponent(
        size: Vector2(15.0, 4.0),
        position: Vector2(20.0, 10.0 + i * 8.0),
        paint: paint,
      );
      add(leaf);
    }
  }

  void _renderBamboo(Paint paint) {
    // Segments
    for (int i = 0; i < 4; i++) {
      final segment = RectangleComponent(
        size: Vector2(8.0, 10.0),
        position: Vector2(16.0, 30.0 - i * 10.0),
        paint: paint,
      );
      add(segment);
    }
    
    // Leaves at top
    for (int i = 0; i < 3; i++) {
      final leaf = RectangleComponent(
        size: Vector2(15.0, 3.0),
        position: Vector2(20.0 + i * 5.0, 5.0),
        paint: paint,
      );
      add(leaf);
    }
  }

  void _renderLotus(Paint paint) {
    // Pad
    final pad = CircleComponent(
      radius: 18.0,
      position: Vector2(20.0, 22.0),
      paint: Paint()..color = const Color(0xFF4CAF50),
    );
    add(pad);
    
    // Flower
    final petalCount = 6;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 360 / petalCount) * 3.14159 / 180;
      final petal = CircleComponent(
        radius: 10.0,
        position: Vector2(
          20.0 + (angle.cos * 8),
          15.0 + (angle.sin * 8),
        ),
        paint: paint,
      );
      add(petal);
    }
  }

  void _renderCherryBlossom(Paint paint) {
    // Trunk
    final trunk = RectangleComponent(
      size: Vector2(10.0, 35.0),
      position: Vector2(15.0, 5.0),
      paint: Paint()..color = const Color(0xFF8D6E63),
    );
    add(trunk);
    
    // Blossoms
    for (int i = 0; i < 8; i++) {
      final blossom = CircleComponent(
        radius: 6.0,
        position: Vector2(
          10.0 + (i % 4) * 10.0,
          (i ~/ 4) * 15.0,
        ),
        paint: paint,
      );
      add(blossom);
    }
  }

  void _addGrowthAnimation() {
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0 + growthStage * 0.2),
      EffectController(duration: 0.5),
    );
    add(scaleEffect);
  }

  void grow() {
    if (growthStage < maxGrowthStage) {
      growthStage++;
      _addGrowthAnimation();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }

  void onTap() {
    // Handle plant interaction
    if (growthStage < maxGrowthStage) {
      grow();
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }
}
