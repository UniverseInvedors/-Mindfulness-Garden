// lib/core/services/auto_theme_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pranaverse/core/services/location_time_service.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/services/audio_manager_service.dart';

/// Service to automatically change theme based on time and season
class AutoThemeService extends ChangeNotifier {
  static final AutoThemeService _instance = AutoThemeService._internal();
  factory AutoThemeService() => _instance;
  AutoThemeService._internal();

  final LocationTimeService _locationService = LocationTimeService();
  Timer? _themeCheckTimer;
  bool _autoThemeEnabled = true;
  bool _autoBackgroundEnabled = true;
  bool _autoWeatherEnabled = true;
  bool _autoDayNightEnabled = true;
  String _manualWeather = 'Sunny';

  // Getters
  bool get autoThemeEnabled => _autoThemeEnabled;
  bool get autoBackgroundEnabled => _autoBackgroundEnabled;
  bool get autoWeatherEnabled => _autoWeatherEnabled;
  bool get autoDayNightEnabled => _autoDayNightEnabled;
  String get manualWeather => _manualWeather;
  LocationTimeService get locationService => _locationService;

  /// Initialize auto theme service
  Future<void> initialize() async {
    // Load preferences
    final autoTheme = LocalStorageService.getSetting('auto_theme_enabled');
    _autoThemeEnabled = autoTheme is bool ? autoTheme : true;

    final autoBg = LocalStorageService.getSetting('auto_background_enabled');
    _autoBackgroundEnabled = autoBg is bool ? autoBg : true;

    final autoWeather = LocalStorageService.getSetting('auto_weather_enabled');
    _autoWeatherEnabled = autoWeather is bool ? autoWeather : true;

    final autoDayNight =
        LocalStorageService.getSetting('auto_daynight_enabled');
    _autoDayNightEnabled = autoDayNight is bool ? autoDayNight : true;

    final manualW = LocalStorageService.getSetting('manual_weather');
    _manualWeather = manualW is String ? manualW : 'Sunny';

    // Initialize location service
    await _locationService.initialize();

    // Listen to location service changes
    _locationService.addListener(_onLocationDataChanged);

    // Start periodic theme checks
    _startThemeCheckTimer();
  }

  /// Called when location/time data changes
  void _onLocationDataChanged() {
    if (_autoThemeEnabled || _autoBackgroundEnabled) {
      notifyListeners();
    }
  }

  /// Start timer to check theme every minute
  void _startThemeCheckTimer() {
    _themeCheckTimer?.cancel();
    _themeCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_autoThemeEnabled || _autoBackgroundEnabled) {
        notifyListeners();
      }
    });
  }

  /// Get current background image based on season and time
  String? getCurrentBackgroundImage() {
    if (!_autoBackgroundEnabled) return null;

    final season = _locationService.currentSeason;
    final timeOfDay = _locationService.timeOfDay;

    // Priority: time of day > season
    // Night overrides everything
    if (timeOfDay == TimeOfDay.night) {
      return 'assets/images/winter.jpeg'; // Use dark winter for night
    }

    // Map season to background
    switch (season) {
      case Season.spring:
        return 'assets/images/spring.jpeg';
      case Season.summer:
        return 'assets/images/summer.jpeg';
      case Season.autumn:
        return 'assets/images/autumn.jpeg';
      case Season.winter:
        return 'assets/images/winter.jpeg';
    }
  }

  /// Get current garden season based on date
  GardenSeason getCurrentGardenSeason() {
    final season = _locationService.currentSeason;

    // Check if it's rainy season (June-September in many regions)
    final month = _locationService.currentDateTime?.month ?? 6;
    if (month >= 6 && month <= 9) {
      return GardenSeason.monsoon;
    }

    switch (season) {
      case Season.spring:
        return GardenSeason.spring;
      case Season.summer:
        return GardenSeason.summer;
      case Season.autumn:
        return GardenSeason.autumn;
      case Season.winter:
        // Check if it's heavy winter
        if (month == 12 || month == 1) {
          return GardenSeason.snowfall;
        }
        return GardenSeason.winter;
    }
  }

  /// Check if dark theme should be used
  bool shouldUseDarkTheme() {
    if (!_autoThemeEnabled) return true; // Default to dark
    return _locationService.shouldUseDarkTheme;
  }

  /// Toggle auto theme
  Future<void> setAutoTheme(bool enabled) async {
    _autoThemeEnabled = enabled;
    await LocalStorageService.saveSetting('auto_theme_enabled', enabled);
    notifyListeners();
  }

  /// Toggle auto background
  Future<void> setAutoBackground(bool enabled) async {
    _autoBackgroundEnabled = enabled;
    await LocalStorageService.saveSetting('auto_background_enabled', enabled);
    notifyListeners();
  }

  /// Toggle auto weather
  Future<void> setAutoWeather(bool enabled) async {
    _autoWeatherEnabled = enabled;
    await LocalStorageService.saveSetting('auto_weather_enabled', enabled);
    notifyListeners();
  }

  /// Set manual weather
  Future<void> setManualWeather(String weather) async {
    _manualWeather = weather;
    await LocalStorageService.saveSetting('manual_weather', weather);

    // Change background music based on weather
    final AudioManagerService audioManager = AudioManagerService();
    await audioManager.changeTheme(weather.toLowerCase());

    notifyListeners();
  }

  /// Toggle auto day/night cycle
  Future<void> setAutoDayNight(bool enabled) async {
    _autoDayNightEnabled = enabled;
    await LocalStorageService.saveSetting('auto_daynight_enabled', enabled);
    notifyListeners();
  }

  /// Get current weather based on location or manual setting
  String getCurrentWeather() {
    if (!_autoWeatherEnabled) {
      return _manualWeather;
    }

    // Auto-detect weather based on season and time
    final season = _locationService.currentSeason;
    final month = _locationService.currentDateTime?.month ?? 1;
    final timeOfDay = _locationService.timeOfDay;

    // Night is cloudy/clear based on season
    if (timeOfDay == TimeOfDay.night) {
      return 'Cloudy';
    }

    // Monsoon season (June-September)
    if (month >= 6 && month <= 9) {
      return 'Rainy';
    }

    // Winter months
    if (month == 12 || month == 1 || month == 2) {
      return 'Snowy';
    }

    // Map season to weather
    switch (season) {
      case Season.spring:
        return 'Sunny';
      case Season.summer:
        return 'Sunny';
      case Season.autumn:
        return 'Cloudy';
      case Season.winter:
        return 'Snowy';
    }
  }

  /// Check if it's currently day or night
  bool isDay() {
    if (!_autoDayNightEnabled) {
      return true; // Default to day
    }
    return _locationService.timeOfDay != TimeOfDay.night;
  }

  /// Manually refresh location and time data
  Future<void> refresh() async {
    await _locationService.refresh();
  }

  @override
  void dispose() {
    _themeCheckTimer?.cancel();
    _locationService.removeListener(_onLocationDataChanged);
    super.dispose();
  }
}

/// Garden season enum (matches existing Season enum in garden)
enum GardenSeason { spring, summer, monsoon, autumn, winter, snowfall }
