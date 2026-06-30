// lib/core/services/location_time_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Service to fetch and manage location, date, and time data
/// Uses free APIs: WorldTimeAPI (time/date) and OpenStreetMap (location names)
class LocationTimeService extends ChangeNotifier {
  static final LocationTimeService _instance = LocationTimeService._internal();
  factory LocationTimeService() => _instance;
  LocationTimeService._internal();

  // Current data
  DateTime? _currentDateTime;
  String? _timezone;
  String? _cityName;
  String? _countryName;
  Position? _position;
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;

  // Getters
  DateTime? get currentDateTime => _currentDateTime;
  String? get timezone => _timezone;
  String? get cityName => _cityName;
  String? get countryName => _countryName;
  Position? get position => _position;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Time-based theme determination
  TimeOfDay get timeOfDay {
    if (_currentDateTime == null) {
      return TimeOfDay.morning;
    }
    final hour = _currentDateTime!.hour;
    if (hour >= 5 && hour < 8) return TimeOfDay.dawn;
    if (hour >= 8 && hour < 12) return TimeOfDay.morning;
    if (hour >= 12 && hour < 17) return TimeOfDay.afternoon;
    if (hour >= 17 && hour < 20) return TimeOfDay.dusk;
    return TimeOfDay.night;
  }

  // Season based on date (Northern Hemisphere)
  Season get currentSeason {
    if (_currentDateTime == null) {
      return Season.spring;
    }
    final month = _currentDateTime!.month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  // Dark theme based on time
  bool get shouldUseDarkTheme {
    if (_currentDateTime == null) return true;
    final hour = _currentDateTime!.hour;
    return hour < 6 || hour >= 19; // Dark from 7 PM to 6 AM
  }

  // Formatted strings
  String get formattedTime => _currentDateTime != null
      ? DateFormat('hh:mm a').format(_currentDateTime!)
      : '--:--';

  String get formattedDate => _currentDateTime != null
      ? DateFormat('EEEE, MMMM d, yyyy').format(_currentDateTime!)
      : 'Loading...';

  String get formattedLocation => _cityName != null && _countryName != null
      ? '$_cityName, $_countryName'
      : (_cityName ?? 'Unknown Location');

  /// Initialize and start automatic updates
  Future<void> initialize() async {
    await fetchAllData();
    _startAutoUpdate();
  }

  /// Fetch all data (location, time, date)
  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch location
      await _fetchLocation();

      // Fetch time from WorldTimeAPI
      await _fetchWorldTime();

      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('LocationTimeService Error: $e');
      // Fallback to device time
      _currentDateTime = DateTime.now();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get device location
  Future<void> _fetchLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      // Get position
      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Reverse geocode using free OpenStreetMap Nominatim API
      await _fetchLocationName(_position!.latitude, _position!.longitude);
    } catch (e) {
      if (kDebugMode) print('Location fetch error: $e');
      _cityName = 'Unknown';
      _countryName = '';
    }
  }

  /// Get location name from coordinates using OpenStreetMap Nominatim (Free)
  Future<void> _fetchLocationName(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=$lat&lon=$lon&format=json&accept-language=en',
      );

      final response = await http
          .get(url, headers: {'User-Agent': 'PranaverseMindfulnessApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        _cityName =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            'Unknown';
        _countryName = address['country'] ?? '';
      }
    } catch (e) {
      if (kDebugMode) print('Location name fetch error: $e');
      _cityName = 'Unknown';
    }
  }

  /// Fetch current time from WorldTimeAPI (Free, no API key needed)
  Future<void> _fetchWorldTime() async {
    try {
      // Use timezone or fallback to IP-based detection
      String endpoint = 'http://worldtimeapi.org/api/ip';

      if (_timezone != null && _timezone!.isNotEmpty) {
        endpoint = 'http://worldtimeapi.org/api/timezone/$_timezone';
      }

      final response = await http
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _currentDateTime = DateTime.parse(data['datetime']);
        _timezone = data['timezone'];
      } else {
        // Fallback to device time
        _currentDateTime = DateTime.now();
      }
    } catch (e) {
      if (kDebugMode) print('Time fetch error: $e');
      // Fallback to device time
      _currentDateTime = DateTime.now();
    }
  }

  /// Start automatic updates every minute
  void _startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      fetchAllData();
    });
  }

  /// Stop automatic updates
  void stopAutoUpdate() {
    _updateTimer?.cancel();
  }

  /// Manual refresh
  Future<void> refresh() async {
    await fetchAllData();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

/// Time of day enum
enum TimeOfDay { dawn, morning, afternoon, dusk, night }

/// Season enum
enum Season { spring, summer, autumn, winter }
