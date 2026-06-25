import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/garden_chunk.dart';
import 'components/camera_component.dart';
import 'components/plant_component.dart';
import 'components/decoration_component.dart';
import 'components/npc_component.dart';
import 'components/weather_system.dart';
import 'components/day_night_cycle.dart';

class GardenWorld extends World with PanDetector, TapDetector {
  late CameraComponent camera;
  late WeatherSystem weatherSystem;
  late DayNightCycle dayNightCycle;
  
  final Map<String, GardenChunk> _chunks = {};
  final List<PlantComponent> _plants = [];
  final List<DecorationComponent> _decorations = [];
  final List<NPCComponent> _npcs = [];
  
  Vector2 _cameraPosition = Vector2.zero();
  double _zoom = 1.0;
  bool _isPanning = false;
  Vector2 _panStart = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize camera
    camera = CameraComponent.withWorld(world: this);
    add(camera);
    
    // Initialize weather system
    weatherSystem = WeatherSystem();
    add(weatherSystem);
    
    // Initialize day/night cycle
    dayNightCycle = DayNightCycle();
    add(dayNightCycle);
    
    // Load initial chunks
    await _loadInitialChunks();
    
    // Add initial plants and decorations
    await _addInitialContent();
  }

  Future<void> initialize() async {
    // Additional initialization if needed
  }

  Future<void> _loadInitialChunks() async {
    // Load center chunk
    await _loadChunk(0, 0);
    
    // Load surrounding chunks
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        if (x != 0 || y != 0) {
          await _loadChunk(x, y);
        }
      }
    }
  }

  Future<void> _loadChunk(int chunkX, int chunkY) async {
    final chunkKey = '${chunkX}_$chunkY';
    
    if (_chunks.containsKey(chunkKey)) return;
    
    final chunk = GardenChunk(
      chunkX: chunkX,
      chunkY: chunkY,
    );
    
    await chunk.onLoad();
    _chunks[chunkKey] = chunk;
    add(chunk);
  }

  Future<void> _addInitialContent() async {
    // Add some initial plants
    for (int i = 0; i < 10; i++) {
      final plant = PlantComponent(
        position: Vector2(
          (i * 100 - 500).toDouble(),
          (i * 80 - 400).toDouble(),
        ),
        plantType: PlantType.values[i % PlantType.values.length],
      );
      await plant.onLoad();
      _plants.add(plant);
      add(plant);
    }
    
    // Add some decorations
    for (int i = 0; i < 5; i++) {
      final decoration = DecorationComponent(
        position: Vector2(
          (i * 150 - 300).toDouble(),
          (i * 120 - 200).toDouble(),
        ),
        decorationType: DecorationType.values[i % DecorationType.values.length],
      );
      await decoration.onLoad();
      _decorations.add(decoration);
      add(decoration);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    _isPanning = true;
    _panStart = info.eventPosition.global;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_isPanning) return;
    
    final delta = info.eventPosition.global - _panStart;
    _cameraPosition -= delta * 0.5;
    camera.position = _cameraPosition;
    _panStart = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _isPanning = false;
  }

  @override
  void onTapDown(TapDownInfo info) {
    final worldPosition = camera.screenToWorld(info.eventPosition.global);
    _handleInteraction(worldPosition);
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    // Zoom in on double tap
    _zoom = (_zoom * 1.2).clamp(0.5, 3.0);
    camera.zoom = _zoom;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    const moveSpeed = 10.0;
    
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        _cameraPosition.y += moveSpeed;
        camera.position = _cameraPosition;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        _cameraPosition.y -= moveSpeed;
        camera.position = _cameraPosition;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        _cameraPosition.x -= moveSpeed;
        camera.position = _cameraPosition;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        _cameraPosition.x += moveSpeed;
        camera.position = _cameraPosition;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.equal) ||
          keysPressed.contains(LogicalKeyboardKey.plus)) {
        _zoom = (_zoom * 1.1).clamp(0.5, 3.0);
        camera.zoom = _zoom;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.minus)) {
        _zoom = (_zoom * 0.9).clamp(0.5, 3.0);
        camera.zoom = _zoom;
        return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }

  void _handleInteraction(Vector2 worldPosition) {
    // Check if a plant was tapped
    for (final plant in _plants) {
      if (plant.containsPoint(worldPosition)) {
        plant.onTap();
        return;
      }
    }
    
    // Check if a decoration was tapped
    for (final decoration in _decorations) {
      if (decoration.containsPoint(worldPosition)) {
        decoration.onTap();
        return;
      }
    }
    
    // Check if an NPC was tapped
    for (final npc in _npcs) {
      if (npc.containsPoint(worldPosition)) {
        npc.onTap();
        return;
      }
    }
  }

  void setWeather(WeatherType weather) {
    weatherSystem.setWeather(weather);
  }

  void setTimeOfDay(double timeOfDay) {
    dayNightCycle.setTimeOfDay(timeOfDay);
  }

  void addPlant(Vector2 position, PlantType type) async {
    final plant = PlantComponent(position: position, plantType: type);
    await plant.onLoad();
    _plants.add(plant);
    add(plant);
  }

  void addDecoration(Vector2 position, DecorationType type) async {
    final decoration = DecorationComponent(position: position, decorationType: type);
    await decoration.onLoad();
    _decorations.add(decoration);
    add(decoration);
  }

  void addNPC(Vector2 position, NPCType type) async {
    final npc = NPCComponent(position: position, npcType: type);
    await npc.onLoad();
    _npcs.add(npc);
    add(npc);
  }
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy,
}

enum PlantType {
  flower,
  tree,
  bush,
  grass,
  fern,
  bamboo,
  lotus,
  cherryBlossom,
}

enum DecorationType {
  rock,
  path,
  bridge,
  fountain,
  lantern,
  bench,
  statue,
  waterfall,
}

enum NPCType {
  gardener,
  butterfly,
  bird,
  rabbit,
  turtle,
}
