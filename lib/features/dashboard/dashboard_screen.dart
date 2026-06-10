import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindfulness_garden/core/widgets/breathing_visualizer.dart';
import 'package:mindfulness_garden/core/widgets/enhanced_garden_widget.dart';
import 'package:mindfulness_garden/data/models/mood_model.dart';
import 'package:mindfulness_garden/data/models/session_model.dart';
import 'package:mindfulness_garden/presentation/providers/mood_provider.dart';
import 'package:mindfulness_garden/presentation/providers/session_provider.dart';
import 'package:mindfulness_garden/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadUser();
      context.read<SessionProvider>().loadSessions();
      context.read<MoodProvider>().loadTodayMood();
      context.read<MoodProvider>().loadRecentMoods();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final user = userProvider.user;
    final sessions = sessionProvider.sessions;
    final mood = moodProvider.todayMood;
    final event = _seasonalEvent();
    final plan = _buildPlan(userProvider, sessionProvider, moodProvider);
    final message = _buildCompanionMessage(userProvider, sessions, mood);
    final rewards = _buildRewards(userProvider);
    final leaderboard = _buildLeaderboard(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F1E7), Color(0xFFF4F6F0), Color(0xFFE8F3EC)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _icon(Icons.arrow_back_rounded,
                              () => context.go('/main')),
                          const Spacer(),
                          if (user?.email == null ||
                              user?.email.isEmpty == true)
                            IconButton(
                              icon: const Icon(Icons.login_rounded,
                                  color: Colors.white),
                              onPressed: () => context.go('/auth'),
                            ),
                          _icon(Icons.calendar_month_rounded,
                              () => context.go('/progress')),
                          const SizedBox(width: 10),
                          _icon(Icons.notifications_none_rounded, () {}),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                              0,
                              -6 *
                                  Curves.easeInOut
                                      .transform(_controller.value)),
                          child: child,
                        ),
                        child: _hero(
                          context,
                          user?.name.isNotEmpty == true
                              ? user!.name
                              : 'Mindful Gardener',
                          user?.currentStreak ?? 0,
                          event,
                          message,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: _stat(
                                  'Minutes',
                                  '${user?.totalMinutes ?? 0}',
                                  Icons.timelapse_rounded,
                                  const Color(0xFF3A8E7C))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _stat(
                                  'Sessions',
                                  '${user?.totalSessions ?? sessions.length}',
                                  Icons.self_improvement_rounded,
                                  const Color(0xFFC98B42))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _stat(
                                  'Garden',
                                  'Lv ${user?.gardenLevel ?? 1}',
                                  Icons.park_rounded,
                                  const Color(0xFF7A8AD8),
                                  footer:
                                      '${user?.achievementCount ?? 0} charms')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _banner(context, event),
                      const SizedBox(height: 24),
                      _section('Today Plan',
                          'A personalized rhythm for your next calm win.'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: plan.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) =>
                              _planCard(context, plan[index]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _section('Companion Insight',
                          'A calmer, more personal guide through your day.'),
                      const SizedBox(height: 12),
                      _companionCard(message, mood),
                      const SizedBox(height: 24),
                      _section('Living Garden',
                          'Your streaks and sessions now shape a richer world.'),
                      const SizedBox(height: 12),
                      _gardenCard(context, user?.gardenLevel ?? 1,
                          user?.currentStreak ?? 0, sessions.length),
                      const SizedBox(height: 24),
                      _section('Breathing Studio',
                          'Fast entry into a guided reset with visual rhythm.'),
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _cardIntro(
                                'Use motion-led guidance for a quick nervous-system reset before you dive back into the day.',
                                'Open',
                                () => context.go('/breathing')),
                            const SizedBox(height: 14),
                            const BreathingVisualizer(size: 210),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _section('Momentum Circle',
                          'Share progress, see friendly competition, stay consistent.'),
                      const SizedBox(height: 12),
                      _socialCard(context, leaderboard,
                          user?.currentStreak ?? 0, user?.totalMinutes ?? 0),
                      const SizedBox(height: 24),
                      _section('Reward Vault',
                          'Collectible progress makes the calm loop more exciting.'),
                      const SizedBox(height: 12),
                      _card(
                          child: Column(
                              children: rewards.map(_rewardTile).toList())),
                      const SizedBox(height: 24),
                      _section('Quick Actions',
                          'Jump straight into what feels good right now.'),
                      const SizedBox(height: 12),
                      _quickActions(context),
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

  Widget _hero(BuildContext context, String name, int streak, _Seasonal event,
      String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF113C34), Color(0xFF1B5C51), Color(0xFF6FAF8B)],
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x26113C34), blurRadius: 28, offset: Offset(0, 16))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Today, $name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w800, height: 1.1)),
        const SizedBox(height: 10),
        Text(message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.82), height: 1.45)),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _pill(Icons.local_fire_department_rounded, '$streak day streak'),
          _pill(event.icon, event.shortLabel)
        ]),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(
            child: FilledButton(
              onPressed: () => context.go('/meditation'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF6C66B),
                foregroundColor: const Color(0xFF1D2D26),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Start Today Plan'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => context.go('/garden'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.28)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Open Garden'),
          ),
        ]),
      ]),
    );
  }

  Widget _banner(BuildContext context, _Seasonal event) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(colors: [event.start, event.end])),
        child: Row(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(event.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(event.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.88), height: 1.4)),
            ]),
          ),
        ]),
      );

  Widget _companionCard(String message, MoodModel? mood) {
    final moodLabel = mood?.mood.isNotEmpty == true ? mood!.mood : 'Unlogged';
    final rating = mood?.rating ?? 0;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFD9EFE7)),
            child: const Icon(Icons.favorite_outline_rounded,
                color: Color(0xFF236957)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: Color(0xFF183028)))),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _tag(Icons.mood_rounded, 'Mood: $moodLabel'),
          _tag(
              Icons.star_outline_rounded,
              rating > 0
                  ? 'Energy ${rating.toStringAsFixed(1)}/5'
                  : 'Rate today'),
          _tag(Icons.auto_awesome_rounded, 'AI companion active'),
        ]),
      ]),
    );
  }

  Widget _gardenCard(
          BuildContext context, int level, int streak, int sessions) =>
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardIntro(
              'Your garden grows faster with consistent care, quests, and mindfulness sessions.',
              'Play',
              () => context.go('/garden')),
          const SizedBox(height: 14),
          ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: EnhancedGardenWidget(
                  level: level, streak: streak, size: 240)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _mini('Garden Power', '${min(100, 30 + (level * 8))}%',
                    const Color(0xFF2D7A61))),
            const SizedBox(width: 10),
            Expanded(
                child: _mini('Session Fuel', '$sessions boosts',
                    const Color(0xFFB97D3D))),
          ]),
        ]),
      );

  Widget _socialCard(
          BuildContext context, List<_Board> board, int streak, int minutes) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
              colors: [Color(0xFFE7EEF9), Color(0xFFF4EFE7)]),
          border: Border.all(color: const Color(0xFFDCE3EF)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('Weekly calm league',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2430)))),
            OutlinedButton.icon(
                onPressed: () => _shareProgress(streak, minutes),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Share')),
          ]),
          const SizedBox(height: 14),
          ...board.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _boardTile(entry))),
          const SizedBox(height: 6),
          Text(
              'Friendly ranking helps retention without making the app feel stressful.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF4A5563))),
        ]),
      );

  Widget _quickActions(BuildContext context) {
    final actions = [
      _Action('Meditate', Icons.spa_rounded, const Color(0xFF2C7A65),
          '/meditation'),
      _Action('Garden', Icons.yard_rounded, const Color(0xFFB9843A), '/garden'),
      _Action(
          'Mood', Icons.mood_rounded, const Color(0xFF6C76D8), '/mood-tracker'),
      _Action('Progress', Icons.insights_rounded, const Color(0xFF2D4E74),
          '/progress'),
    ];
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => context.go(action.route),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFDFE8DB))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: action.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(action.icon, color: action.color),
              ),
              const Spacer(),
              Text(action.label,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E332B))),
              const SizedBox(height: 4),
              Text('Tap to enter',
                  style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF1E332B).withOpacity(0.62))),
            ]),
          ),
        );
      },
    );
  }

  Widget _planCard(BuildContext context, _Plan item) => InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => context.go(item.route),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                colors: [item.color, item.color.withOpacity(0.72)]),
            boxShadow: [
              BoxShadow(
                  color: item.color.withOpacity(0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 12))
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(item.icon, color: Colors.white, size: 28)),
            const Spacer(),
            Text(item.metric,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(item.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(item.subtitle,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.4)),
          ]),
        ),
      );

  Widget _rewardTile(_Reward reward) {
    final percent = (reward.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: reward.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: reward.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(reward.icon, color: reward.color)),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reward.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF183028))),
              const SizedBox(height: 4),
              Text(reward.subtitle,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: Color(0xFF4D6259))),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                    value: reward.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(reward.color)),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Text('$percent%',
              style:
                  TextStyle(color: reward.color, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }

  Widget _boardTile(_Board entry) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: entry.emphasized
              ? entry.color.withOpacity(0.12)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: entry.emphasized
                  ? entry.color.withOpacity(0.32)
                  : const Color(0xFFDDE4EE)),
        ),
        child: Row(children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.bolt_rounded, color: entry.color)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Color(0xFF1F2D38))),
              const SizedBox(height: 3),
              Text(entry.highlight,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF5B6876))),
            ]),
          ),
          Text(entry.score,
              style:
                  TextStyle(color: entry.color, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _section(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17342B))),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: Color(0xFF50635A))),
        ],
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDFE8DB))),
        child: child,
      );

  Widget _cardIntro(String text, String cta, VoidCallback onTap) => Row(
        children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 15, height: 1.45, color: Color(0xFF355047)))),
          const SizedBox(width: 12),
          FilledButton.tonal(onPressed: onTap, child: Text(cta)),
        ],
      );

  Widget _icon(IconData icon, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.74),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDDE7DB))),
          child: Icon(icon, color: const Color(0xFF234136)),
        ),
      );

  Widget _pill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700))
        ]),
      );

  Widget _tag(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F4EC),
            borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: const Color(0xFF34564B)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF34564B)))
        ]),
      );

  Widget _stat(String title, String value, IconData icon, Color color,
          {String? footer}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDFE8DB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color)),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17342B))),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5D7067))),
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(footer,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w700))
          ],
        ]),
      );

  Widget _mini(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF50635A), fontSize: 13)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800))
        ]),
      );

  List<_Plan> _buildPlan(UserProvider userProvider,
      SessionProvider sessionProvider, MoodProvider moodProvider) {
    final streak = userProvider.currentStreak;
    final totalMinutes = userProvider.totalMinutes;
    final mood = moodProvider.todayMood?.mood.toLowerCase() ?? '';
    final recent = sessionProvider.sessions.isNotEmpty
        ? sessionProvider.sessions.first.meditationType
        : 'Mindful reset';
    return [
      _Plan(
          mood.contains('stress') || mood.contains('anx')
              ? 'Reset stress in 5 minutes'
              : 'Keep your calm momentum',
          'Recommended from your recent rhythm: $recent',
          '${max(5, 8 - min(streak, 3))} min session',
          const Color(0xFF2E7D69),
          Icons.spa_rounded,
          '/meditation'),
      _Plan(
          streak > 2
              ? 'Boost your garden combo'
              : 'Start your first garden quest',
          'Plant, water, and trigger reward momentum.',
          'Lv ${userProvider.gardenLevel} garden',
          const Color(0xFFB57A37),
          Icons.yard_rounded,
          '/garden'),
      _Plan(
          totalMinutes > 60
              ? 'Track your recovery mood'
              : 'Log how today feels',
          'Mood data sharpens your companion suggestions.',
          moodProvider.todayMood == null ? 'Not logged yet' : 'Mood ready',
          const Color(0xFF6975D9),
          Icons.mood_rounded,
          '/mood-tracker'),
    ];
  }

  String _buildCompanionMessage(
      UserProvider userProvider, List<SessionModel> sessions, MoodModel? mood) {
    if (mood != null && mood.mood.toLowerCase().contains('stress')) {
      return 'Your mood check-in suggests some pressure today, so I lined up a gentler reset and a lighter garden task.';
    }
    if (userProvider.currentStreak >= 7) {
      return 'Your consistency is excellent right now. Keep the streak warm with one short meditation and a quick bloom cycle.';
    }
    if (sessions.isEmpty) {
      return 'You are one session away from bringing the whole garden to life. Start small and let the app build momentum around you.';
    }
    return 'You already have progress on the board today. A short mindful round now is enough to keep growth, rewards, and calm moving forward.';
  }

  _Seasonal _seasonalEvent() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      return const _Seasonal(
          'Spring Bloom Event',
          'Limited-time blossom rewards, softer visuals, and extra growth energy for garden sessions.',
          'Spring live',
          Icons.local_florist_rounded,
          Color(0xFFDE8FA4),
          Color(0xFFF1B870));
    }
    if (month >= 6 && month <= 8) {
      return const _Seasonal(
          'Summer Flow Event',
          'Sunlit challenges, warmer breathing scenes, and higher combo gains on mindful care actions.',
          'Summer flow',
          Icons.wb_sunny_rounded,
          Color(0xFF3D8C97),
          Color(0xFFF0B35C));
    }
    if (month >= 9 && month <= 11) {
      return const _Seasonal(
          'Harvest Calm Event',
          'Seasonal quests reward rare seeds, cozy ambience, and stronger progression bursts.',
          'Harvest live',
          Icons.park_rounded,
          Color(0xFF7B5A43),
          Color(0xFFD89558));
    }
    return const _Seasonal(
        'Winter Glow Event',
        'Gentle night palettes, focus rituals, and bonus calm points for consistent check-ins.',
        'Winter glow',
        Icons.ac_unit_rounded,
        Color(0xFF4B698A),
        Color(0xFF85AABF));
  }

  List<_Reward> _buildRewards(UserProvider userProvider) => [
        _Reward(
            'Moonleaf Seed Pack',
            userProvider.currentStreak >= 3
                ? 'Unlocked from your active streak momentum.'
                : 'Reach a 3-day streak to unlock this seasonal seed pack.',
            (userProvider.currentStreak / 3).clamp(0, 1).toDouble(),
            Icons.eco_rounded,
            const Color(0xFF2F7C67)),
        _Reward(
            'Golden Watering Can',
            userProvider.totalSessions >= 10
                ? 'Unlocked by steady mindfulness sessions.'
                : 'Complete 10 total sessions to earn this prestige care tool.',
            (userProvider.totalSessions / 10).clamp(0, 1).toDouble(),
            Icons.water_drop_rounded,
            const Color(0xFFC18A3F)),
        _Reward(
            'Aurora Companion Skin',
            userProvider.gardenLevel >= 5
                ? 'Unlocked for growing a stronger sanctuary.'
                : 'Reach garden level 5 to give your guide a premium look.',
            (userProvider.gardenLevel / 5).clamp(0, 1).toDouble(),
            Icons.auto_awesome_rounded,
            const Color(0xFF727CE0)),
      ];

  List<_Board> _buildLeaderboard(UserProvider userProvider) => [
        const _Board('Ava', '184 calm pts', 'Bloom streak', Color(0xFF5B76D8)),
        _Board(
            'You',
            '${userProvider.totalMinutes + (userProvider.currentStreak * 12)} calm pts',
            '${userProvider.currentStreak} day streak',
            const Color(0xFF2C7A65),
            emphasized: true),
        const _Board('Noah', '126 calm pts', 'Night resets', Color(0xFFC88842)),
      ];

  Future<void> _shareProgress(int streak, int minutes) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'I am building calm in Mindfulness Garden with a $streak day streak and $minutes mindful minutes.',
      ),
    );
  }
}

class _Plan {
  const _Plan(this.title, this.subtitle, this.metric, this.color, this.icon,
      this.route);
  final String title;
  final String subtitle;
  final String metric;
  final Color color;
  final IconData icon;
  final String route;
}

class _Seasonal {
  const _Seasonal(this.title, this.description, this.shortLabel, this.icon,
      this.start, this.end);
  final String title;
  final String description;
  final String shortLabel;
  final IconData icon;
  final Color start;
  final Color end;
}

class _Reward {
  const _Reward(
      this.title, this.subtitle, this.progress, this.icon, this.color);
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color color;
}

class _Board {
  const _Board(this.name, this.score, this.highlight, this.color,
      {this.emphasized = false});
  final String name;
  final String score;
  final String highlight;
  final Color color;
  final bool emphasized;
}

class _Action {
  const _Action(this.label, this.icon, this.color, this.route);
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}
