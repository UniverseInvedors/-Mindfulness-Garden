import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/garden_entity.dart';
import '../systems/interaction_manager.dart';
import '../systems/camera_controller.dart';
import '../systems/weather_engine.dart';

/// Main garden engine that coordinates all systems
class GardenEngine {
  /// Camera controller for viewport management
  final CameraController cameraController;
  
  /// Interaction manager for pointer events
  final InteractionManager interactionManager;
  
  /// Weather engine for seasonal effects
  final WeatherEngine weatherEngine;
  
  /// Economy system for currency and rewards (now handled by WalletService)
  /// This is kept for backward compatibility but will be deprecated
  // final EconomySystem economySystem;
  
  /// All entities in the garden
  final List<GardenEntity> entities;
  
  /// Whether the engine is running
  bool isRunning;
  
  /// Last update time (for delta time calculation)
  DateTime _lastUpdateTime;
  
  /// Frame time accumulator
  double _frameTimeAccumulator;
  
  /// Target frame time (seconds)
  static const double targetFrameTime = 1.0 / 60.0; // 60 FPS
  
  /// Chunk size for infinite world
  final double chunkSize;
  
  /// Loaded chunks
  final Map<Point<int>, List<GardenEntity>> loadedChunks;
  
  /// Callback for when entities are added/removed
  final void Function(List<GardenEntity> entities)? onEntitiesChanged;
  
  /// Callback for when camera changes
  final void Function(Offset position, double zoom)? onCameraChanged;
  
  /// Callback for when weather changes
  final void Function(WeatherState state)? onWeatherChanged;
  
  /// Callback for when economy changes
  final void Function(Map<String, dynamic> stats)? onEconomyChanged;
  
  GardenEngine({
    CameraController? cameraController,
    InteractionManager? interactionManager,
    WeatherEngine? weatherEngine,
    // EconomySystem? economySystem,
    this.chunkSize = 1000.0,
    this.onEntitiesChanged,
    this.onCameraChanged,
    this.onWeatherChanged,
    this.onEconomyChanged,
  })  : cameraController = cameraController ?? CameraController(),
        weatherEngine = weatherEngine ?? WeatherEngine(),
        // economySystem = economySystem ?? EconomySystem(),
        entities = [],
        isRunning = false,
        _lastUpdateTime = DateTime.now(),
        _frameTimeAccumulator = 0.0,
        loadedChunks = {},
        interactionManager = interactionManager ?? InteractionManager(entities: []) {
    // Initialize interaction manager with empty list
    // Will be updated after entities are loaded
    
    // Note: WeatherEngine callbacks are set in constructor
    // They will call onWeatherChanged and onTimeChanged callbacks
    // and apply effects
  }
  
  /// Initialize the garden engine
  Future<void> initialize() async {
    // Load initial chunks around origin
    _loadInitialChunks();
    
    // Update interaction manager with loaded entities
    interactionManager.entities.clear();
    interactionManager.entities.addAll(entities);
    interactionManager.rebuildSpatialGrid();
    
    isRunning = true;
    _lastUpdateTime = DateTime.now();
  }
  
  /// Load initial chunks around the camera
  void _loadInitialChunks() {
    // For now, load a single chunk at origin
    final originChunk = Point<int>(0, 0);
    _loadChunk(originChunk);
  }
  
  /// Load a specific chunk
  void _loadChunk(Point<int> chunkCoord) {
    if (loadedChunks.containsKey(chunkCoord)) return;
    
    final chunkEntities = _generateChunkEntities(chunkCoord);
    loadedChunks[chunkCoord] = chunkEntities;
    
    // Add to main entities list
    entities.addAll(chunkEntities);
    
    // Update interaction manager
    for (final entity in chunkEntities) {
      interactionManager.addEntity(entity);
    }
    
    onEntitiesChanged?.call(chunkEntities);
  }
  
  /// Unload a specific chunk
  void _unloadChunk(Point<int> chunkCoord) {
    final chunkEntities = loadedChunks[chunkCoord];
    if (chunkEntities == null) return;
    
    // Remove from main entities list
    for (final entity in chunkEntities) {
      entities.remove(entity);
      interactionManager.removeEntity(entity);
    }
    
    loadedChunks.remove(chunkCoord);
    
    onEntitiesChanged?.call([]);
  }
  
