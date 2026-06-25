import 'package:flutter/services.dart';

/// Haptic feedback service for sensory feedback
class HapticService {
  /// Light impact for taps
  Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Medium impact for interactions
  Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Heavy impact for important events
  Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Selection click for UI interactions
  Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Success pulse for rewards
  Future<void> successPulse() async {
    try {
      // Simulate success pulse with multiple haptics
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Error impact for failures
  Future<void> errorImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Warning vibration for warnings
  Future<void> warningVibration() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Custom vibration pattern
  Future<void> customVibration(List<int> pattern) async {
    try {
      for (final duration in pattern) {
        await HapticFeedback.vibrate();
        await Future.delayed(Duration(milliseconds: duration));
      }
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Plant growth feedback
  Future<void> growthFeedback() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Harvest feedback
  Future<void> harvestFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Watering feedback
  Future<void> wateringFeedback() async {
    try {
      await HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 30));
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Meditation energy feedback
  Future<void> energyFeedback() async {
    try {
      // Gentle pulsing for energy gain
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
  
  /// Disturbance feedback (negative)
  Future<void> disturbanceFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available on this device
    }
  }
}
