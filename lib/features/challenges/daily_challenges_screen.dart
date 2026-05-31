import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mindfulness_garden/presentation/providers/challenge_provider.dart';
import 'package:mindfulness_garden/data/models/challenge_model.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class _ZenoOpponent {
  final int streak;
  final int points;
  final int sessionsToday;
  final int plantsGrown;
  final String status;
  const _ZenoOpponent({required this.streak, required this.points,
      required this.sessionsToday, required this.plantsGrown, required this.status});
}

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});
  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userSessions = 0;
  int _userStreak = 0;
  int _userPlants = 0;

  static const _ZenoOpponent _zeno = _ZenoOpponent(
    streak: 5, points: 420, sessionsToday: 2, plantsGrown: 4,
    status: 'Neural breathing protocol active',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userStreak = LocalStorageService.getCurrentStreak();
    _userSessions = LocalStorageService.getSessionsByDate(DateTime.now()).length;
    final plants = LocalStorageService.getSetting('garden_plants_grown');
    _userPlants = plants is int ? plants : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().loadChallenges();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050510),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: const Text('MISSION CONTROL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 15)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x33FFD700),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x66FFD700)),
            ),
            child: Row(children: [
              const Icon(Icons.hexagon_outlined, color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 4),
              Text('${provider.points}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF9d4edd),
          indicatorWeight: 2,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0x66FFFFFF),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 11),
          tabs: const [Tab(text: 'DAILY OPS'), Tab(text: 'EPIC QUESTS'), Tab(text: 'NEURAL COMBAT')],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('⬡', style: TextStyle(fontSize: 40, color: Color(0xFF9d4edd))),
              SizedBox(height: 12),
              CircularProgressIndicator(color: Color(0xFF9d4edd)),
              SizedBox(height: 12),
              Text('LOADING MISSIONS...', style: TextStyle(color: Color(0x809d4edd), fontSize: 11, letterSpacing: 2)),
            ]))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(provider),
                _buildWeeklyTab(provider),
                _buildVsZenoTab(provider),
              ],
            ),
    );
  }

  Widget _buildDailyTab(ChallengeProvider provider) {
    final today = provider.todayChallenge;
    final daily = provider.challenges
        .where((c) => c.type == ChallengeType.daily && (today == null || c.id != today.id))
        .toList();
    final completedCount = provider.challenges.where((c) => c.isCompleted).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _buildMissionBriefing(completedCount),
      const SizedBox(height: 16),
      if (today != null) ...[
        _sectionLabel('PRIORITY MISSION'),
        const SizedBox(height: 10),
        _buildTodayCard(today, provider),
        const SizedBox(height: 20),
      ],
      _sectionLabel('ALL DAILY OPS'),
      const SizedBox(height: 10),
      if (daily.isEmpty) _emptyState('No daily ops available')
      else ...daily.map((c) => _buildChallengeCard(c, provider)),
    ]);
  }

  Widget _buildWeeklyTab(ChallengeProvider provider) {
    final weekly = provider.challenges.where((c) => c.type == ChallengeType.weekly).toList();
    final achievements = provider.challenges.where((c) => c.type == ChallengeType.achievement).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionLabel('EPIC QUESTS'),
      const SizedBox(height: 10),
      if (weekly.isEmpty) _emptyState('No epic quests available')
      else ...weekly.map((c) => _buildChallengeCard(c, provider)),
      const SizedBox(height: 20),
      _sectionLabel('ACHIEVEMENTS'),
      const SizedBox(height: 10),
      if (achievements.isEmpty) _emptyState('Complete missions to unlock achievements')
      else ...achievements.map((c) => _buildChallengeCard(c, provider)),
    ]);
  }

  Widget _buildVsZenoTab(ChallengeProvider provider) {
    final battles = provider.challenges.where((c) => c.type == ChallengeType.social).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _buildZenoCard(),
      const SizedBox(height: 20),
      _buildHeadToHead(),
      const SizedBox(height: 20),
      _sectionLabel('NEURAL COMBAT MISSIONS'),
      const SizedBox(height: 10),
      if (battles.isEmpty) _emptyState('No combat missions available')
      else ...battles.map((c) => _buildBattleCard(c, provider)),
    ]);
  }

  Widget _emptyState(String msg) => Container(
    padding: const EdgeInsets.all(24),
    alignment: Alignment.center,
    child: Text(msg, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 14), textAlign: TextAlign.center),
  );

  Widget _buildMissionBriefing(int completedCount) {
    final streakCapped = _userStreak.clamp(0, 7);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF0a1628)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.fromBorderSide(BorderSide(color: Color(0x669d4edd))),
        boxShadow: [BoxShadow(color: Color(0x339d4edd), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_userStreak-DAY STREAK',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('$completedCount missions completed', style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: streakCapped / 7,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9d4edd)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(7 - streakCapped).clamp(0, 7)} more days to unlock weekly reward',
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11)),
        ])),
      ]),
    );
  }

  Widget _buildTodayCard(Challenge challenge, ChallengeProvider provider) {
    final done = challenge.isCompleted;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: done ? const [Color(0xFF1a3a1a), Color(0xFF0d2b0d)] : const [Color(0xFF001a2e), Color(0xFF003366)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: done ? const Color(0xFF38b000) : const Color(0xFF00b4d8)),
        boxShadow: [BoxShadow(color: done ? const Color(0x3338b000) : const Color(0x3300b4d8), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(done ? Icons.check_circle : Icons.radar, color: done ? const Color(0xFF38b000) : const Color(0xFF00b4d8)),
          const SizedBox(width: 8),
          Text(done ? 'MISSION COMPLETE ✓' : 'PRIORITY MISSION',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 11)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(color: Color(0x33FFFFFF), borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Text('+${challenge.reward} ⬡', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(challenge.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 6),
        Text(challenge.description, style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => _navigate(challenge),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x99FFFFFF)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('DEPLOY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: done ? null : () async {
              await provider.completeChallenge(challenge.id);
              setState(() => _userSessions++);
              if (mounted) _showMissionComplete(challenge);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
              disabledBackgroundColor: const Color(0x4D38b000),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(done ? 'DONE ✓' : 'MARK DONE',
                style: TextStyle(fontWeight: FontWeight.w700, color: done ? const Color(0xFF38b000) : Colors.white, letterSpacing: 0.5)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, ChallengeProvider provider) {
    final color = _typeColor(challenge.type);
    final done = challenge.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? const Color(0x8038b000) : const Color(0x339d4edd)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigate(challenge),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_typeIcon(challenge.type), color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(challenge.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                if (done)
                  const Icon(Icons.check_circle, color: Color(0xFF38b000), size: 20)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Color.fromARGB(38, color.red, color.green, color.blue), borderRadius: BorderRadius.circular(10)),
                    child: Text('+${challenge.reward} ⬡', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 6),
              Text(challenge.description, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13)),
              if (challenge.progress > 0 && !done) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      backgroundColor: const Color(0x1AFFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 5,
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text('${(challenge.progress * 100).toInt()}%',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ],
              if (!done) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => _navigate(challenge),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color.fromARGB(128, color.red, color.green, color.blue)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('DEPLOY', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      await provider.completeChallenge(challenge.id);
                      if (mounted) _showMissionComplete(challenge);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(204, color.red, color.green, color.blue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('MARK DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  )),
                ]),
              ] else ...[
                const SizedBox(height: 8),
                const Row(children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF38b000), size: 14),
                  SizedBox(width: 4),
                  Text('Mission Complete', style: TextStyle(color: Color(0xCC38b000), fontSize: 12)),
                ]),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildZenoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF0a0a1a)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF9d4edd))),
        boxShadow: [BoxShadow(color: Color(0x339d4edd), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 60, height: 60,
            decoration: const BoxDecoration(color: Color(0x339d4edd), shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Color(0xFF9d4edd)))),
            child: const Center(child: Text('⬡', style: TextStyle(fontSize: 28, color: Color(0xFF9d4edd)))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ZENO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
            const Text('Neural AI Opponent · Future Entity', style: TextStyle(color: Color(0xB39d4edd), fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: const BoxDecoration(color: Color(0x1A9d4edd), borderRadius: BorderRadius.all(Radius.circular(10)), border: Border.fromBorderSide(BorderSide(color: Color(0x339d4edd)))),
              child: Text(_zeno.status, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11)),
            ),
          ])),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _statChip('🔥 ${_zeno.streak}', 'STREAK'),
          _statChip('⬡ ${_zeno.points}', 'POINTS'),
          _statChip('🧘 ${_zeno.sessionsToday}', 'TODAY'),
          _statChip('🌱 ${_zeno.plantsGrown}', 'PLANTS'),
        ]),
      ]),
    );
  }

  Widget _statChip(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Color(0x809d4edd), fontSize: 10, letterSpacing: 1)),
  ]);

  Widget _buildHeadToHead() {
    final stats = [
      {'label': 'Sessions Today', 'you': _userSessions, 'zeno': _zeno.sessionsToday},
      {'label': 'Day Streak', 'you': _userStreak, 'zeno': _zeno.streak},
      {'label': 'Plants Grown', 'you': _userPlants, 'zeno': _zeno.plantsGrown},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1F),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.fromBorderSide(BorderSide(color: Color(0x339d4edd))),
      ),
      child: Column(children: [
        const Text('NEURAL COMBAT · HEAD TO HEAD',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: Center(child: Text('YOU', style: TextStyle(color: Color(0xFF00b4d8), fontWeight: FontWeight.w700, letterSpacing: 1)))),
          SizedBox(width: 60),
          Expanded(child: Center(child: Text('ZENO', style: TextStyle(color: Color(0xFF9d4edd), fontWeight: FontWeight.w700, letterSpacing: 1)))),
        ]),
        const SizedBox(height: 12),
        ...stats.map((s) {
          final you = s['you'] as int;
          final zeno = s['zeno'] as int;
          final total = (you + zeno).toDouble();
          final youRatio = total == 0 ? 0.5 : you / total;
          final winning = you >= zeno;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Text(s['label'] as String, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Row(children: [
                Text('$you', style: TextStyle(color: winning ? const Color(0xFF38b000) : Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 8, color: const Color(0x669d4edd)),
                    FractionallySizedBox(widthFactor: youRatio, child: Container(height: 8,
                        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00b4d8), Color(0xFF0077b6)])))),
                  ]),
                )),
                const SizedBox(width: 8),
                Text('$zeno', style: TextStyle(color: !winning ? const Color(0xFF38b000) : Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildBattleCard(Challenge challenge, ChallengeProvider provider) {
    final winning = _isBattleWinning(challenge.id);
    final done = challenge.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? const Color(0x8038b000) : const Color(0x669d4edd)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigate(challenge),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(challenge.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: winning ? const Color(0x2638b000) : const Color(0x26FF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: winning ? const Color(0x6638b000) : const Color(0x66FF4444)),
                  ),
                  child: Text(winning ? '🏆 WINNING' : '⚠ LOSING',
                      style: TextStyle(color: winning ? const Color(0xFF38b000) : const Color(0xFFFF4444), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(challenge.description, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _navigate(challenge),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x809d4edd)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('DEPLOY', style: TextStyle(color: Color(0xFF9d4edd), fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  onPressed: done ? null : () async {
                    await provider.completeChallenge(challenge.id);
                    setState(() => _userSessions++);
                    if (mounted) _showBattleResult(challenge, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9d4edd),
                    disabledBackgroundColor: const Color(0xFF38b000),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(done ? 'DEFEATED ✓' : 'BEAT ZENO (+${challenge.reward} ⬡)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  bool _isBattleWinning(String id) {
    switch (id) {
      case 'ai1': return _userSessions > _zeno.sessionsToday;
      case 'ai2': return _userStreak > _zeno.streak;
      case 'ai3': return _userPlants > _zeno.plantsGrown;
      default: return false;
    }
  }

  void _navigate(Challenge challenge) {
    switch (challenge.id) {
      case 'd1': case 'd3': case 'a3': case 'ai2': context.push('/guided-meditation'); break;
      case 'd2': case 'd4': case 'w2': case 'a1': case 'ai1': context.push('/breathing'); break;
      case 'w1': case 'w4': context.push('/mood-tracker'); break;
      case 'w3': case 'a2': case 'ai3': context.push('/garden'); break;
      default:
        switch (challenge.type) {
          case ChallengeType.garden: context.push('/garden'); break;
          case ChallengeType.daily: case ChallengeType.meditation: context.push('/guided-meditation'); break;
          default: context.push('/breathing'); break;
        }
    }
  }

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(color: Color(0xFF00b4d8), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 2));

  Color _typeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily: return const Color(0xFF00b4d8);
      case ChallengeType.weekly: return const Color(0xFF9d4edd);
      case ChallengeType.achievement: return const Color(0xFFFFD700);
      case ChallengeType.garden: return const Color(0xFF38b000);
      case ChallengeType.meditation: return const Color(0xFFf72585);
      case ChallengeType.social: return const Color(0xFFFF6B35);
    }
  }

  IconData _typeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily: return Icons.radar;
      case ChallengeType.weekly: return Icons.public;
      case ChallengeType.achievement: return Icons.emoji_events;
      case ChallengeType.garden: return Icons.park;
      case ChallengeType.meditation: return Icons.self_improvement;
      case ChallengeType.social: return Icons.bolt;
    }
  }

  void _showMissionComplete(Challenge challenge) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0D0D1F),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D1F),
            borderRadius: BorderRadius.all(Radius.circular(25)),
            border: Border.fromBorderSide(BorderSide(color: Color(0xFF9d4edd))),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('MISSION COMPLETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('+${challenge.reward} CREDITS EARNED',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFFD700), letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(challenge.title, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('Neural pathways reinforced.', style: TextStyle(color: Color(0x809d4edd), fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ACKNOWLEDGED', style: TextStyle(color: Color(0xFF00b4d8), fontWeight: FontWeight.w700, letterSpacing: 1)),
            )),
          ]),
        ),
      ),
    );
  }

  void _showBattleResult(Challenge challenge, bool won) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0D0D1F),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1F),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            border: Border.all(color: won ? const Color(0xFF38b000) : const Color(0xFF9d4edd)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(won ? 'ZENO DEFEATED 🏆' : 'ZENO WINS THIS ROUND',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(won ? '🎉' : '⚡', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(won ? '+${challenge.reward} CREDITS!' : 'CONTINUE TRAINING',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: won ? const Color(0xFFFFD700) : const Color(0xB3FFFFFF), letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(won
                ? 'ZENO: "Well executed, operative. I will recalibrate."'
                : 'ZENO: "Your neural patterns are improving. Keep training."',
                style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ACKNOWLEDGED', style: TextStyle(color: Color(0xFF9d4edd), fontWeight: FontWeight.w700, letterSpacing: 1)),
            )),
          ]),
        ),
      ),
    );
  }
}
