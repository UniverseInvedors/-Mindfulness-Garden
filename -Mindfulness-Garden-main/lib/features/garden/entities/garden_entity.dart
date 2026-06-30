import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/garden_engine.dart';

/// Base class for all interactive entities in the garden
abstract class GardenEntity {
  /// Unique identifier for this entity
  final String id;
  
  /// World position (normalized coordinates)
  final Offset worldPosition;
  
  /// Bounding rectangle in world coordinates
  final Rect bounds;
  
  /// Z-index for rendering order (higher = on top)
  final int zIndex;
  
  /// Whether this entity is currently interactive
  bool isInteractive;
  
  /// Whether this entity is currently visible
  bool isVisible;
  
  GardenEntity({
    required this.id,
    required this.worldPosition,
    required this.bounds,
    this.zIndex = 0,
    this.isInteractive = true,
    this.isVisible = true,
  });
  
  /// Called when entity is tapped
  void onTap();
  
  /// Called when entity is long-pressed (>500ms)
  void onLongPress();
  
  /// Called when entity is dragged
  void onDrag(Offset delta);
  
  /// Update entity state (called every frame)
  void update(double deltaTime);
  
  /// Render the entity
  void render(Canvas canvas, Size viewportSize, Offset cameraOffset);
  
  /// Check if a point (in screen coordinates) hits this entity
  bool hitTest(Offset screenPoint, Size viewportSize, Offset cameraOffset) {
    // Convert screen point to world coordinates
    final worldPoint = screenPoint - cameraOffset;
    
    // Simple rectangle hit test (can be overridden for complex shapes)
    return bounds.contains(worldPoint);
  }
  
  /// Get the screen position for rendering
  Offset getScreenPosition(Size viewportSize, Offset cameraOffset) {
    return worldPosition - cameraOffset;
  }
}

/// Entity that can be planted (plants, trees, etc.)
abstract class PlantEntity extends GardenEntity {
  /// Plant lifecycle states
  PlantState state;
  
  /// Hydration level (0.0 - 1.0)
  double hydration;
  
  /// Growth progress (0.0 - 100.0)
  double growthProgress;
  
  /// Health level (0.0 - 100.0)
  double health;
  
  /// Plant level/rarity
  int level;
  
  /// Last time watered (timestamp)
  DateTime lastWatered;
  
  /// Care quality score (0.0 - 1.0)
  double careQuality;
  
  PlantEntity({
    required super.id,
    required super.worldPosition,
    required super.bounds,
    this.state = PlantState.seed,
    this.hydration = 0.7,
    this.growthProgress = 0.0,
    this.health = 100.0,
    this.level = 1,
    this.careQuality = 0.5,
    super.zIndex,
    super.isInteractive,
    super.isVisible,
  }) : lastWatered = DateTime.now();
  
  /// Water the plant
  void water(double amount) {
    hydration = (hydration + amount).clamp(0.0, 1.2);
    lastWatered = DateTime.now();
    
    // Overwater penalty
    if (hydration > 1.0) {
      health = max(0.0, health - (hydration - 1.0) * 10);
    }
    
    // Update care quality based on watering consistency
    final now = DateTime.now();
    final hoursSinceLastWater = now.difference(lastWatered).inHours;
    if (hoursSinceLastWater < 24) {
      careQuality = min(1.0, careQuality + 0.05);
    }
  }
  
  /// Apply neglect decay over time
  void applyNeglect(double deltaTimeHours) {
    // Hydration decay
    hydration = max(0.0, hydration - deltaTimeHours * 0.02);
    
    // Health decay when too dry
    if (hydration < 0.3) {
      health = max(0.0, health - deltaTimeHours * 2);
    }
    
    // Update state based on health
    if (health <= 0) {
      state = PlantState.dead;
    } else if (growthProgress >= 100) {
      state = PlantState.harvestable;
    } else if (growthProgress >= 70) {
      state = PlantState.mature;
    } else if (growthProgress >= 30) {
      state = PlantState.growing;
    }
  }
  
  /// Update growth based on current conditions
  void updateGrowth(double deltaTimeHours, double growthMultiplier) {
    if (state == PlantState.dead) return;
    
    // Growth rate depends on hydration, health, and season multiplier
    final growthRate = hydration * (health / 100) * growthMultiplier;
    growthProgress = min(100.0, growthProgress + deltaTimeHours * growthRate * 0.5);
    
    // Update state based on growth progress
    if (growthProgress >= 100) {
      state = PlantState.harvestable;
    } else if (growthProgress >= 70) {
      state = PlantState.mature;
    } else if (growthProgress >= 30) {
      state = PlantState.growing;
    }
  }
  
