import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DayNightCycle extends Component with HasGameRef {
  double timeOfDay = 0.5; // 0.0 = midnight, 0.5 = noon, 1.0 = midnight
  double cycleSpeed = 0.01; // How fast the day/night cycle progresses
  bool isPaused = false;

  // Colors for different times of day
  static const Color _midnightColor = Color(0xFF0A1929);
  static const Color _dawnColor = Color(0xFF1A237E);
  static const Color _noonColor = Color(0xFF4FC3F7);
  static const Color _duskColor = Color(0xFFE91E63);
  static const Color _nightColor = Color(0xFF1A237E);

  late RectangleComponent _overlay;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create overlay for lighting effects
    _overlay = RectangleComponent(
      size: gameRef.size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.transparent,
    );
    add(_overlay);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPaused) {
      timeOfDay += cycleSpeed * dt;
      if (timeOfDay >= 1.0) {
        timeOfDay = 0.0;
      }
    }
    
    _updateLighting();
  }

  void setTimeOfDay(double time) {
    timeOfDay = time.clamp(0.0, 1.0);
    _updateLighting();
  }

  void _updateLighting() {
    final color = _getCurrentSkyColor();
    _overlay.paint = Paint()..color = color.withOpacity(0.3);
  }

  Color _getCurrentSkyColor() {
    if (timeOfDay < 0.25) {
      // Night to dawn
      return _interpolateColor(_midnightColor, _dawnColor, timeOfDay / 0.25);
    } else if (timeOfDay < 0.5) {
      // Dawn to noon
      return _interpolateColor(_dawnColor, _noonColor, (timeOfDay - 0.25) / 0.25);
    } else if (timeOfDay < 0.75) {
      // Noon to dusk
      return _interpolateColor(_noonColor, _duskColor, (timeOfDay - 0.5) / 0.25);
    } else {
      // Dusk to night
      return _interpolateColor(_duskColor, _nightColor, (timeOfDay - 0.75) / 0.25);
    }
  }

  Color _interpolateColor(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t)!;
  }

  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
  }

  void setCycleSpeed(double speed) {
    cycleSpeed = speed.clamp(0.0, 0.1);
  }

  String getTimeDescription() {
    if (timeOfDay < 0.25) return 'Night';
    if (timeOfDay < 0.375) return 'Dawn';
    if (timeOfDay < 0.625) return 'Day';
    if (timeOfDay < 0.75) return 'Dusk';
    return 'Night';
  }

  double getHour() {
    return (timeOfDay * 24).clamp(0.0, 24.0);
  }

  bool isNight() {
    return timeOfDay < 0.25 || timeOfDay > 0.75;
  }

  bool isDay() {
    return timeOfDay >= 0.375 && timeOfDay <= 0.625;
  }
}
