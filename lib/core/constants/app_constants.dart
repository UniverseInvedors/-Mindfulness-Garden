class AppConstants {
  // App Info
  static const String appName = 'Mindfulness Garden';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeModeKey = 'theme_mode';
  static const String notificationsKey = 'notifications_enabled';
  static const String soundEnabledKey = 'sound_enabled';
  static const String vibrationEnabledKey = 'vibration_enabled';

  // Default Values
  static const int defaultSessionDuration = 10;
  static const int maxGardenLevel = 50;
  static const int minutesPerLevel = 60;

  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration breathingAnimationDuration = Duration(seconds: 4);

  // Colors
  static const List<int> gardenLevelColors = [
    0xFF6C63FF, // Level 1
    0xFF4CD97B, // Level 2
    0xFFFF6584, // Level 3
    0xFFFFB74D, // Level 4
    0xFF9575CD, // Level 5
    0xFF4FC3F7, // Level 6
    0xFF81C784, // Level 7
    0xFFFF8A65, // Level 8
    0xFFBA68C8, // Level 9
    0xFF4DB6AC, // Level 10
  ];

  // Meditation Types
  static const List<String> meditationTypes = [
    'Breath Awareness',
    'Body Scan',
    'Loving-Kindness',
    'Guided Meditation',
    'Walking Meditation',
    'Sleep Meditation',
    'Anxiety Relief',
    'Focus & Concentration',
  ];

  // Mood Options
  static const List<Map<String, dynamic>> moodOptions = [
    {'emoji': '😢', 'label': 'Sad', 'color': 0xFF2196F3},
    {'emoji': '😐', 'label': 'Neutral', 'color': 0xFF9E9E9E},
    {'emoji': '🙂', 'label': 'Good', 'color': 0xFF4CAF50},
    {'emoji': '😊', 'label': 'Happy', 'color': 0xFFFFC107},
    {'emoji': '😄', 'label': 'Great', 'color': 0xFFFF9800},
    {'emoji': '🤩', 'label': 'Awesome', 'color': 0xFFE91E63},
  ];

  // Sound Options
  static const List<Map<String, dynamic>> soundOptions = [
    {'id': 'ocean', 'name': 'Ocean Waves', 'icon': '🌊', 'color': 0xFF2196F3},
    {'id': 'rain', 'name': 'Gentle Rain', 'icon': '🌧️', 'color': 0xFF607D8B},
    {'id': 'forest', 'name': 'Forest Birds', 'icon': '🌲', 'color': 0xFF4CAF50},
    {'id': 'bowl', 'name': 'Singing Bowl', 'icon': '🛎️', 'color': 0xFFFF9800},
    {'id': 'white', 'name': 'White Noise', 'icon': '📻', 'color': 0xFF9E9E9E},
    {'id': 'piano', 'name': 'Calm Piano', 'icon': '🎹', 'color': 0xFF9C27B0},
  ];
}
