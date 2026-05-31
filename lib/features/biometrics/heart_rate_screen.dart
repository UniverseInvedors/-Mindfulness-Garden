// lib/features/biometrics/heart_rate_screen.dart - COMPLETE VERSION
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'dart:async';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  int _currentHeartRate = 72;
  bool _isMeasuring = false;
  bool _hasPermission = false;
  List<int> _heartRateHistory = [];
  Timer? _measurementTimer;
  Timer? _simulationTimer;
  DateTime? _lastMeasurement;
  String _heartRateStatus = 'Normal';
  Color _heartRateColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadHeartRateHistory();
    _startHeartRateSimulation();
  }

  @override
  void dispose() {
    _measurementTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.sensors.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  void _loadHeartRateHistory() {
    // Load sample data
    final random = Random();
    setState(() {
      _heartRateHistory = List.generate(24, (index) => 60 + random.nextInt(40));
      _lastMeasurement = DateTime.now().subtract(const Duration(minutes: 30));
    });
  }

  void _startHeartRateSimulation() {
    final random = Random();
    _simulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isMeasuring) {
        final variation = random.nextInt(5) - 2;
        setState(() {
          _currentHeartRate = (68 + variation).clamp(60, 100);
          _updateHeartRateStatus();
        });
      }
    });
  }

  void _startMeasurement() async {
    if (!_hasPermission) {
      await _requestPermissions();
      if (!_hasPermission) {
        _showPermissionDialog();
        return;
      }
    }

    setState(() {
      _isMeasuring = true;
      _currentHeartRate = 72; // Reset to baseline
    });

    // Simulate measurement process
    _measurementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final random = Random();
      if (timer.tick <= 10) {
        // Simulate heart rate measurement
        final variation = random.nextInt(10) - 5;
        setState(() {
          _currentHeartRate = (72 + variation + timer.tick).clamp(65, 85);
        });
      } else {
        // Complete measurement
        timer.cancel();
        _completeMeasurement();
      }
    });
  }

  void _completeMeasurement() {
    setState(() {
      _isMeasuring = false;
      _lastMeasurement = DateTime.now();
      _heartRateHistory.insert(0, _currentHeartRate);
      if (_heartRateHistory.length > 50) {
        _heartRateHistory.removeLast();
      }
      _updateHeartRateStatus();
    });

    // Show measurement result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Heart rate measured: $_currentHeartRate BPM'),
        backgroundColor: _heartRateColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _updateHeartRateStatus() {
    if (_currentHeartRate < 60) {
      _heartRateStatus = 'Low';
      _heartRateColor = Colors.blue;
    } else if (_currentHeartRate < 100) {
      _heartRateStatus = 'Normal';
      _heartRateColor = Colors.green;
    } else {
      _heartRateStatus = 'High';
      _heartRateColor = Colors.red;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Heart rate monitoring requires sensor permissions. '
              'Please enable permissions in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showMeasurementHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e).withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _buildHistorySheet(scrollController),
      ),
    );
  }

  Widget _buildHistorySheet(ScrollController scrollController) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Heart Rate History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 200,
            child: _buildHeartRateChart(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _heartRateHistory.length,
            itemBuilder: (context, index) {
              final rate = _heartRateHistory[index];
              final time = DateTime.now().subtract(Duration(minutes: index * 30));
              return _buildHistoryItem(rate, time, index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateChart() {
    if (_heartRateHistory.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final maxRate = _heartRateHistory.reduce(max);
    final minRate = _heartRateHistory.reduce(min);

    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 200),
      painter: _HeartRateChartPainter(
        data: _heartRateHistory,
        maxValue: maxRate.toDouble(),
        minValue: minRate.toDouble(),
        isMeasuring: _isMeasuring,
      ),
    );
  }

  Widget _buildHistoryItem(int rate, DateTime time, int index) {
    Color rateColor;
    if (rate < 60) {
      rateColor = Colors.blue;
    } else if (rate < 100) {
      rateColor = Colors.green;
    } else {
      rateColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rateColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.favorite,
                color: rateColor,
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
                  '$rate BPM',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusForRate(rate),
              style: TextStyle(
                fontSize: 12,
                color: rateColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusForRate(int rate) {
    if (rate < 60) return 'Low';
    if (rate < 100) return 'Normal';
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Monitor'),
        backgroundColor: const Color(0xFF0a0a1a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        actions: [
          IconButton(
            onPressed: _showMeasurementHistory,
            icon: const Icon(Icons.history),
            tooltip: 'History',
          ),
          IconButton(
            onPressed: () {
              // Settings
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0a1a),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Heart rate visualization
              _buildHeartRateVisualization(),
              const SizedBox(height: 30),

              // Stats
              _buildHeartRateStats(),
              const SizedBox(height: 30),

              // Measurement button
              _buildMeasurementButton(),
              const SizedBox(height: 30),

              // Tips
              _buildHealthTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartRateVisualization() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _heartRateColor.withOpacity(0.1),
            _heartRateColor.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _heartRateColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Animated heart
          _buildAnimatedHeart(),
          const SizedBox(height: 20),

          // Heart rate display
          Text(
            '$_currentHeartRate',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: _heartRateColor,
            ),
          ),
          Text(
            'BPM',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _heartRateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _heartRateStatus,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _heartRateColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeart() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 100,
      height: 100,
      child: Icon(
        Icons.favorite,
        color: _heartRateColor,
        size: _isMeasuring ? 110 : 100,
      ),
    );
  }

  Widget _buildHeartRateStats() {
    final avgRate = _heartRateHistory.isNotEmpty
        ? _heartRateHistory.reduce((a, b) => a + b) ~/ _heartRateHistory.length
        : 0;
    final minRate = _heartRateHistory.isNotEmpty
        ? _heartRateHistory.reduce(min)
        : 0;
    final maxRate = _heartRateHistory.isNotEmpty
        ? _heartRateHistory.reduce(max)
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'Average',
          '$avgRate',
          Icons.timeline,
          Colors.blue,
        ),
        _buildStatCard(
          'Minimum',
          '$minRate',
          Icons.arrow_downward,
          Colors.green,
        ),
        _buildStatCard(
          'Maximum',
          '$maxRate',
          Icons.arrow_upward,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementButton() {
    return Column(
      children: [
        if (_lastMeasurement != null) ...[
          Text(
            'Last measured: ${_lastMeasurement!.hour}:${_lastMeasurement!.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ElevatedButton(
          onPressed: _isMeasuring ? null : _startMeasurement,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isMeasuring ? Colors.grey : Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isMeasuring ? Icons.stop : Icons.favorite,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _isMeasuring ? 'MEASURING...' : 'MEASURE HEART RATE',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!_hasPermission) ...[
          const SizedBox(height: 10),
          Text(
            'Permissions needed for accurate measurement',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHealthTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Health Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            'Resting heart rate typically ranges from 60-100 BPM',
            Icons.info,
          ),
          _buildTipItem(
            'Regular meditation can help lower resting heart rate',
            Icons.self_improvement,
          ),
          _buildTipItem(
            'Stay hydrated and avoid caffeine before measurement',
            Icons.local_drink,
          ),
          _buildTipItem(
            'Sit quietly for 5 minutes before measuring for accurate results',
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateChartPainter extends CustomPainter {
  final List<int> data;
  final double maxValue;
  final double minValue;
  final bool isMeasuring;

  _HeartRateChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.isMeasuring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final valueRange = maxValue - minValue;
    final xStep = size.width / (data.length - 1);

    // Create path for line
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final normalizedValue = (data[i] - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final normalizedValue = (data[i] - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
