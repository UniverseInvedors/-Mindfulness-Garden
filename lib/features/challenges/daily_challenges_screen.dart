import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DailyChallengesScreen — daily mindfulness challenge hub
// ─────────────────────────────────────────────────────────────────────────────

class DailyChallengesScreen extends StatelessWidget {
  const DailyChallengesScreen({super.key});

  static const _challenges = [
    _Challenge('Morning Calm', 'Complete a 5-min guided meditation',
        Icons.wb_twilight_rounded, Color(0xFF9d4edd), 5),
    _Challenge('Breath Reset', 'Finish one full Box Breathing cycle',
        Icons.air_rounded, Color(0xFF00b4d8), 3),
    _Challenge('Garden Bloom', 'Water 3 plants in your garden',
        Icons.spa_rounded, Color(0xFF38b000), 2),
    _Challenge('Mood Log', 'Log your mood with an energy rating',
        Icons.mood_rounded, Color(0xFFf72585), 1),
    _Challenge('Yoga Flow', 'Complete a 10-min yoga session with Zeno',
        Icons.self_improvement_rounded, Color(0xFFe9c46a), 10),
    _Challenge('Night Wind-Down', 'Do a 4-7-8 breathing session before bed',
        Icons.nightlight_round, Color(0xFF3a86ff), 4),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              colors.primary.withOpacity(0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _iconBtn(
                          context,
                          Icons.arrow_back_rounded,
                          () => context.canPop()
                              ? context.pop()
                              : context.go('/main')),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily Challenges',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            Text('Complete all 6 to earn bonus garden seeds',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      // Streak badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text('3',
                                style: TextStyle(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Progress summary ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                  child: _ProgressBar(completed: 2, total: _challenges.length),
                ),
              ),

              // ── Challenge list ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ChallengeCard(
                          challenge: _challenges[i], isCompleted: i < 2),
                    ),
                    childCount: _challenges.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.completed, required this.total});
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = completed / total;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Progress",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Text('$completed / $total',
                  style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            completed == total
                ? '🎉 All done! Seeds unlocked.'
                : '${total - completed} challenges remaining — keep going!',
            style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 12,
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.isCompleted});
  final _Challenge challenge;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isCompleted ? 0.65 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.white.withOpacity(0.05)
              : challenge.color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? Colors.white.withOpacity(0.10)
                : challenge.color.withOpacity(0.40),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: challenge.color.withOpacity(0.20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(challenge.icon, color: challenge.color, size: 26),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(challenge.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 12,
                          height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 13, color: challenge.color.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text('${challenge.durationMin} min',
                          style: TextStyle(
                              color: challenge.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Completion check
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.25)
                    : Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? Colors.green
                      : Colors.white.withOpacity(0.25),
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.green, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Challenge {
  const _Challenge(
      this.title, this.description, this.icon, this.color, this.durationMin);
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int durationMin;
}
