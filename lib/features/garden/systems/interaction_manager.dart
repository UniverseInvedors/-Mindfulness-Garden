import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/garden_entity.dart';

/// Manages all pointer interactions in the garden
class InteractionManager {
  /// All entities in the garden
  final List<GardenEntity> entities;
  
  /// Spatial partitioning grid for efficient hit detection
  final Map<Point<int>, List<GardenEntity>> spatialGrid;
  
  /// Grid cell size (world units)
  final double gridCellSize;
  
  /// Tap threshold in pixels
  static const double tapThreshold = 8.0;
  
  /// Tap time threshold in milliseconds
  static const int tapTimeThreshold = 250;
  
  /// Long press threshold in milliseconds
  static const int longPressThreshold = 500;
  
  /// Double tap threshold in milliseconds
  static const int doubleTapThreshold = 300;
  
  /// Current pointer state
  Offset? _pointerDownPosition;
  DateTime? _pointerDownTime;
  bool _isPanning = false;
  GardenEntity? _draggedEntity;
  
  /// Last tap time for double tap detection
  DateTime? _lastTapTime;
  GardenEntity? _lastTappedEntity;
  
  InteractionManager({
    required this.entities,
    this.gridCellSize = 100.0,
  }) : spatialGrid = {} {
    _buildSpatialGrid();
  }
  
  /// Build spatial grid for efficient hit detection
  void _buildSpatialGrid() {
    spatialGrid.clear();
    
    for (final entity in entities) {
      if (!entity.isVisible || !entity.isInteractive) continue;
      
      // Calculate grid cells that the entity occupies
      final minX = (entity.bounds.left / gridCellSize).floor();
      final maxX = (entity.bounds.right / gridCellSize).ceil();
      final minY = (entity.bounds.top / gridCellSize).floor();
      final maxY = (entity.bounds.bottom / gridCellSize).ceil();
      
      for (int x = minX; x < maxX; x++) {
        for (int y = minY; y < maxY; y++) {
          final cell = Point<int>(x, y);
          spatialGrid.putIfAbsent(cell, () => []).add(entity);
        }
      }
    }
  }
  
