import 'dart:math';
import 'package:flutter/material.dart';

/// Camera controller for infinite scrollable garden
class CameraController {
  /// Current camera position (world coordinates)
  Offset position;
  
  /// Current zoom level (0.5 = 50%, 3.0 = 300%)
  double zoom;
  
  /// Minimum zoom level
  final double minZoom;
  
  /// Maximum zoom level
  final double maxZoom;
  
  /// Camera velocity for inertia
  Offset velocity;
  
  /// Velocity decay factor per frame
  final double velocityDecay;
  
  /// Whether camera is currently being panned
  bool isPanning;
  
  /// Whether camera is currently being zoomed
  bool isZooming;
  
  /// Last pointer position for panning
  Offset? _lastPanPosition;
  
  /// Last scale for zooming
  double? _lastScale;
  
  /// World bounds (optional, for constrained camera)
  Rect? worldBounds;
  
  /// Chunk size for infinite world
  final double chunkSize;
  
  /// Loaded chunks
  final Set<Point<int>> loadedChunks;
  
  CameraController({
    this.position = Offset.zero,
    this.zoom = 1.0,
    this.minZoom = 0.5,
    this.maxZoom = 3.0,
    this.velocity = Offset.zero,
    this.velocityDecay = 0.92,
    this.isPanning = false,
    this.isZooming = false,
    this.worldBounds,
    this.chunkSize = 1000.0,
  }) : loadedChunks = {};
  
  /// Start panning
  void startPan(Offset screenPosition) {
    isPanning = true;
    _lastPanPosition = screenPosition;
    velocity = Offset.zero;
  }
  
  /// Update panning
  void updatePan(Offset screenPosition) {
    if (!isPanning || _lastPanPosition == null) return;
    
    // Calculate delta in screen space
    final delta = screenPosition - _lastPanPosition!;
    
    // Convert to world space (inverse of zoom)
    final worldDelta = delta / zoom;
    
    // Update position
    position -= worldDelta;
    
    // Constrain to world bounds if specified
    if (worldBounds != null) {
      position = Offset(
        position.dx.clamp(worldBounds!.left, worldBounds!.right),
        position.dy.clamp(worldBounds!.top, worldBounds!.bottom),
      );
    }
    
    // Update velocity for inertia
    velocity = -worldDelta;
    
    _lastPanPosition = screenPosition;
    
    // Update loaded chunks based on viewport
    _updateLoadedChunks();
  }
  
  /// End panning
  void endPan() {
    isPanning = false;
    _lastPanPosition = null;
  }
  
  /// Start zooming
  void startZoom(double scale, Offset focalPoint) {
    isZooming = true;
    _lastScale = scale;
  }
  
  /// Update zooming (pinch gesture)
  void updateZoom(double scale, Offset focalPoint) {
    if (!isZooming || _lastScale == null) return;
    
    // Calculate scale delta
    final scaleDelta = scale / _lastScale!;
    
    // Update zoom with clamping
    final newZoom = (zoom * scaleDelta).clamp(minZoom, maxZoom);
    
    // Calculate focal point in world coordinates
    final focalWorld = position + focalPoint / zoom;
    
    // Update zoom
    zoom = newZoom;
    
    // Adjust position to keep focal point stable
    position = focalWorld - focalPoint / zoom;
    
    _lastScale = scale;
    
    // Update loaded chunks based on new zoom
    _updateLoadedChunks();
  }
  
  /// End zooming
  void endZoom() {
    isZooming = false;
    _lastScale = null;
  }
  
  /// Update camera inertia
  void updateInertia() {
    if (isPanning || isZooming) return;
    
    // Apply velocity decay
    velocity *= velocityDecay;
    
    // Update position
    position += velocity;
    
    // Constrain to world bounds if specified
    if (worldBounds != null) {
      position = Offset(
        position.dx.clamp(worldBounds!.left, worldBounds!.right),
        position.dy.clamp(worldBounds!.top, worldBounds!.bottom),
      );
      
      // Stop velocity if at bounds
      if (position.dx == worldBounds!.left || position.dx == worldBounds!.right) {
        velocity = Offset(0, velocity.dy);
      }
      if (position.dy == worldBounds!.top || position.dy == worldBounds!.bottom) {
        velocity = Offset(velocity.dx, 0);
      }
    }
    
    // Stop if velocity is very small
    if (velocity.distance < 0.1) {
      velocity = Offset.zero;
    }
    
    // Update loaded chunks
    _updateLoadedChunks();
  }
  
  /// Convert screen coordinates to world coordinates
  Offset screenToWorld(Offset screenPoint) {
    return position + screenPoint / zoom;
  }
  
  /// Convert world coordinates to screen coordinates
  Offset worldToScreen(Offset worldPoint) {
    return (worldPoint - position) * zoom;
  }
  
  /// Get visible world bounds based on viewport
  Rect getVisibleWorldBounds(Size viewportSize) {
    final topLeft = screenToWorld(Offset.zero);
    final bottomRight = screenToWorld(Offset(viewportSize.width, viewportSize.height));
    
    return Rect.fromPoints(topLeft, bottomRight);
  }
  
  /// Update loaded chunks based on current viewport
  void _updateLoadedChunks() {
    // This would calculate which chunks are visible
    // and load/unload them as needed
    // For now, just a placeholder implementation
  }
  
  /// Get chunks that should be loaded based on viewport
  Set<Point<int>> getChunksToLoad(Size viewportSize) {
    final visibleBounds = getVisibleWorldBounds(viewportSize);
    final chunks = <Point<int>>{};
    
    // Calculate chunk coordinates for visible area
    final minChunkX = (visibleBounds.left / chunkSize).floor();
    final maxChunkX = (visibleBounds.right / chunkSize).ceil();
    final minChunkY = (visibleBounds.top / chunkSize).floor();
    final maxChunkY = (visibleBounds.bottom / chunkSize).ceil();
    
    for (int x = minChunkX; x <= maxChunkX; x++) {
      for (int y = minChunkY; y <= maxChunkY; y++) {
        chunks.add(Point<int>(x, y));
      }
    }
    
    return chunks;
  }
  
  /// Reset camera to default position
  void reset() {
    position = Offset.zero;
    zoom = 1.0;
    velocity = Offset.zero;
    loadedChunks.clear();
  }
  
  /// Smoothly move camera to target position
  void moveTo(Offset targetPosition, {double targetZoom = 1.0, Duration duration = const Duration(milliseconds: 500)}) {
    // This would implement smooth camera movement
    // For now, just set directly
    position = targetPosition;
    zoom = targetZoom.clamp(minZoom, maxZoom);
  }
  
  /// Check if a world point is visible in the viewport
  bool isPointVisible(Offset worldPoint, Size viewportSize) {
    final screenPoint = worldToScreen(worldPoint);
    return screenPoint.dx >= 0 && 
           screenPoint.dx <= viewportSize.width &&
           screenPoint.dy >= 0 && 
           screenPoint.dy <= viewportSize.height;
  }
  
  /// Get the scale factor for rendering at current zoom
  double get renderScale => zoom;
  
  /// Get the inverse scale factor (for hit detection)
  double get inverseScale => 1.0 / zoom;
}
