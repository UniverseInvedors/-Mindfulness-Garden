import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';
import 'package:mindfulness_garden/data/models/session_model.dart';
import 'package:mindfulness_garden/data/models/mood_model.dart';
import 'package:mindfulness_garden/presentation/providers/user_provider.dart';
import 'package:mindfulness_garden/presentation/providers/session_provider.dart';
import 'package:mindfulness_garden/presentation/providers/challenge_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Real data
  List<SessionModel> _sessions = [];
  List<MoodModel> _moods = [];
  int _streak = 0;
  int _totalMinutes = 0;
  int _totalSessions = 0;
  int _avgSession = 0;
  String _bestDay = '—';
  int _bestDayMinutes = 0;
  List<int> _weeklyMinutes = List.filled(7, 0); // Mon–Sun
  List<double> _moodRatings = []; // last 14 days
  List<String> _moodDates = [];
  Map<String, int> _typeBreakdown = {};
  int _completedChallenges = 0;
  int _totalChallengePoints = 0;
  int _moodLogsThisWeek = 0;
  double _avgMoodRating = 0;
  String _moodTrend = 'stable';

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _typeColors = [
    Color(0xFF00b4d8),
    Color(0xFF9d4edd),
    Color(0xFF38b000),
    Color(0xFFf72585),
    Color(0xFFffb700),
    Color(0xFF4361ee),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      // Listen for session provider changes so progress updates live
      try {
        final sessionProv = context.read<SessionProvider>();
        sessionProv.addListener(_onSessionChange);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      final sessionProv = context.read<SessionProvider>();
      sessionProv.removeListener(_onSessionChange);
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  void _onSessionChange() {
    // Debounce / ensure UI still mounted before reloading
    if (!mounted) return;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await context.read<UserProvider>().loadUser();
    await context.read<ChallengeProvider>().loadChallenges();

    final sessions = LocalStorageService.getSessions();
    final moods = LocalStorageService.getAllMoods();
    final streak = LocalStorageService.getCurrentStreak();
    final user = LocalStorageService.getUser();
    final challengeProvider = context.read<ChallengeProvider>();

    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    moods.sort((a, b) => b.date.compareTo(a.date));

    final totalMin = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final avg = sessions.isEmpty ? 0 : totalMin ~/ sessions.length;

    // Weekly minutes (current week Mon–Sun)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekMins = List.filled(7, 0);
    for (final s in sessions) {
      if (s.startTime.isAfter(weekStart.subtract(const Duration(hours: 1)))) {
        final idx = s.startTime.weekday - 1; // 0=Mon
        if (idx >= 0 && idx < 7) weekMins[idx] += s.durationMinutes;
      }
    }

    // Best day
    int maxMin = 0;
    String bestDay = '—';
    for (int i = 0; i < 7; i++) {
      if (weekMins[i] > maxMin) {
        maxMin = weekMins[i];
        bestDay = _days[i];
      }
    }

    // Mood last 14 days
    final mood14Start = now.subtract(const Duration(days: 14));
    final recentMoods = moods.where((m) => m.date.isAfter(mood14Start)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final moodRatings = recentMoods.map((m) => m.rating).toList();
    final moodDates = recentMoods.map((m) {
      return '${m.date.day}/${m.date.month}';
    }).toList();

    // Avg mood
    double avgMood = 0;
    if (moods.isNotEmpty) {
      avgMood = moods.fold(0.0, (s, m) => s + m.rating) / moods.length;
    }

    // Mood trend
    String trend = 'stable';
    if (recentMoods.length >= 6) {
      final first = recentMoods
              .take(recentMoods.length ~/ 2)
              .map((m) => m.rating)
              .reduce((a, b) => a + b) /
          (recentMoods.length ~/ 2);
      final last = recentMoods
              .skip(recentMoods.length ~/ 2)
              .map((m) => m.rating)
              .reduce((a, b) => a + b) /
          (recentMoods.length - recentMoods.length ~/ 2);
      if (last - first > 0.3) {
        trend = 'improving';
      } else if (first - last > 0.3) trend = 'declining';
    }

    // Mood logs this week
    final weekMoods = moods
        .where(
            (m) => m.date.isAfter(weekStart.subtract(const Duration(hours: 1))))
        .length;

    // Session type breakdown
    final typeMap = <String, int>{};
    for (final s in sessions) {
      final t = s.meditationType.isEmpty ? 'Other' : s.meditationType;
      typeMap[t] = (typeMap[t] ?? 0) + 1;
    }

    // Challenges
    final completed =
        challengeProvider.challenges.where((c) => c.isCompleted).length;
    final points = challengeProvider.points;

    setState(() {
      _sessions = sessions;
      _moods = moods;
      _streak = streak;
      _totalMinutes = totalMin;
      _totalSessions = sessions.length;
      _avgSession = avg;
      _weeklyMinutes = weekMins;
      _bestDay = bestDay;
      _bestDayMinutes = maxMin;
      _moodRatings = moodRatings;
      _moodDates = moodDates;
      _typeBreakdown = typeMap;
      _completedChallenges = completed;
      _totalChallengePoints = points;
      _moodLogsThisWeek = weekMoods;
      _avgMoodRating = avgMood;
      _moodTrend = trend;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Progress',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            Text('Real data from your sessions',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00b4d8),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activity'),
            Tab(text: 'Challenges'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00b4d8)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(user),
                _buildActivityTab(),
                _buildChallengesTab(),
              ],
            ),
    );
  }

  // ─── OVERVIEW TAB ─────────────────────────────────────────────────────────

  Widget _buildOverviewTab(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTopStats(),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
          const SizedBox(height: 20),
          if (_moodRatings.isNotEmpty) ...[
            _buildMoodChart(),
            const SizedBox(height: 20),
          ],
          _buildInsightCards(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _statCard('🔥', '$_streak', 'Day Streak', Colors.orange),
        _statCard('⏱', '$_totalMinutes', 'Total Minutes', Colors.blue),
        _statCard('🧘', '$_totalSessions', 'Sessions', Colors.purple),
        _statCard('📊', '$_avgSession min', 'Avg Session', Colors.green),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final maxVal = _weeklyMinutes.isEmpty
        ? 1
        : _weeklyMinutes.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('THIS WEEK',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, letterSpacing: 1)),
              const Spacer(),
              Text(
                  'Best: $_bestDay ${_bestDayMinutes > 0 ? "$_bestDayMinutes min" : ""}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal == 0 ? 10 : maxVal.toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${_days[group.x]}\n${rod.toY.toInt()} min',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(_days[v.toInt()],
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ),
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                    7,
                    (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _weeklyMinutes[i].toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: _weeklyMinutes[i] > 0
                                    ? [
                                        const Color(0xFF00b4d8),
                                        const Color(0xFF9d4edd)
                                      ]
                                    : [Colors.white12, Colors.white12],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        )),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _totalSessions == 0
                ? 'No sessions yet — start your first one!'
                : 'Total this week: ${_weeklyMinutes.fold(0, (a, b) => a + b)} min across ${_sessions.where((s) => s.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length} sessions',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('MOOD TREND (14 DAYS)',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, letterSpacing: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _moodTrendColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _moodTrend == 'improving'
                      ? '↑ Improving'
                      : _moodTrend == 'declining'
                          ? '↓ Declining'
                          : '→ Stable',
                  style: TextStyle(
                      color: _moodTrendColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _moodRatings
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFf72585),
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFFf72585),
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFf72585).withOpacity(0.25),
                          const Color(0xFFf72585).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Avg mood: ${_avgMoodRating.toStringAsFixed(1)}/5',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 12)),
              const Spacer(),
              Text('${_moods.length} total logs',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Color _moodTrendColor() {
    if (_moodTrend == 'improving') return Colors.green;
    if (_moodTrend == 'declining') return Colors.red;
    return Colors.blue;
  }

  Widget _buildInsightCards() {
    final insights = _generateInsights();
    return Column(
      children: insights
          .map((i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: i['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: (i['color'] as Color).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(i['emoji'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(i['body'],
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];
    if (_streak >= 7) {
      insights.add({
        'emoji': '🏆',
        'title': '7-Day Streak!',
        'body':
            'Your consistency is building real neural pathways. Keep going!',
        'color': Colors.amber
      });
    } else if (_streak >= 3) {
      insights.add({
        'emoji': '🔥',
        'title': '$_streak-Day Streak',
        'body': '${7 - _streak} more days to hit your weekly goal!',
        'color': Colors.orange
      });
    } else if (_streak == 0) {
      insights.add({
        'emoji': '💡',
        'title': 'Start Your Streak',
        'body': 'Complete one session today to begin your streak.',
        'color': Colors.blue
      });
    }
    if (_totalMinutes >= 60) {
      insights.add({
        'emoji': '⏱',
        'title': '$_totalMinutes Minutes Mindful',
        'body':
            'That is ${(_totalMinutes / 60).toStringAsFixed(1)} hours of mindfulness practice.',
        'color': Colors.teal
      });
    }
    if (_avgMoodRating >= 4.0) {
      insights.add({
        'emoji': '😊',
        'title': 'Great Mood Average',
        'body':
            'Your avg mood is ${_avgMoodRating.toStringAsFixed(1)}/5 — mindfulness is working!',
        'color': Colors.green
      });
    } else if (_avgMoodRating > 0 && _avgMoodRating < 3.0) {
      insights.add({
        'emoji': '💙',
        'title': 'Mood Needs Attention',
        'body':
            'Your avg mood is ${_avgMoodRating.toStringAsFixed(1)}/5. Try a loving-kindness session.',
        'color': Colors.purple
      });
    }
    if (_moodLogsThisWeek >= 5) {
      insights.add({
        'emoji': '📓',
        'title': 'Consistent Mood Logging',
        'body':
            '$_moodLogsThisWeek mood logs this week — great self-awareness!',
        'color': Colors.pink
      });
    }
    if (insights.isEmpty) {
      insights.add({
        'emoji': '🌱',
        'title': 'Your Journey Begins',
        'body': 'Complete your first session to see real insights here.',
        'color': Colors.green
      });
    }
    return insights;
  }

  // ─── ACTIVITY TAB ─────────────────────────────────────────────────────────

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSessionTypeBreakdown(),
          const SizedBox(height: 20),
          _buildRecentSessions(),
          const SizedBox(height: 20),
          _buildMoodDistribution(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSessionTypeBreakdown() {
    if (_typeBreakdown.isEmpty) {
      return _emptyCard('No sessions yet',
          'Complete a session to see your activity breakdown.');
    }
    final entries = _typeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SESSION TYPES',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: entries
                      .asMap()
                      .entries
                      .map((e) => PieChartSectionData(
                            value: e.value.value.toDouble(),
                            color: _typeColors[e.key % _typeColors.length],
                            radius: 30,
                            title: '',
                          ))
                      .toList(),
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: entries.asMap().entries.map((e) {
                    final pct =
                        total > 0 ? (e.value.value / total * 100).round() : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _typeColors[e.key % _typeColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e.value.key,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('$pct%',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    final recent = _sessions.take(10).toList();
    if (recent.isEmpty) {
      return _emptyCard(
          'No sessions yet', 'Your completed sessions will appear here.');
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECENT SESSIONS',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...recent.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9d4edd).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                          child: Text('🧘', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.meditationType.isEmpty
                                ? 'Meditation'
                                : s.meditationType,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                          Text(
                            _formatDate(s.startTime),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00b4d8).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${s.durationMinutes} min',
                          style: const TextStyle(
                              color: Color(0xFF00b4d8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution() {
    if (_moods.isEmpty) {
      return _emptyCard(
          'No mood logs yet', 'Log your mood daily to see patterns here.');
    }
    final dist = <String, int>{};
    for (final m in _moods) {
      dist[m.mood] = (dist[m.mood] ?? 0) + 1;
    }
    final sorted = dist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('MOOD DISTRIBUTION',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, letterSpacing: 1)),
              const Spacer(),
              Text('${_moods.length} total logs',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          ...sorted.map((e) {
            final pct = _moods.isEmpty ? 0.0 : e.value / _moods.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_moodEmoji(e.key),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e.key,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ),
                      Text('${e.value}x  ${(pct * 100).round()}%',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      color: const Color(0xFFf72585),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'stressed':
        return '😰';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'tired':
        return '😴';
      case 'neutral':
        return '😐';
      case 'anxious':
        return '😟';
      case 'calm':
        return '😌';
      default:
        return '🙂';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) {
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ─── CHALLENGES TAB ───────────────────────────────────────────────────────

  Widget _buildChallengesTab() {
    final provider = context.watch<ChallengeProvider>();
    final challenges = provider.challenges;
    final completed = challenges.where((c) => c.isCompleted).toList();
    final inProgress =
        challenges.where((c) => !c.isCompleted && c.progress > 0).toList();
    final notStarted =
        challenges.where((c) => !c.isCompleted && c.progress == 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                  child: _challengeSummaryCard(
                      '✅', '${completed.length}', 'Completed', Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _challengeSummaryCard('🪙', '$_totalChallengePoints',
                      'Points Earned', Colors.amber)),
              const SizedBox(width: 12),
              Expanded(
                  child: _challengeSummaryCard('🔄', '${inProgress.length}',
                      'In Progress', Colors.blue)),
            ],
          ),
          const SizedBox(height: 20),

          // Overall progress bar
          _buildOverallChallengeProgress(challenges.length, completed.length),
          const SizedBox(height: 20),

          // In progress
          if (inProgress.isNotEmpty) ...[
            _sectionLabel('IN PROGRESS'),
            const SizedBox(height: 10),
            ...inProgress.map((c) => _challengeProgressCard(c)),
            const SizedBox(height: 20),
          ],

          // Completed
          if (completed.isNotEmpty) ...[
            _sectionLabel('COMPLETED'),
            const SizedBox(height: 10),
            ...completed.map((c) => _challengeCompletedCard(c)),
            const SizedBox(height: 20),
          ],

          // Not started
          if (notStarted.isNotEmpty) ...[
            _sectionLabel('NOT STARTED'),
            const SizedBox(height: 10),
            ...notStarted.map((c) => _challengeLockedCard(c)),
            const SizedBox(height: 20),
          ],

          // Analytics
          _buildChallengeAnalytics(challenges),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _challengeSummaryCard(
      String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text(label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOverallChallengeProgress(int total, int done) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('OVERALL PROGRESS',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, letterSpacing: 1)),
              const Spacer(),
              Text('$done / $total',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: const Color(0xFF00b4d8),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(pct * 100).round()}% of all challenges completed',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _challengeProgressCard(dynamic c) {
    final color = _challengeColor(c.type.toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('+${c.reward} 🪙',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.description,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.progress,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(c.progress * 100).round()}%',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _challengeCompletedCard(dynamic c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(c.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          Text('+${c.reward} 🪙',
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _challengeLockedCard(dynamic c) {
    final color = _challengeColor(c.type.toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline,
              color: Colors.white.withOpacity(0.3), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(c.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 11)),
              ],
            ),
          ),
          Text('+${c.reward} 🪙',
              style: TextStyle(color: color.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChallengeAnalytics(List<dynamic> challenges) {
    final byType = <String, Map<String, int>>{};
    for (final c in challenges) {
      final t = c.type.toString().split('.').last;
      byType.putIfAbsent(t, () => {'total': 0, 'done': 0});
      byType[t]!['total'] = byType[t]!['total']! + 1;
      if (c.isCompleted) byType[t]!['done'] = byType[t]!['done']! + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BY CATEGORY',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 14),
          ...byType.entries.map((e) {
            final pct = e.value['total']! == 0
                ? 0.0
                : e.value['done']! / e.value['total']!;
            final color = _challengeColor('ChallengeType.${e.key}');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(e.key.toUpperCase(),
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const Spacer(),
                      Text('${e.value['done']}/${e.value['total']}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _challengeColor(String type) {
    if (type.contains('daily')) return const Color(0xFF00b4d8);
    if (type.contains('weekly')) return const Color(0xFF9d4edd);
    if (type.contains('achievement')) return Colors.amber;
    if (type.contains('social')) return Colors.orange;
    if (type.contains('garden')) return const Color(0xFF38b000);
    return const Color(0xFFf72585);
  }

  Widget _sectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _emptyCard(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(body,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