  /// Handle pointer down event
  void onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.localPosition;
    _pointerDownTime = DateTime.now();
    _isPanning = false;
    _draggedEntity = null;
  }
  
  /// Handle pointer move event
  void onPointerMove(PointerMoveEvent event, Size viewportSize, Offset cameraOffset) {
    if (_pointerDownPosition == null) return;
    
    // Calculate movement distance
    final movement = (event.localPosition - _pointerDownPosition!).distance;
    
    // Check if movement exceeds tap threshold
    if (!_isPanning && movement > tapThreshold) {
      _isPanning = true;
      
      // Find entity at pointer down position for dragging
      _draggedEntity = _findEntityAt(_pointerDownPosition!, viewportSize, cameraOffset);
    }
    
    // Handle panning/dragging
    if (_isPanning) {
      if (_draggedEntity != null) {
        // Drag the entity
        final delta = event.delta;
        _draggedEntity!.onDrag(delta);
      } else {
        // Camera pan (handled by camera controller)
        // This would update camera offset
      }
    }
  }
  
  /// Handle pointer up event
  void onPointerUp(PointerUpEvent event, Size viewportSize, Offset cameraOffset) {
    if (_pointerDownPosition == null || _pointerDownTime == null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(_pointerDownTime!).inMilliseconds;
    final movement = (event.localPosition - _pointerDownPosition!).distance;
    
    // Check for tap vs pan
    if (!_isPanning && movement <= tapThreshold && elapsed <= tapTimeThreshold) {
      // This is a tap
      _handleTap(event.localPosition, viewportSize, cameraOffset, elapsed);
    } else if (!_isPanning && elapsed >= longPressThreshold) {
      // This is a long press
      _handleLongPress(event.localPosition, viewportSize, cameraOffset);
    }
    
    // Reset pointer state
    _pointerDownPosition = null;
    _pointerDownTime = null;
    _isPanning = false;
    _draggedEntity = null;
  }
  
  /// Handle tap event
  void _handleTap(Offset position, Size viewportSize, Offset cameraOffset, int elapsedMs) {
    final entity = _findEntityAt(position, viewportSize, cameraOffset);
    
    if (entity != null) {
      // Check for double tap
      final now = DateTime.now();
      if (_lastTapTime != null && 
          _lastTappedEntity == entity &&
          now.difference(_lastTapTime!).inMilliseconds <= doubleTapThreshold) {
        // Double tap detected
        _handleDoubleTap(entity);
        _lastTapTime = null;
        _lastTappedEntity = null;
      } else {
        // Single tap
        entity.onTap();
        _lastTapTime = now;
        _lastTappedEntity = entity;
      }
    }
  }
  
  /// Handle long press event
  void _handleLongPress(Offset position, Size viewportSize, Offset cameraOffset) {
    final entity = _findEntityAt(position, viewportSize, cameraOffset);
    if (entity != null) {
      entity.onLongPress();
    }
  }
  
  /// Handle double tap event
  void _handleDoubleTap(GardenEntity entity) {
    // Double tap could have special meaning depending on entity type
    // For example: quick water nearby plants, special action, etc.
    if (entity is PlantEntity) {
      // Quick water action
      entity.water(0.3);
    }
  }
  
  /// Find entity at a given screen position
  GardenEntity? _findEntityAt(Offset screenPosition, Size viewportSize, Offset cameraOffset) {
    // Convert screen position to world coordinates
    final worldPosition = screenPosition + cameraOffset;
    
    // Calculate grid cell
    final cellX = (worldPosition.dx / gridCellSize).floor();
    final cellY = (worldPosition.dy / gridCellSize).floor();
    final cell = Point<int>(cellX, cellY);
    
    // Check entities in this cell and neighboring cells
    final candidates = <GardenEntity>[];
    
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final neighborCell = Point<int>(cellX + dx, cellY + dy);
        final entitiesInCell = spatialGrid[neighborCell];
        if (entitiesInCell != null) {
          candidates.addAll(entitiesInCell);
        }
      }
    }
    
    // Sort by z-index (higher z-index = on top)
    candidates.sort((a, b) => b.zIndex.compareTo(a.zIndex));
    
    // Find first entity that passes hit test
    for (final entity in candidates) {
      if (entity.isVisible && 
          entity.isInteractive && 
          entity.hitTest(screenPosition, viewportSize, cameraOffset)) {
        return entity;
      }
    }
    
    return null;
  }
  
  /// Update all entities
  void update(double deltaTime) {
    for (final entity in entities) {
      if (entity.isVisible) {
        entity.update(deltaTime);
      }
    }
  }
  
  /// Render all entities (sorted by z-index)
  void render(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    // Sort entities by z-index for proper rendering order
    final sortedEntities = List<GardenEntity>.from(entities)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    
    for (final entity in sortedEntities) {
      if (entity.isVisible) {
        entity.render(canvas, viewportSize, cameraOffset);
      }
    }
  }
  
  /// Add an entity to the manager
  void addEntity(GardenEntity entity) {
    entities.add(entity);
    _addEntityToGrid(entity);
  }
  
  /// Remove an entity from the manager
  void removeEntity(GardenEntity entity) {
    entities.remove(entity);
    _removeEntityFromGrid(entity);
  }
  
  /// Add entity to spatial grid
  void _addEntityToGrid(GardenEntity entity) {
    if (!entity.isVisible || !entity.isInteractive) return;
    
    final minX = (entity.bounds.left / gridCellSize).floor();
    final maxX = (entity.bounds.right / gridCellSize).ceil();
    final minY = (entity.bounds.top / gridCellSize).floor();
    final maxY = (entity.bounds.bottom / gridCellSize).ceil();
    
    for (int x = minX; x < maxX; x++) {
      for (int y = minY; y < maxY; y++) {
        final cell = Point<int>(x, y);
        spatialGrid.putIfAbsent(cell, () => []).add(entity);
      }
    }
  }
  
  /// Remove entity from spatial grid
  void _removeEntityFromGrid(GardenEntity entity) {
    spatialGrid.forEach((cell, entitiesInCell) {
      entitiesInCell.remove(entity);
    });
    
    // Remove empty cells
    spatialGrid.removeWhere((cell, entitiesInCell) => entitiesInCell.isEmpty);
  }
  
  /// Rebuild spatial grid (call when many entities change)
  void rebuildSpatialGrid() {
    _buildSpatialGrid();
  }
}
