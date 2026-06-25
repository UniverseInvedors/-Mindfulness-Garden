import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GardenChunk extends PositionComponent {
  final int chunkX;
  final int chunkY;
  static const double chunkSize = 512.0;

  GardenChunk({
    required this.chunkX,
    required this.chunkY,
  }) : super(
          position: Vector2(chunkX * chunkSize, chunkY * chunkSize),
          size: Vector2.all(chunkSize),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create chunk background
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = _getChunkColor(),
    );
    add(background);
    
    // Add isometric grid lines
    _addIsometricGrid();
    
    // Add terrain features based on chunk position
    _addTerrainFeatures();
  }

  Color _getChunkColor() {
    // Vary the color slightly based on chunk position for visual variety
    final hue = (chunkX + chunkY) % 3;
    switch (hue) {
      case 0:
        return const Color(0xFF1A3A2A); // Dark green
      case 1:
        return const Color(0xFF1E4A35); // Medium green
      case 2:
        return const Color(0xFF225A40); // Light green
      default:
        return const Color(0xFF1A3A2A);
    }
  }

  void _addIsometricGrid() {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Create grid lines for isometric effect
    for (int i = 0; i <= 8; i++) {
      final x = (i * chunkSize / 8);
      final line = LineComponent(
        start: Vector2(x, 0),
        end: Vector2(x, chunkSize),
        paint: gridPaint,
      );
      add(line);
      
      final line2 = LineComponent(
        start: Vector2(0, x),
        end: Vector2(chunkSize, x),
        paint: gridPaint,
      );
      add(line2);
    }
  }

  void _addTerrainFeatures() {
    // Add water features in specific chunks
    if (_isWaterChunk()) {
      _addWaterFeature();
    }
    
    // Add paths in specific chunks
    if (_isPathChunk()) {
      _addPathFeature();
    }
    
    // Add flower beds in specific chunks
    if (_isFlowerChunk()) {
      _addFlowerBed();
    }
  }

  bool _isWaterChunk() {
    // Water in chunks with specific patterns
    return (chunkX + chunkY) % 5 == 0;
  }

  bool _isPathChunk() {
    // Paths in chunks with specific patterns
    return chunkX % 3 == 0 || chunkY % 3 == 0;
  }

  bool _isFlowerChunk() {
    // Flower beds in chunks with specific patterns
    return (chunkX * chunkY) % 4 == 1;
  }

  void _addWaterFeature() {
    final waterPaint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final water = RectangleComponent(
      size: Vector2(chunkSize * 0.6, chunkSize * 0.4),
      position: Vector2(chunkSize * 0.2, chunkSize * 0.3),
      paint: waterPaint,
    );
    add(water);
    
    // Add water ripple effect (simplified)
    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2.0;
    
    for (int i = 0; i < 3; i++) {
      final ripple = CircleComponent(
        radius: 20.0 + i * 15,
        position: Vector2(chunkSize * 0.5, chunkSize * 0.5),
        paint: ripplePaint,
      );
      add(ripple);
    }
  }

  void _addPathFeature() {
    final pathPaint = Paint()
      ..color = const Color(0xFF8B7355).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Create a winding path
    final path = RectangleComponent(
      size: Vector2(chunkSize * 0.3, chunkSize * 0.9),
      position: Vector2(chunkSize * 0.35, chunkSize * 0.05),
      paint: pathPaint,
    );
    add(path);
  }

  void _addFlowerBed() {
    final bedPaint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final bed = RectangleComponent(
      size: Vector2(chunkSize * 0.4, chunkSize * 0.4),
      position: Vector2(chunkSize * 0.3, chunkSize * 0.3),
      paint: bedPaint,
    );
    add(bed);
    
    // Add some flowers (simplified as colored circles)
    final flowerColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
    ];
    
    for (int i = 0; i < 8; i++) {
      final flowerPaint = Paint()
        ..color = flowerColors[i % flowerColors.length]
        ..style = PaintingStyle.fill;
      
      final flower = CircleComponent(
        radius: 8.0,
        position: Vector2(
          chunkSize * 0.3 + (i % 4) * 40.0,
          chunkSize * 0.3 + (i ~/ 4) * 40.0,
        ),
        paint: flowerPaint,
      );
      add(flower);
    }
  }
}