  /// Harvest the plant
  int harvest() {
    if (state != PlantState.harvestable) return 0;
    
    // Calculate reward based on care quality and level
    final baseReward = 10 * level;
    final qualityBonus = (careQuality * 100).toInt();
    final totalReward = baseReward + qualityBonus;
    
    // Reset to seed or upgrade tier based on care quality
    if (careQuality > 0.8) {
      // Perfect care - plant evolves to next tier
      level++;
      state = PlantState.seed;
      growthProgress = 0.0;
      hydration = 0.7;
      health = 100.0;
      careQuality = 0.5;
    } else {
      // Normal harvest - reset to seed
      state = PlantState.seed;
      growthProgress = 0.0;
      hydration = 0.7;
      health = 100.0;
      careQuality = 0.5;
    }
    
    return totalReward;
  }
}

/// Plant lifecycle states
enum PlantState {
  seed,      // Just planted
  growing,   // Actively growing
  mature,    // Fully grown but not ready for harvest
  harvestable, // Ready to harvest
  dead,      // Died from neglect
}

/// Meditator entity with AI behavior
class MeditatorEntity extends GardenEntity {
  /// Meditator states
  MeditatorState state;
  
  /// Breathing animation phase
  double breathPhase;
  
  /// Breathing frequency
  double breathFrequency;
  
  /// Disturbance level (0.0 - 1.0)
  double disturbance;
  
  /// Anger level (0.0 - 1.0)
  double anger;
  
  /// Time when last disturbed
  DateTime? lastDisturbed;
  
  /// Seasonal appearance modifier
  String? seasonalModifier;
  
  MeditatorEntity({
    required super.id,
    required super.worldPosition,
    required super.bounds,
    this.state = MeditatorState.calm,
    this.breathPhase = 0.0,
    this.breathFrequency = 0.5,
    this.disturbance = 0.0,
    this.anger = 0.0,
    this.seasonalModifier,
    super.zIndex = 10, // Meditators render on top
    super.isInteractive,
    super.isVisible,
  });
  
  @override
  void onTap() {
    if (!isInteractive) return;
    
    final now = DateTime.now();
    
    // Check if repeated tap (<2s interval)
    if (lastDisturbed != null) {
      final secondsSinceLast = now.difference(lastDisturbed!).inSeconds;
      if (secondsSinceLast < 2) {
        // Repeated tap - increase anger
        anger = min(1.0, anger + 0.3);
      }
    }
    
    // Single tap - increase disturbance
    disturbance = min(1.0, disturbance + 0.2);
    lastDisturbed = now;
    
    // Update state based on levels
    if (anger > 0.7) {
      state = MeditatorState.angry;
    } else if (disturbance > 0.4) {
      state = MeditatorState.disturbed;
    }
  }
  
  @override
  void onLongPress() {
    // Long press shows meditation info
    // Could show stats or start meditation session
  }
  
  @override
  void onDrag(Offset delta) {
    // Meditators typically don't drag
  }
  
  @override
  void update(double deltaTime) {
    // Update breathing animation
    breathPhase += deltaTime * breathFrequency;
    
    // Decay disturbance and anger over time
    disturbance = max(0.0, disturbance - deltaTime * 0.1);
    anger = max(0.0, anger - deltaTime * 0.05);
    
    // Update state based on levels
    if (anger > 0.7) {
      state = MeditatorState.angry;
    } else if (disturbance > 0.4) {
      state = MeditatorState.disturbed;
    } else if (anger < 0.1 && disturbance < 0.1) {
      state = MeditatorState.calm;
    }
    
    // Angry meditators may leave
    if (state == MeditatorState.angry && anger > 0.9) {
      state = MeditatorState.leaving;
    }
  }
  
  @override
  void render(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    // Implementation would draw meditator with breathing animation
    // and seasonal modifiers
  }
  
  /// Get the penalty for disturbing this meditator
  int getDisturbancePenalty() {
    if (state == MeditatorState.angry) {
      return 50; // Significant penalty for angry exit
    } else if (state == MeditatorState.disturbed) {
      return 10; // Minor penalty for disturbance
    }
    return 0;
  }
}

/// Meditator states
enum MeditatorState {
  calm,      // Peacefully meditating
  disturbed, // Slightly bothered
  angry,     // Very upset
  leaving,   // Leaving the garden
}

