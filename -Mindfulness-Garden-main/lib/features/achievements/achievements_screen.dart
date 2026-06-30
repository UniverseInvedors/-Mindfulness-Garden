import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/presentation/providers/achievement_provider.dart';
import 'package:pranaverse/data/models/achievement_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final achievementProvider = context.watch<AchievementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: const Color(0xFF1a1a2e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Column(
          children: [
            // Stats Summary
            _buildStatsSummary(achievementProvider),

            // Achievement Categories
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Meditation'),
                        Tab(text: 'Garden'),
                        Tab(text: 'Social'),
                      ],
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAchievementGrid(
                              achievementProvider.achievements),
                          _buildAchievementGrid(
                            achievementProvider.achievements
                                .where((a) => a.category == 'Meditation')
                                .toList(),
                          ),
                          _buildAchievementGrid(
                            achievementProvider.achievements
                                .where((a) => a.category == 'Garden')
                                .toList(),
                          ),
                          _buildAchievementGrid(
                            achievementProvider.achievements
                                .where((a) => a.category == 'Social')
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(AchievementProvider provider) {
    final unlockedCount =
        provider.achievements.where((a) => a.isUnlocked).length;
    final totalCount = provider.achievements.length;
    final inProgressCount = provider.achievements
        .where((a) => !a.isUnlocked && a.progress > 0)
        .length;
    final totalPoints = provider.achievements
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.rewardValue);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'ACHIEVEMENT PROGRESS',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$unlockedCount/$totalCount',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: totalCount > 0 ? unlockedCount / totalCount : 0,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: Colors.yellow,
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Unlocked', unlockedCount.toString()),
              _buildStatItem('In Progress', inProgressCount.toString()),
              _buildStatItem('Total Points', totalPoints.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildAchievementGrid(List<AchievementModel> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Text(
          'No achievements found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
    // Map icon strings to emojis or Flutter icons
    final iconWidget = _getIconWidget(achievement.icon);

    // Get color based on rarity
    final Color color = _getRarityColor(achievement.rarity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked
              ? color.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: achievement.isUnlocked ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Achievement Content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? color.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: achievement.isUnlocked ? color : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(height: 15),

                // Title
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        achievement.isUnlocked ? Colors.white : Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Progress or Points
                if (!achievement.isUnlocked)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: color,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),

                if (achievement.isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.yellow),
                        const SizedBox(width: 5),
                        Text(
                          '+${achievement.rewardValue}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.yellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Unlocked Badge
          if (achievement.isUnlocked)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.black),
              ),
            ),

          // Rarity Indicator
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                achievement.rarity.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconWidget(String icon) {
    // Handle emoji icons
    if (icon.length == 1 ||
        (icon.length == 2 && icon.codeUnits.any((c) => c > 127))) {
      return Text(
        icon,
        style: const TextStyle(fontSize: 35),
      );
    }

    // Map common icon names to Flutter icons
    switch (icon) {
      case '🔥':
        return const Text('🔥', style: TextStyle(fontSize: 35));
      case '⏱️':
        return const Text('⏱️', style: TextStyle(fontSize: 35));
      case '🌿':
        return const Text('🌿', style: TextStyle(fontSize: 35));
      case '🌬️':
        return const Text('🌬️', style: TextStyle(fontSize: 35));
      case '📊':
        return const Text('📊', style: TextStyle(fontSize: 35));
      default:
        return Icon(
          Icons.star,
          size: 35,
          color: Colors.white.withOpacity(0.8),
        );
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.blue;
      case 'rare':
        return Colors.purple;
      case 'epic':
        return Colors.orange;
      case 'legendary':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