  /// Generate entities for a chunk
  List<GardenEntity> _generateChunkEntities(Point<int> chunkCoord) {
    final entities = <GardenEntity>[];
    final rng = Random(chunkCoord.x * 1000 + chunkCoord.y);
    
    // Calculate chunk world position
    final chunkWorldX = chunkCoord.x * chunkSize;
    final chunkWorldY = chunkCoord.y * chunkSize;
    
    // Generate tiles
    final tileCount = 10; // 10x10 grid of tiles per chunk
    final tileSize = chunkSize / tileCount;
    
    for (int x = 0; x < tileCount; x++) {
      for (int y = 0; y < tileCount; y++) {
        final worldX = chunkWorldX + x * tileSize;
        final worldY = chunkWorldY + y * tileSize;
        
        // Determine tile type based on position and randomness
        TileType tileType;
        if (rng.nextDouble() < 0.1) {
          tileType = TileType.pond;
        } else if (rng.nextDouble() < 0.05) {
          tileType = TileType.path;
        } else if (rng.nextDouble() < 0.03) {
          tileType = TileType.fence;
        } else {
          tileType = TileType.soil;
        }
        
        final tileEntity = TileEntity(
          id: 'tile_${chunkCoord.x}_${chunkCoord.y}_$x-$y',
          worldPosition: Offset(worldX, worldY),
          bounds: Rect.fromLTWH(worldX, worldY, tileSize, tileSize),
          type: tileType,
          isPlantable: tileType == TileType.soil,
          isWalkable: tileType != TileType.fence,
          fertility: 0.3 + rng.nextDouble() * 0.4,
        );
        
        entities.add(tileEntity);
        
        // Add plants on soil tiles with some probability
        if (tileType == TileType.soil && rng.nextDouble() < 0.3) {
          final plantTypes = PlantType.values;
          final plantType = plantTypes[rng.nextInt(plantTypes.length)];
          
          final plantEntity = BasicPlantEntity(
            id: 'plant_${chunkCoord.x}_${chunkCoord.y}_$x-$y',
            worldPosition: Offset(worldX + tileSize / 2, worldY + tileSize / 2),
            bounds: Rect.fromCircle(
              center: Offset(worldX + tileSize / 2, worldY + tileSize / 2),
              radius: tileSize / 3,
            ),
            plantType: plantType,
            state: PlantState.values[rng.nextInt(PlantState.values.length - 1)], // Exclude dead
            hydration: 0.5 + rng.nextDouble() * 0.3,
            growthProgress: rng.nextDouble() * 100,
            health: 50 + rng.nextDouble() * 50,
            level: 1 + rng.nextInt(3),
            careQuality: 0.3 + rng.nextDouble() * 0.4,
          );
          
          entities.add(plantEntity);
        }
      }
    }
    
    // Add meditators with some probability
    if (rng.nextDouble() < 0.2) {
      final meditatorX = chunkWorldX + rng.nextDouble() * chunkSize;
      final meditatorY = chunkWorldY + rng.nextDouble() * chunkSize;
      
      final meditatorEntity = MeditatorEntity(
        id: 'meditator_${chunkCoord.x}_${chunkCoord.y}',
        worldPosition: Offset(meditatorX, meditatorY),
        bounds: Rect.fromCircle(
          center: Offset(meditatorX, meditatorY),
          radius: 20.0,
        ),
        state: MeditatorState.calm,
        breathPhase: rng.nextDouble() * pi * 2,
        breathFrequency: 0.3 + rng.nextDouble() * 0.4,
      );
      
      entities.add(meditatorEntity);
    }
    
    return entities;
  }
  
  /// Update loaded chunks based on camera position
  void _updateLoadedChunks(Size viewportSize) {
    final chunksToLoad = cameraController.getChunksToLoad(viewportSize);
    final currentChunks = Set<Point<int>>.from(loadedChunks.keys);
    
    // Load new chunks
    for (final chunk in chunksToLoad) {
      if (!currentChunks.contains(chunk)) {
        _loadChunk(chunk);
      }
    }
    
    // Unload distant chunks
    for (final chunk in currentChunks) {
      if (!chunksToLoad.contains(chunk)) {
        _unloadChunk(chunk);
      }
    }
  }
  
  /// Update the garden engine
  void update(Size viewportSize) {
    if (!isRunning) return;
    
    final now = DateTime.now();
    final deltaTime = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;
    
    // Accumulate frame time
    _frameTimeAccumulator += deltaTime;
    
    // Update at target frame rate
    while (_frameTimeAccumulator >= targetFrameTime) {
      _frameTimeAccumulator -= targetFrameTime;
      
      // Update camera inertia
      cameraController.updateInertia();
      
      // Update weather
      weatherEngine.update(targetFrameTime);
      
      // Update all entities
      interactionManager.update(targetFrameTime);
      
      // Update loaded chunks based on camera
      _updateLoadedChunks(viewportSize);
      
      // Check for camera changes
      if (onCameraChanged != null) {
        onCameraChanged!(cameraController.position, cameraController.zoom);
      }
      
      // Check for economy changes
      // if (onEconomyChanged != null) {
      //   onEconomyChanged!(economySystem.getStats());
      // }
    }
  }
  
  /// Apply weather effects to entities
  void _applyWeatherEffects() {
    final growthMultiplier = weatherEngine.getGrowthMultiplier();
    final waterContribution = weatherEngine.getWaterContribution();
    final healthEffect = weatherEngine.getHealthEffect();
    
    for (final entity in entities) {
      if (entity is PlantEntity) {
        // Apply weather effects to plants
        entity.updateGrowth(targetFrameTime / 3600, growthMultiplier); // Convert to hours
        if (waterContribution > 0) {
          entity.water(waterContribution);
        }
        entity.health = (entity.health + healthEffect).clamp(0.0, 100.0);
      }
    }
  }
  
