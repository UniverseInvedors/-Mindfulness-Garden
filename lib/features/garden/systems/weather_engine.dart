import 'dart:math';
import 'package:flutter/material.dart';

/// Weather states with gameplay effects
enum WeatherState {
  spring,    // Gentle growth, occasional rain
  summer,    // Fast growth, high dehydration risk
  monsoon,   // Heavy rain, auto-watering, +60% growth
  autumn,    // Leaves fall, growth slows, harvest season
  winter,    // Freeze growth, health decay, mushrooms thrive
}

/// Weather engine that controls seasonal transitions and effects
class WeatherEngine {
  /// Current weather state
  WeatherState currentState;
  
  /// Current wind strength (0.0 - 1.0)
  double windStrength;
  
  /// Wind direction in radians
  double windDirection;
  
  /// Time of day (0.0 = midnight, 1.0 = next midnight)
  double timeOfDay;
  
  /// Day duration in seconds (e.g., 600 = 10 minutes)
  double dayDuration;
  
  /// Current season duration in seconds
  double seasonDuration;
  
  /// Time elapsed in current season
  double seasonElapsed;
  
  /// Whether it's currently raining
  bool isRaining;
  
  /// Whether it's currently snowing
  bool isSnowing;
  
  /// Rain intensity (0.0 - 1.0)
  double rainIntensity;
  
  /// Temperature (0.0 = freezing, 1.0 = hot)
  double temperature;
  
  /// Humidity (0.0 - 1.0)
  double humidity;
  
  /// Random number generator
  final Random _rng;
  
  /// Callback for weather state changes
  final void Function(WeatherState newState)? onWeatherChanged;
  
  /// Callback for time of day changes
  final void Function(double timeOfDay)? onTimeChanged;
  
  WeatherEngine({
    this.currentState = WeatherState.spring,
    this.windStrength = 0.5,
    this.windDirection = 0.0,
    this.timeOfDay = 0.25, // Start at morning
    this.dayDuration = 600.0, // 10 minutes
    this.seasonDuration = 300.0, // 5 minutes per season for testing
    this.seasonElapsed = 0.0,
    this.isRaining = false,
    this.isSnowing = false,
    this.rainIntensity = 0.0,
    this.temperature = 0.5,
    this.humidity = 0.5,
    this.onWeatherChanged,
    this.onTimeChanged,
  }) : _rng = Random();
  
  /// Update weather system
  void update(double deltaTime) {
    // Update time of day
    timeOfDay = (timeOfDay + deltaTime / dayDuration) % 1.0;
    onTimeChanged?.call(timeOfDay);
    
    // Update season progression
    seasonElapsed += deltaTime;
    if (seasonElapsed >= seasonDuration) {
      _transitionToNextSeason();
    }
    
    // Update weather effects based on current state
    _updateWeatherEffects(deltaTime);
    
    // Update wind (sinusoidal variation)
    _updateWind(deltaTime);
    
    // Update precipitation
    _updatePrecipitation(deltaTime);
  }
  
  /// Transition to next season
  void _transitionToNextSeason() {
    final nextState = WeatherState.values[(currentState.index + 1) % WeatherState.values.length];
    _setWeatherState(nextState);
    seasonElapsed = 0.0;
  }
  
