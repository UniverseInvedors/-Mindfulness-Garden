import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'garden_world.dart';

class GardenGame extends FlameGame with PanDetector, TapDetector {
  GardenGame({
    required this.onGardenInteract,
    this.onWeatherChanged,
    this.onTimeChanged,
  });

  final Function(String) onGardenInteract;
  final void Function(WeatherType weather)? onWeatherChanged;
  final void Function(String timeLabel)? onTimeChanged;
  late GardenWorld gardenWorld;

  @override
  Color backgroundColor() => const Color(0xFF06141B);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    gardenWorld = GardenWorld(
      onWeatherChanged: onWeatherChanged,
      onTimeChanged: onTimeChanged,
    );
    add(gardenWorld);
    
    await gardenWorld.initialize();
  }

  @override
  void onPanStart(DragStartInfo info) {
    gardenWorld.onPanStart(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    gardenWorld.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    gardenWorld.onPanEnd(info);
  }

  @override
  void onTapDown(TapDownInfo info) {
    gardenWorld.onTapDown(info);
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    gardenWorld.onDoubleTapDown(info);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return gardenWorld.onKeyEvent(event, keysPressed);
  }
}
