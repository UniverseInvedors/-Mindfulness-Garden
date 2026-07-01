// lib/features/sleep/sleep_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/mixins/theme_audio_mixin.dart';

enum SleepQuality { excellent, good, fair, poor }

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen>
    with ThemeAudioMixin {
  bool _isTracking = false;
  DateTime? _sleepStartTime;
  SleepQuality _sleepQuality = SleepQuality.good;
  final double _sleepDuration = 7.5;
  List<Map<String, dynamic>> _sleepHistory = [];

  @override
  void initState() {
    super.initState();
    startThemeAudio();
    _requestPermissions();
    _loadSleepData();
  }

  @override
  void dispose() {
    stopThemeAudio();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.notification.request();
  }

  Future<void> _loadSleepData() async {
    // For now, load dummy data
    // In a real app, you would connect to HealthKit or Google Fit
    setState(() {
      _sleepHistory = [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'duration': 7.2,
          'quality': SleepQuality.good,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'duration': 6.8,
          'quality': SleepQuality.fair,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'duration': 8.1,
          'quality': SleepQuality.excellent,
        },
      ];
    });
  }

  void _startSleepTracking() {
    setState(() {
      _isTracking = true;
      _sleepStartTime = DateTime.now();
    });

    // Show tracking started notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep tracking started'),
        duration: Duration(seconds: 2),
      ),
    );

    // Schedule wake-up reminder
    _scheduleWakeUpReminder();
  }

  void _stopSleepTracking() async {
    if (_sleepStartTime == null) return;

    setState(() {
      _isTracking = false;
    });

    final sleepDuration = DateTime.now().difference(_sleepStartTime!);
    final hours = sleepDuration.inHours + (sleepDuration.inMinutes % 60) / 60;

    // Save sleep data locally
    await _saveSleepSession(hours);

    // Analyze sleep quality
    _analyzeSleepQuality(sleepDuration);

    // Show tracking stopped notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sleep tracking stopped. Duration: ${hours.toStringAsFixed(1)} hours',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveSleepSession(double hours) async {
    final newEntry = {
      'date': DateTime.now(),
      'duration': hours,
      'quality': _sleepQuality,
    };

    setState(() {
      _sleepHistory.insert(0, newEntry);
    });

    // Here you would save to local database or cloud
    // For example: await DatabaseService().saveSleepEntry(newEntry);
  }

  void _analyzeSleepQuality(Duration duration) {
    final hours = duration.inHours + (duration.inMinutes % 60) / 60;

    if (hours >= 7 && hours <= 9) {
      _sleepQuality = SleepQuality.excellent;
    } else if (hours >= 6 && hours < 7) {
      _sleepQuality = SleepQuality.good;
    } else if (hours >= 5 && hours < 6) {
      _sleepQuality = SleepQuality.fair;
    } else {
      _sleepQuality = SleepQuality.poor;
    }

    setState(() {});
  }

  void _scheduleWakeUpReminder() {
    // Implement wake-up scheduling logic here
    // Could use flutter_local_notifications package
  }

  Widget _buildSleepQuality() {
    return Text(
      'Sleep Quality: ${_sleepQuality.name.toUpperCase()}',
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildTrackingControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isTracking ? null : _startSleepTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.grey : Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(
                _isTracking ? 'TRACKING...' : 'START SLEEP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _isTracking ? _stopSleepTracking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'STOP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _isTracking
              ? 'Sleep tracking in progress...'
              : 'Ready to track sleep',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        if (_isTracking && _sleepStartTime != null) ...[
          const SizedBox(height: 10),
          Text(
            'Started: ${_sleepStartTime!.hour}:${_sleepStartTime!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildBedtimeRoutine() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bedtime Routine',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRoutineItem('🧘‍♀️', 'Meditation', '5 min mindfulness'),
          _buildRoutineItem('📖', 'Reading', 'Relaxing book'),
          _buildRoutineItem('🎵', 'Calm Music', 'Sleep sounds'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Start bedtime routine
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.withOpacity(0.7),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Start Bedtime Routine'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  Widget _buildSleepHistory() {
    if (_sleepHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No sleep data yet\nStart tracking your sleep!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Sleep History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._sleepHistory.take(3).map((entry) => _buildHistoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final date = entry['date'] as DateTime;
    final duration = entry['duration'] as double;
    final quality = entry['quality'] as SleepQuality;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getQualityColor(quality).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _getQualityIcon(quality),
                color: _getQualityColor(quality),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${duration.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${date.month}/${date.day} • ${quality.name.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.excellent:
        return Colors.green;
      case SleepQuality.good:
        return Colors.lightGreen;
      case SleepQuality.fair:
        return Colors.orange;
      case SleepQuality.poor:
        return Colors.red;
    }
  }

  IconData _getQualityIcon(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.excellent:
        return Icons.star;
      case SleepQuality.good:
        return Icons.star_half;
      case SleepQuality.fair:
        return Icons.nightlight;
      case SleepQuality.poor:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: const Color(0xFF0f3460),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/main'),
        ),
        actions: [
          IconButton(
            onPressed: _loadSleepData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            onPressed: () {
              // Show settings or history
            },
            icon: const Icon(Icons.history),
            tooltip: 'Sleep History',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0f3460), Color(0xFF16213e), Color(0xFF1a1a2e)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Sleep Stats
                _buildSleepStats(),
                const SizedBox(height: 20),

                // Sleep Quality
                _buildSleepQuality(),
                const SizedBox(height: 20),

                // Sleep Tracking Controls
                _buildTrackingControls(),
                const SizedBox(height: 30),

                // Bedtime Routine
                _buildBedtimeRoutine(),
                const SizedBox(height: 20),

                // Sleep History
                _buildSleepHistory(),
                const SizedBox(height: 20),

                // Additional Info
                Text(
                  'Track your sleep to improve mindfulness and overall health',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SLEEP STATISTICS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Duration',
                '${_sleepDuration.toStringAsFixed(1)}h',
                Icons.timer,
                Colors.blue,
              ),
              _buildStatItem(
                'Quality',
                _sleepQuality.name.toUpperCase(),
                Icons.star,
                _getQualityColor(_sleepQuality),
              ),
              _buildStatItem(
                'Streak',
                '${_sleepHistory.length} days',
                Icons.trending_up,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }
}
