/// Audio file paths organized by category for the Mindfulness Garden app
/// Updated to use ONLY available files
class AudioConstants {
  // ==================== BACKGROUND MUSIC ====================
  // Theme-based background music for different seasons/moods
  static const String musicSpring = 'assets/music/spring.mp3';
  static const String musicSummer = 'assets/music/summer.mp3';
  static const String musicWinter = 'assets/music/winter.mp3';
  static const String musicRainy = 'assets/music/rainny.mp3';

  // Activity-specific background music
  static const String musicMorningMeditation =
      'assets/music/morning_meditation.mp3';
  static const String musicStressRelief = 'assets/music/stress_relief.mp3';
  static const String musicDeepSleep = 'assets/music/deep_sleep.mp3';
  static const String musicEnergyBoost = 'assets/music/energy_boost.mp3';

  // ==================== BINAURAL BEATS ====================
  // Brainwave entrainment audio for different mental states
  static const String binauralFocus = 'assets/binaural/focus.mp3';
  static const String binauralMeditation = 'assets/binaural/meditation.mp3';
  static const String binauralCreativity = 'assets/binaural/creativity.mp3';
  static const String binauralEnergy = 'assets/binaural/energy.mp3';
  static const String binauralLightSleep = 'assets/binaural/lightSleep.mp3';
  static const String binauralDeepSleep = 'assets/binaural/deepSleep.mp3';

  // ==================== UI SOUND EFFECTS ====================
  // Button and interaction sounds - ONLY AVAILABLE FILES
  static const String uiButtonClick = 'assets/sounds/UI.mp3';
  static const String uiSelect = 'assets/sounds/Select.mp3';
  static const String uiSuccess = 'assets/sounds/UI.mp3'; // Reuse UI.mp3
  static const String uiError = 'assets/sounds/UI.mp3'; // Reuse UI.mp3

  // ==================== NATURE AMBIENCE ====================
  // Animal sounds
  static const String natureBirds = 'assets/sounds/birds.mp3';
  static const String natureCrickets = 'assets/sounds/crickets.mp3';

  // Water sounds
  static const String natureOcean = 'assets/sounds/ocean.mp3';
  static const String natureWaterfall = 'assets/sounds/waterfall.mp3';
  static const String natureRiver = 'assets/sounds/river.wav';

  // Weather sounds
  static const String natureWind = 'assets/sounds/wind.mp3';

  // Forest ambience
  static const String natureForest = 'assets/sounds/forest.mp3';
  static const String natureRainforest = 'assets/sounds/rainforest.mp3';
  static const String natureNight = 'assets/sounds/night.mp3';

  // ==================== MEDITATION SOUNDS ====================
  // Meditation and mindfulness audio
  static const String meditationBowl = 'assets/sounds/bowl.mp3';
  static const String meditationZen = 'assets/sounds/zen.mp3';
  static const String meditationPiano = 'assets/sounds/piano.mp3';

  // ==================== THEME COLLECTIONS ====================
  /// Get background music for different themes/seasons
  static List<String> getThemeMusic(String theme) {
    switch (theme.toLowerCase()) {
      case 'spring':
        return [musicSpring, natureBirds, natureForest];
      case 'summer':
      case 'sunny':
        return [musicSummer, natureCrickets, natureOcean];
      case 'winter':
      case 'snowy':
        return [musicWinter, natureWind, natureNight];
      case 'rainy':
      case 'rain':
        return [musicRainy, natureRainforest];
      case 'cloudy':
        return [musicSpring, natureForest, natureBirds];
      case 'stormy':
        return [musicRainy, natureWind];
      case 'morning':
        return [musicMorningMeditation, natureBirds];
      case 'night':
        return [binauralDeepSleep, natureCrickets, natureNight];
      case 'meditation':
        return [musicStressRelief, meditationZen, meditationBowl];
      case 'sleep':
        return [musicDeepSleep, natureOcean];
      case 'focus':
        return [binauralFocus];
      case 'energy':
        return [musicEnergyBoost, binauralEnergy, natureBirds];
      default:
        return [musicSpring];
    }
  }

  /// Get ambient sounds for garden activities
  static List<String> getGardenAmbience(bool isDay) {
    return isDay ? [natureBirds, natureForest] : [natureCrickets, natureNight];
  }

  /// Get all UI interaction sounds
  static List<String> getAllUISounds() {
    return [
      uiButtonClick,
      uiSelect,
      uiSuccess,
      uiError,
    ];
  }

  /// Get all nature ambience sounds
  static List<String> getAllNatureSounds() {
    return [
      natureBirds,
      natureCrickets,
      natureOcean,
      natureWaterfall,
      natureRiver,
      natureWind,
      natureForest,
      natureRainforest,
      natureNight,
    ];
  }

  /// Get all meditation sounds
  static List<String> getAllMeditationSounds() {
    return [
      meditationBowl,
      meditationZen,
      meditationPiano,
    ];
  }

  /// Get all binaural beats
  static List<String> getAllBinauralBeats() {
    return [
      binauralFocus,
      binauralMeditation,
      binauralCreativity,
      binauralEnergy,
      binauralLightSleep,
      binauralDeepSleep,
    ];
  }

  /// Get all background music
  static List<String> getAllBackgroundMusic() {
    return [
      musicSpring,
      musicSummer,
      musicWinter,
      musicRainy,
      musicMorningMeditation,
      musicStressRelief,
      musicDeepSleep,
      musicEnergyBoost,
    ];
  }
}
