import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/themes/app_theme.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2B1E), Color(0xFF0A1F15), Color(0xFF071810)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats overview
                      _buildStatsOverview(context),

                      const SizedBox(height: 30),

                      // Weekly progress chart
                      _buildWeeklyProgressChart(context),

                      const SizedBox(height: 30),

                      // Milestones
                      _buildMilestonesSection(context),

                      const SizedBox(height: 30),

                      // Recent activity
                      _buildRecentActivitySection(context),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Sessions',
            '127',
            Icons.self_improvement,
            const Color(0xFF4CAF50),
            0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Minutes',
            '1,245',
            Icons.timer,
            const Color(0xFF66BB6A),
            1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Streak',
            '14 days',
            Icons.local_fire_department,
            const Color(0xFF81C784),
            2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildWeeklyProgressChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 15,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: [
                  _buildBarGroup(0, 25, AppTheme.primaryColor),
                  _buildBarGroup(1, 35, AppTheme.primaryColor),
                  _buildBarGroup(2, 20, AppTheme.primaryColor),
                  _buildBarGroup(3, 45, AppTheme.primaryColor),
                  _buildBarGroup(4, 30, AppTheme.primaryColor),
                  _buildBarGroup(5, 55, AppTheme.primaryColor),
                  _buildBarGroup(6, 40, AppTheme.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    final milestones = [
      {'title': 'First Session', 'completed': true, 'icon': Icons.star},
      {'title': '7 Day Streak', 'completed': true, 'icon': Icons.local_fire_department},
      {'title': '30 Sessions', 'completed': true, 'icon': Icons.emoji_events},
      {'title': '100 Minutes', 'completed': true, 'icon': Icons.timer},
      {'title': '14 Day Streak', 'completed': true, 'icon': Icons.whatshot},
      {'title': '50 Sessions', 'completed': false, 'icon': Icons.workspace_premium},
      {'title': '500 Minutes', 'completed': false, 'icon': Icons.timer_outlined},
      {'title': '30 Day Streak', 'completed': false, 'icon': Icons.fireplace},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...milestones.asMap().entries.map((entry) {
          final index = entry.key;
          final milestone = entry.value;
          return _buildMilestoneCard(
            context,
            milestone['title'] as String,
            milestone['completed'] as bool,
            milestone['icon'] as IconData,
            index,
          );
        }),
      ],
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    String title,
    bool completed,
    IconData icon,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? AppTheme.primaryColor.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: completed
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_circle : icon,
              color: completed ? AppTheme.primaryColor : Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: completed ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          if (completed)
            Icon(
              Icons.verified,
              color: AppTheme.primaryColor,
              size: 20,
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50 + 500).ms, duration: 400.ms);
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final activities = [
      {'type': 'Meditation', 'duration': '15 min', 'time': '2 hours ago'},
      {'type': 'Breathing', 'duration': '5 min', 'time': '5 hours ago'},
      {'type': 'Meditation', 'duration': '20 min', 'time': 'Yesterday'},
      {'type': 'Garden', 'duration': '10 min', 'time': 'Yesterday'},
      {'type': 'Breathing', 'duration': '10 min', 'time': '2 days ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return _buildActivityCard(
            context,
            activity['type'] as String,
            activity['duration'] as String,
            activity['time'] as String,
            index,
          );
        }),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String type,
    String duration,
    String time,
    int index,
  ) {
    IconData icon;
    Color color;

    switch (type) {
      case 'Meditation':
        icon = Icons.self_improvement;
        color = AppTheme.primaryColor;
        break;
      case 'Breathing':
        icon = Icons.air;
        color = AppTheme.secondaryColor;
        break;
      case 'Garden':
        icon = Icons.park;
        color = AppTheme.accentColor;
        break;
      default:
        icon = Icons.circle;
        color = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50 + 900).ms, duration: 400.ms);
  }
}
