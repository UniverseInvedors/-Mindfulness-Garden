import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../garden_world.dart';

class WeatherSystem extends Component with HasGameRef {
  WeatherType currentWeather = WeatherType.sunny;
  final List<WeatherParticle> _particles = [];
  double _weatherIntensity = 0.5;

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update weather particles
    for (final particle in _particles) {
      particle.update(dt);
    }
    
    // Remove dead particles
    _particles.removeWhere((p) => p.isDead);
    
    // Spawn new particles based on weather
    _spawnParticles(dt);
  }

  void setWeather(WeatherType weather) {
    currentWeather = weather;
    _particles.clear();
    
    switch (weather) {
      case WeatherType.sunny:
        _weatherIntensity = 0.0;
        break;
      case WeatherType.cloudy:
        _weatherIntensity = 0.3;
        break;
      case WeatherType.rainy:
        _weatherIntensity = 0.7;
        break;
      case WeatherType.snowy:
        _weatherIntensity = 0.6;
        break;
      case WeatherType.stormy:
        _weatherIntensity = 1.0;
        break;
    }
  }

  void _spawnParticles(double dt) {
    if (currentWeather == WeatherType.sunny) return;
    
    final spawnRate = _weatherIntensity * 10;
    final particlesToSpawn = (spawnRate * dt).toInt();
    
    for (int i = 0; i < particlesToSpawn; i++) {
      final particle = _createParticle();
      if (particle != null) {
        _particles.add(particle);
        add(particle);
      }
    }
  }

  WeatherParticle? _createParticle() {
    final screenBounds = gameRef.size;
    final x = (screenBounds.x * (0.2 + 0.6 * (DateTime.now().millisecondsSinceEpoch % 100) / 100));
    final y = -20.0;
    
    switch (currentWeather) {
      case WeatherType.cloudy:
        return CloudParticle(position: Vector2(x, y));
      case WeatherType.rainy:
        return RainParticle(position: Vector2(x, y));
      case WeatherType.snowy:
        return SnowParticle(position: Vector2(x, y));
      case WeatherType.stormy:
        return StormParticle(position: Vector2(x, y));
      default:
        return null;
    }
  }
}

abstract class WeatherParticle extends PositionComponent {
  bool isDead = false;
  double lifetime = 10.0;
  double age = 0.0;

  WeatherParticle({required Vector2 position}) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    age += dt;
    if (age >= lifetime) {
      isDead = true;
      removeFromParent();
    }
  }
}

class CloudParticle extends WeatherParticle {
  CloudParticle({required super.position}) {
    size = Vector2.all(40.0);
    lifetime = 15.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final cloud = CircleComponent(
      radius: 20.0,
      position: Vector2(20.0, 20.0),
      paint: paint,
    );
    add(cloud);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(20.0 * dt, 5.0 * dt);
  }
}

class RainParticle extends WeatherParticle {
  RainParticle({required super.position}) {
    size = Vector2(2.0, 15.0);
    lifetime = 5.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final rain = RectangleComponent(
      size: size,
      position: Vector2.zero,
      paint: paint,
    );
    add(rain);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(-10.0 * dt, 200.0 * dt);
  }
}

class SnowParticle extends WeatherParticle {
  SnowParticle({required super.position}) {
    size = Vector2.all(6.0);
    lifetime = 10.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final snow = CircleComponent(
      radius: 3.0,
      position: Vector2(3.0, 3.0),
      paint: paint,
    );
    add(snow);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final sway = (age * 2).sin() * 20.0 * dt;
    position += Vector2(sway, 50.0 * dt);
  }
}

class StormParticle extends WeatherParticle {
  StormParticle({required super.position}) {
    size = Vector2(3.0, 20.0);
    lifetime = 3.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final paint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final rain = RectangleComponent(
      size: size,
      position: Vector2.zero,
      paint: paint,
    );
    add(rain);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(-50.0 * dt, 300.0 * dt);
  }
}