/// Tile entity (soil, path, pond, etc.)
class TileEntity extends GardenEntity {
  /// Tile type
  final TileType type;
  
  /// Whether this tile is walkable
  final bool isWalkable;
  
  /// Whether this tile is plantable
  final bool isPlantable;
  
  /// Fertility level (0.0 - 1.0)
  final double fertility;
  
  /// Proximity bonuses
  final Map<String, double> proximityBonuses;
  
  TileEntity({
    required super.id,
    required super.worldPosition,
    required super.bounds,
    required this.type,
    this.isWalkable = true,
    this.isPlantable = true,
    this.fertility = 0.5,
    this.proximityBonuses = const {},
    super.zIndex = -10, // Tiles render at bottom
    super.isInteractive,
    super.isVisible,
  });
  
  @override
  void onTap() {
    // Tile tap actions depend on type
    switch (type) {
      case TileType.pond:
        // Show pond info
        break;
      case TileType.fence:
        // Show blocked feedback
        break;
      case TileType.path:
        // Path info
        break;
      case TileType.soil:
        // Soil info or planting
        break;
    }
  }
  
  @override
  void onLongPress() {
    // Long press could show advanced options
    // like fertilize soil or remove obstacles
  }
  
  @override
  void onDrag(Offset delta) {
    // Tiles typically don't drag
  }
  
  @override
  void update(double deltaTime) {
    // Tiles are static, no update needed
  }
  
  @override
  void render(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    // Implementation would draw tile based on type
  }
  
  /// Get growth multiplier based on proximity bonuses
  double getGrowthMultiplier() {
    double multiplier = 1.0;
    proximityBonuses.forEach((key, value) {
      multiplier += value;
    });
    return multiplier;
  }
}

/// Tile types
enum TileType {
  soil,
  path,
  pond,
  fence,
}

/// Concrete implementation of PlantEntity
class BasicPlantEntity extends PlantEntity {
  /// Plant type
  final PlantType plantType;
  
  /// Visual variant
  final int variant;
  
  BasicPlantEntity({
    required super.id,
    required super.worldPosition,
    required super.bounds,
    required this.plantType,
    this.variant = 0,
    super.state,
    super.hydration,
    super.growthProgress,
    super.health,
    super.level,
    super.careQuality,
    super.zIndex,
    super.isInteractive,
    super.isVisible,
  });
  
  @override
  void onTap() {
    if (!isInteractive) return;
    
    // Show plant info or water on tap
    // For now, just water the plant
    water(0.1);
  }
  
  @override
  void onLongPress() {
    // Show detailed plant info or options
  }
  
  @override
  void onDrag(Offset delta) {
    // Plants typically don't drag
  }
  
  @override
  void update(double deltaTime) {
    // Apply neglect over time
    applyNeglect(deltaTime / 3600); // Convert to hours
    
    // Update growth (growth multiplier handled by weather)
    // updateGrowth is called by weather system
  }
  
  @override
  void render(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    final screenPos = getScreenPosition(viewportSize, cameraOffset);
    final paint = Paint()
      ..color = _getPlantColor()
      ..style = PaintingStyle.fill;
    
    // Draw a simple circle for the plant
    canvas.drawCircle(
      screenPos + Offset(bounds.width / 2, bounds.height / 2),
      bounds.width / 2 * (growthProgress / 100),
      paint,
    );
    
    // Draw health indicator
    if (health < 70) {
      final healthPaint = Paint()
        ..color = health < 30 ? Colors.red : Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(
        screenPos + Offset(bounds.width / 2, bounds.height / 2),
        bounds.width / 2 * (growthProgress / 100) + 5,
        healthPaint,
      );
    }
  }
  
  /// Get plant color based on type and state
  Color _getPlantColor() {
    if (state == PlantState.dead) return Colors.brown;
    
    return switch (plantType) {
      PlantType.flower => Colors.pink,
      PlantType.tree => Colors.green[800]!,
      PlantType.bush => Colors.green[600]!,
      PlantType.herb => Colors.green[400]!,
      PlantType.mushroom => Colors.brown[400]!,
      PlantType.cactus => Colors.green[700]!,
      PlantType.bamboo => Colors.green[500]!,
      PlantType.lotus => Colors.purple,
      PlantType.sunflower => Colors.yellow[700]!,
      PlantType.lavender => Colors.purple[300]!,
      PlantType.sage => Colors.green[300]!,
      PlantType.bonsai => Colors.green[900]!,
    };
  }
}