  /// Set weather state with transition effects
  void _setWeatherState(WeatherState newState) {
    if (currentState == newState) return;
    
    final oldState = currentState;
    currentState = newState;
    
    // Apply state-specific initial conditions
    switch (newState) {
      case WeatherState.spring:
        temperature = 0.6;
        humidity = 0.7;
        windStrength = 0.4;
        isRaining = _rng.nextDouble() < 0.3;
        isSnowing = false;
        break;
      case WeatherState.summer:
        temperature = 0.9;
        humidity = 0.4;
        windStrength = 0.2;
        isRaining = false;
        isSnowing = false;
        break;
      case WeatherState.monsoon:
        temperature = 0.7;
        humidity = 0.95;
        windStrength = 0.8;
        isRaining = true;
        rainIntensity = 0.8;
        isSnowing = false;
        break;
      case WeatherState.autumn:
        temperature = 0.5;
        humidity = 0.6;
        windStrength = 0.7;
        isRaining = _rng.nextDouble() < 0.2;
        isSnowing = false;
        break;
      case WeatherState.winter:
        temperature = 0.2;
        humidity = 0.3;
        windStrength = 0.3;
        isRaining = false;
        isSnowing = _rng.nextDouble() < 0.5;
        break;
    }
    
    onWeatherChanged?.call(newState);
  }
  
  /// Update weather effects based on current state
  void _updateWeatherEffects(double deltaTime) {
    switch (currentState) {
      case WeatherState.spring:
        // Gentle rain chance
        if (!isRaining && _rng.nextDouble() < deltaTime * 0.001) {
          isRaining = true;
          rainIntensity = 0.3 + _rng.nextDouble() * 0.3;
        }
        if (isRaining && _rng.nextDouble() < deltaTime * 0.002) {
          isRaining = false;
          rainIntensity = 0.0;
        }
        break;
        
      case WeatherState.summer:
        // Occasional thunderstorms
        if (!isRaining && _rng.nextDouble() < deltaTime * 0.0005) {
          isRaining = true;
          rainIntensity = 0.5 + _rng.nextDouble() * 0.5;
          windStrength = min(1.0, windStrength + 0.3);
        }
        break;
        
      case WeatherState.monsoon:
        // Continuous heavy rain
        rainIntensity = 0.7 + sin(seasonElapsed * 0.5) * 0.3;
        break;
        
      case WeatherState.autumn:
        // Windy with leaf particles
        windStrength = 0.5 + sin(seasonElapsed) * 0.3;
        // Occasional rain
        if (!isRaining && _rng.nextDouble() < deltaTime * 0.0008) {
          isRaining = true;
          rainIntensity = 0.4;
        }
        break;
        
      case WeatherState.winter:
        // Snow chance increases with time
        if (!isSnowing && _rng.nextDouble() < deltaTime * 0.001) {
          isSnowing = true;
        }
        if (isSnowing && _rng.nextDouble() < deltaTime * 0.0005) {
          isSnowing = false;
        }
        break;
    }
    
    // Update temperature based on time of day
    final dayTemp = sin(timeOfDay * pi) * 0.3;
    temperature = (temperature + dayTemp * deltaTime * 0.1).clamp(0.0, 1.0);
  }
  
  /// Update wind system
  void _updateWind(double deltaTime) {
    // Wind direction slowly changes
    windDirection = (windDirection + _rng.nextDouble() * 0.1 - 0.05) % (pi * 2);
    
    // Wind strength varies sinusoidally
    final windVariation = sin(seasonElapsed * 0.3) * 0.2;
    windStrength = (windStrength + windVariation * deltaTime * 0.1).clamp(0.0, 1.0);
  }
  
  /// Update precipitation
  void _updatePrecipitation(double deltaTime) {
    if (isRaining) {
      // Rain intensity varies
      rainIntensity = (rainIntensity + (_rng.nextDouble() - 0.5) * deltaTime * 0.2)
          .clamp(0.1, 1.0);
    } else {
      rainIntensity = max(0.0, rainIntensity - deltaTime * 0.1);
    }
  }
  
  /// Get growth multiplier for current weather
  double getGrowthMultiplier() {
    double multiplier = 1.0;
    
    switch (currentState) {
      case WeatherState.spring:
        multiplier = 1.4;
        if (isRaining) multiplier *= 1.2;
        break;
      case WeatherState.summer:
        multiplier = 1.2;
        break;
      case WeatherState.monsoon:
        multiplier = 1.6; // +60% growth
        break;
      case WeatherState.autumn:
        multiplier = 0.8;
        break;
      case WeatherState.winter:
        multiplier = 0.4;
        break;
    }
    
    // Temperature effect
    if (temperature > 0.7) {
      multiplier *= 1.1; // Warm weather boosts growth
    } else if (temperature < 0.3) {
      multiplier *= 0.7; // Cold weather slows growth
    }
    
    return multiplier;
  }
  