  /// Apply time of day effects
  void _applyTimeOfDayEffects() {
    final daylightIntensity = weatherEngine.daylightIntensity;
    
    // Adjust plant growth based on daylight
    final growthMultiplier = weatherEngine.isDayTime ? 1.2 : 0.8;
    
    for (final entity in entities) {
      if (entity is PlantEntity) {
        entity.updateGrowth(targetFrameTime / 3600, growthMultiplier);
      }
    }
  }
  
  /// Handle pointer down event
  void onPointerDown(PointerDownEvent event) {
    interactionManager.onPointerDown(event);
    cameraController.startPan(event.localPosition);
  }
  
  /// Handle pointer move event
  void onPointerMove(PointerMoveEvent event, Size viewportSize) {
    interactionManager.onPointerMove(event, viewportSize, cameraController.position);
    cameraController.updatePan(event.localPosition);
  }
  
  /// Handle pointer up event
  void onPointerUp(PointerUpEvent event, Size viewportSize) {
    interactionManager.onPointerUp(event, viewportSize, cameraController.position);
    cameraController.endPan();
  }
  
  /// Handle scale start (for zoom)
  void onScaleStart(ScaleStartDetails details) {
    cameraController.startZoom(1.0, details.focalPoint);
  }
  
  /// Handle scale update (for zoom)
  void onScaleUpdate(ScaleUpdateDetails details, Size viewportSize) {
    cameraController.updateZoom(details.scale, details.focalPoint);
  }
  
  /// Handle scale end (for zoom)
  void onScaleEnd(ScaleEndDetails details) {
    cameraController.endZoom();
  }
  
  /// Render the garden
  void render(Canvas canvas, Size viewportSize) {
    // Sort entities by z-index for proper rendering
    final sortedEntities = List<GardenEntity>.from(entities)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    
    // Apply camera transform
    canvas.save();
    canvas.translate(-cameraController.position.dx, -cameraController.position.dy);
    canvas.scale(cameraController.zoom);
    
    // Render all entities
    for (final entity in sortedEntities) {
      if (entity.isVisible) {
        // Check if entity is in viewport
        final screenPos = entity.getScreenPosition(viewportSize, cameraController.position);
        final bounds = Rect.fromPoints(
          screenPos,
          screenPos + Offset(entity.bounds.width, entity.bounds.height),
        );
        
        final viewportRect = Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height);
        
        if (bounds.overlaps(viewportRect)) {
          entity.render(canvas, viewportSize, cameraController.position);
        }
      }
    }
    
    canvas.restore();
  }
  
  /// Add an entity to the garden
  void addEntity(GardenEntity entity) {
    entities.add(entity);
    interactionManager.addEntity(entity);
    onEntitiesChanged?.call([entity]);
  }
  
  /// Remove an entity from the garden
  void removeEntity(GardenEntity entity) {
    entities.remove(entity);
    interactionManager.removeEntity(entity);
    onEntitiesChanged?.call([]);
  }
  
  /// Get entity by ID
  GardenEntity? getEntityById(String id) {
    for (final entity in entities) {
      if (entity.id == id) {
        return entity;
      }
    }
    return null;
  }
  
  /// Get all entities of a specific type
  List<T> getEntitiesByType<T extends GardenEntity>() {
    return entities.whereType<T>().toList();
  }
  
  /// Reset the garden to initial state
  Future<void> reset() async {
    // Clear all entities
    entities.clear();
    loadedChunks.clear();
    interactionManager.entities.clear();
    interactionManager.rebuildSpatialGrid();
    
    // Reset camera
    cameraController.reset();
    
    // Reset weather
    weatherEngine.setWeatherState(WeatherState.spring);
    
    // Reset economy
    // await economySystem.reset();
    
    // Load initial chunks
    _loadInitialChunks();
    
    onEntitiesChanged?.call([]);
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    isRunning = false;
    // await economySystem.dispose();
  }
  
  /// Get engine stats for debugging
  Map<String, dynamic> getStats() {
    return {
      'entities_total': entities.length,
      'chunks_loaded': loadedChunks.length,
      'camera_position': {
        'x': cameraController.position.dx,
        'y': cameraController.position.dy,
        'zoom': cameraController.zoom,
      },
      'weather_state': weatherEngine.currentState.toString(),
      // 'economy': economySystem.getStats(),
      'performance': {
        'frame_time': targetFrameTime,
        'entities_rendered': entities.where((e) => e.isVisible).length,
      },
    };
  }
}

/// Plant types (extended from original)
enum PlantType {
  flower,
  tree,
  bush,
  herb,
  mushroom,
  cactus,
  bamboo,
  lotus,      // Rare water plant
  sunflower,  // Sun-loving
  lavender,   // Aromatic
  sage,       // Medicinal
  bonsai,     // Artistic
}