  /// Get water contribution from weather (for auto-watering)
  double getWaterContribution() {
    if (isRaining) {
      return rainIntensity * 0.1; // Rain waters plants
    }
    if (isSnowing && temperature > 0.2) {
      return 0.02; // Melting snow provides water
    }
    return 0.0;
  }
  
  /// Get health effect from weather
  double getHealthEffect() {
    double effect = 0.0;
    
    // Rain is good for health
    if (isRaining) {
      effect += 0.01;
    }
    
    // Extreme temperatures are bad
    if (temperature > 0.8) {
      effect -= 0.02; // Heat stress
    }
    if (temperature < 0.2) {
      effect -= 0.03; // Frost damage
    }
    
    return effect;
  }
  
  /// Get wind vector for particle effects
  Offset getWindVector() {
    return Offset(
      cos(windDirection) * windStrength,
      sin(windDirection) * windStrength,
    );
  }
  
  /// Check if it's day time
  bool get isDayTime => timeOfDay > 0.25 && timeOfDay < 0.75;
  
  /// Check if it's night time
  bool get isNightTime => !isDayTime;
  
  /// Get daylight intensity (0.0 = darkest night, 1.0 = brightest day)
  double get daylightIntensity {
    if (isDayTime) {
      // Peak at noon (timeOfDay = 0.5)
      final noonDistance = (timeOfDay - 0.5).abs();
      return 1.0 - noonDistance * 2;
    } else {
      // Night with moonlight
      final midnightDistance = min(timeOfDay, 1.0 - timeOfDay);
      return 0.1 + sin(midnightDistance * pi) * 0.1;
    }
  }
  
  /// Get season-specific visual effects
  List<String> getVisualEffects() {
    final effects = <String>[];
    
    if (isRaining) effects.add('rain');
    if (isSnowing) effects.add('snow');
    if (currentState == WeatherState.autumn) effects.add('leaves');
    if (currentState == WeatherState.summer && isNightTime) effects.add('fireflies');
    if (windStrength > 0.7) effects.add('wind');
    if (humidity > 0.8) effects.add('humidity');
    
    return effects;
  }
  
  /// Get weather description for UI
  String get description {
    switch (currentState) {
      case WeatherState.spring:
        return isRaining ? 'Spring Rain' : 'Spring Breeze';
      case WeatherState.summer:
        return isRaining ? 'Summer Storm' : 'Summer Heat';
      case WeatherState.monsoon:
        return 'Monsoon Rains';
      case WeatherState.autumn:
        return isRaining ? 'Autumn Shower' : 'Autumn Wind';
      case WeatherState.winter:
        return isSnowing ? 'Winter Snowfall' : 'Winter Chill';
    }
  }
  
  /// Get emoji for current weather
  String get emoji {
    switch (currentState) {
      case WeatherState.spring:
        return isRaining ? '🌧️' : '🌸';
      case WeatherState.summer:
        return isRaining ? '⛈️' : '☀️';
      case WeatherState.monsoon:
        return '🌧️';
      case WeatherState.autumn:
        return isRaining ? '🌧️' : '🍂';
      case WeatherState.winter:
        return isSnowing ? '🌨️' : '❄️';
    }
  }
  
  /// Force set weather state (for debugging)
  void setWeatherState(WeatherState state) {
    _setWeatherState(state);
    seasonElapsed = 0.0;
  }
  
  /// Set time of day
  void setTimeOfDay(double time) {
    timeOfDay = time.clamp(0.0, 1.0);
    onTimeChanged?.call(timeOfDay);
  }
}