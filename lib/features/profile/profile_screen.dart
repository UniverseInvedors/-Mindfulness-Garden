import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mindfulness_garden/presentation/providers/user_provider.dart';
import 'package:mindfulness_garden/presentation/providers/auth_provider.dart';
import 'package:mindfulness_garden/presentation/providers/app_provider.dart';
import 'package:mindfulness_garden/core/services/voice_service.dart';
import 'package:mindfulness_garden/core/services/localization_service.dart';
import 'package:mindfulness_garden/core/services/ai_service.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _aiService = AiService();
  late TabController _tabCtrl;

  String _avatar = '🧘';
  String _age = '', _goal = '';
  final List<String> _conditions = [];
  bool _saving = false;
  bool _notificationsOn = true;
  bool _soundsOn = true;
  String _reminderTime = '08:00';

  static const _avatars = [
    '🧘',
    '🌿',
    '🌸',
    '🌻',
    '🦋',
    '🌙',
    '⭐',
    '🌊',
    '🍃',
    '🌺',
    '🔥',
    '💎',
    '🦁',
    '🐉',
    '🌈'
  ];
  static const _ages = ['Under 18', '18–25', '26–35', '36–45', '46–55', '55+'];
  static const _goals = [
    'Reduce stress & anxiety',
    'Sleep better',
    'Improve focus & productivity',
    'Manage emotions',
    'Build daily mindfulness habit',
    'Recover from burnout',
    'General wellbeing',
  ];
  static const _healthConditions = [
    'Anxiety',
    'Depression',
    'Insomnia',
    'Chronic Stress',
    'High Blood Pressure',
    'Chronic Pain',
    'ADHD',
    'PTSD',
    'Burnout',
    'Grief',
    'Panic Attacks',
    'None of the above',
  ];
  static const _reminderTimes = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '12:00',
    '18:00',
    '20:00',
    '21:00',
    '22:00'
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  void _load() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name == 'Mindful Gardener' ? '' : user.name;
      _emailCtrl.text = user.email;
    }
    final av = LocalStorageService.getSetting('profile_avatar');
    if (av is String) _avatar = av;
    final bio = LocalStorageService.getSetting('profile_bio');
    if (bio is String) _bioCtrl.text = bio;
    final notif = LocalStorageService.getSetting('pref_notifications');
    if (notif is bool) _notificationsOn = notif;
    final sounds = LocalStorageService.getSetting('pref_sounds');
    if (sounds is bool) _soundsOn = sounds;
    final rt = LocalStorageService.getSetting('pref_reminder_time');
    if (rt is String) _reminderTime = rt;

    final h = _aiService.getHealthProfile();
    _age = h['age'] as String? ?? '';
    _goal = h['goal'] as String? ?? '';
    final c = h['conditions'];
    if (c is List) _conditions.addAll(List<String>.from(c));
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Please enter your name', Colors.red);
      return;
    }
    setState(() => _saving = true);
    await LocalStorageService.saveSetting('profile_avatar', _avatar);
    await LocalStorageService.saveSetting('profile_bio', _bioCtrl.text.trim());
    await LocalStorageService.saveSetting(
        'pref_notifications', _notificationsOn);
    await LocalStorageService.saveSetting('pref_sounds', _soundsOn);
    await LocalStorageService.saveSetting('pref_reminder_time', _reminderTime);
    await context.read<UserProvider>().updateName(name);
    final user = context.read<UserProvider>().user;
    if (user != null) {
      await context
          .read<UserProvider>()
          .updateUser(user.copyWith(email: _emailCtrl.text.trim()));
    }
    await _aiService.saveHealthProfile(
        age: _age, goal: _goal, conditions: _conditions);
    setState(() => _saving = false);
    _snack('Profile saved!', const Color(0xFF38b000));
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          Builder(builder: (ctx) {
            final user = ctx.watch<UserProvider>().user;
            if (user == null || user.email.isEmpty) {
              return TextButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Sign In',
                    style: TextStyle(color: Colors.white)),
              );
            }
            return const SizedBox.shrink();
          }),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF9d4edd)))
                : const Text('Save',
                    style: TextStyle(
                        color: Color(0xFF9d4edd),
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF9d4edd),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0x66FFFFFF),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: 'PROFILE'),
            Tab(text: 'HEALTH'),
            Tab(text: 'SETTINGS')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [_buildProfileTab(), _buildHealthTab(), _buildSettingsTab()],
      ),
    );
  }

  // ─── PROFILE TAB ──────────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    final user = context.watch<UserProvider>().user;
    final streak = LocalStorageService.getCurrentStreak();
    final sessions = LocalStorageService.getSessions();
    final totalMin = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final moods = LocalStorageService.getAllMoods();
    final plants = LocalStorageService.getSetting('garden_plants_grown') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar + name hero
        Center(
            child: Column(children: [
          Stack(children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x669d4edd), blurRadius: 24, spreadRadius: 4)
                ],
              ),
              child: Center(
                  child: Text(_avatar, style: const TextStyle(fontSize: 50))),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: Color(0xFF9d4edd), shape: BoxShape.circle),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                )),
          ]),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Mindful Gardener',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          if (_emailCtrl.text.isNotEmpty)
            Text(_emailCtrl.text,
                style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0x339d4edd),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Garden Level ${user?.gardenLevel ?? 1}',
                style: const TextStyle(
                    color: Color(0xFF9d4edd),
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ])),
        const SizedBox(height: 24),

        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _statCard('🔥', '$streak', 'Streak', const Color(0xFFf77f00)),
            _statCard('🧘', '${sessions.length}', 'Sessions',
                const Color(0xFF9d4edd)),
            _statCard('⏱', '$totalMin', 'Minutes', const Color(0xFF00b4d8)),
            _statCard(
                '😊', '${moods.length}', 'Mood Logs', const Color(0xFFf72585)),
            _statCard('🌱', '$plants', 'Plants', const Color(0xFF38b000)),
            _statCard('⭐', 'Lv.${user?.gardenLevel ?? 1}', 'Garden',
                const Color(0xFFFFD700)),
          ],
        ),
        const SizedBox(height: 24),

        // Personal info
        _label('PERSONAL INFO'),
        const SizedBox(height: 10),
        _field(_nameCtrl, 'Your Name', Icons.person_outline),
        const SizedBox(height: 10),
        _field(_emailCtrl, 'Email (optional)', Icons.email_outlined),
        const SizedBox(height: 10),
        _multiField(_bioCtrl, 'Bio — tell us about yourself (optional)',
            Icons.notes_outlined, 3),
        const SizedBox(height: 24),

        // Joined date
        if (user != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x1AFFFFFF))),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Color(0x80FFFFFF), size: 18),
              const SizedBox(width: 10),
              Text('Member since ${_fmtDate(user.joinedDate)}',
                  style:
                      const TextStyle(color: Color(0x80FFFFFF), fontSize: 13)),
            ]),
          ),
        const SizedBox(height: 24),

        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9d4edd),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(30, color.red, color.green, color.blue),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Color.fromARGB(60, color.red, color.green, color.blue)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Text(label,
            style: TextStyle(
                color: Color.fromARGB(153, color.red, color.green, color.blue),
                fontSize: 10)),
      ]),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Choose Avatar',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _avatars
                .map((a) => GestureDetector(
                      onTap: () {
                        setState(() => _avatar = a);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _avatar == a
                              ? const Color(0xFF9d4edd)
                              : const Color(0xFF0D0D1F),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _avatar == a
                                  ? const Color(0xFF9d4edd)
                                  : const Color(0x33FFFFFF)),
                          boxShadow: _avatar == a
                              ? const [
                                  BoxShadow(
                                      color: Color(0x669d4edd), blurRadius: 10)
                                ]
                              : null,
                        ),
                        child: Center(
                            child:
                                Text(a, style: const TextStyle(fontSize: 26))),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ─── HEALTH TAB ───────────────────────────────────────────────────────────

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Health summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF1a0533), Color(0xFF0a1628)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.fromBorderSide(BorderSide(color: Color(0x339d4edd))),
          ),
          child: Row(children: [
            const Text('🧬', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Health Matrix',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    _conditions.isEmpty ||
                            _conditions.contains('None of the above')
                        ? 'No conditions set — Zeno uses time-based recommendations'
                        : 'Zeno is calibrated for: ${_conditions.take(2).join(', ')}${_conditions.length > 2 ? ' +${_conditions.length - 2} more' : ''}',
                    style:
                        const TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
                  ),
                ])),
          ]),
        ),
        const SizedBox(height: 24),

        _label('AGE GROUP'),
        const SizedBox(height: 10),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ages
                .map((a) => _chip(a, _age == a, () => setState(() => _age = a)))
                .toList()),
        const SizedBox(height: 24),

        _label('PRIMARY GOAL'),
        const SizedBox(height: 10),
        ..._goals.map(
            (g) => _radioTile(g, _goal == g, () => setState(() => _goal = g))),
        const SizedBox(height: 24),

        _label('HEALTH CONDITIONS'),
        const SizedBox(height: 4),
        const Text(
            'Zeno uses this to personalise every exercise recommendation.',
            style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _healthConditions
                .map((c) => _chip(
                    c,
                    _conditions.contains(c),
                    () => setState(() {
                          if (c == 'None of the above') {
                            _conditions.clear();
                            _conditions.add(c);
                          } else {
                            _conditions.remove('None of the above');
                            _conditions.contains(c)
                                ? _conditions.remove(c)
                                : _conditions.add(c);
                          }
                        })))
                .toList()),
        const SizedBox(height: 24),

        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9d4edd),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Health Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  // ─── SETTINGS TAB ─────────────────────────────────────────────────────────

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('PREFERENCES'),
        const SizedBox(height: 12),

        _toggleTile(
            'Notifications',
            'Daily reminders & streaks',
            Icons.notifications_outlined,
            _notificationsOn,
            (v) => setState(() => _notificationsOn = v)),
        const SizedBox(height: 8),
        _toggleTile(
            'Sounds & Music',
            'Ambient sounds during sessions',
            Icons.music_note_outlined,
            _soundsOn,
            (v) => setState(() => _soundsOn = v)),
        const SizedBox(height: 24),

        _label('DAILY REMINDER TIME'),
        const SizedBox(height: 10),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reminderTimes
                .map((t) => _chip(t, _reminderTime == t,
                    () => setState(() => _reminderTime = t)))
                .toList()),
        const SizedBox(height: 24),
        // Guided voice language selector (only expose three voices)
        _label('GUIDED VOICE LANGUAGE'),
        const SizedBox(height: 10),
        Builder(builder: (ctx) {
          final appLang = ctx.watch<AppProvider>().appLanguage;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(
                AppLanguage.english.displayName,
                appLang == AppLanguage.english,
                () => ctx
                    .read<AppProvider>()
                    .setAppLanguage(AppLanguage.english)),
            _chip(
                AppLanguage.hindi.displayName,
                appLang == AppLanguage.hindi,
                () =>
                    ctx.read<AppProvider>().setAppLanguage(AppLanguage.hindi)),
            _chip(
                AppLanguage.bengali.displayName,
                appLang == AppLanguage.bengali,
                () => ctx
                    .read<AppProvider>()
                    .setAppLanguage(AppLanguage.bengali)),
          ]);
        }),
        const SizedBox(height: 20),
        _label('VOICE PERSONALITY'),
        const SizedBox(height: 10),
        Builder(builder: (ctx) {
          final current = ctx.watch<AppProvider>().voicePersonality;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(
                'Buddha',
                current == VoicePersonality.buddha,
                () => ctx
                    .read<AppProvider>()
                    .setVoicePersonality(VoicePersonality.buddha)),
            _chip(
                'Zeno',
                current == VoicePersonality.zeno,
                () => ctx
                    .read<AppProvider>()
                    .setVoicePersonality(VoicePersonality.zeno)),
            _chip(
                'Monk',
                current == VoicePersonality.monk,
                () => ctx
                    .read<AppProvider>()
                    .setVoicePersonality(VoicePersonality.monk)),
          ]);
        }),
        const SizedBox(height: 24),

        _label('ACCOUNT'),
        const SizedBox(height: 12),
        Builder(builder: (ctx) {
          final authProv = ctx.watch<AuthProvider>();
          if (authProv.isAuthenticated) {
            return Column(
              children: [
                _actionTile(
                  'Sign Out',
                  'Disconnect from your account',
                  Icons.logout_rounded,
                  Colors.orange,
                  () async {
                    await authProv.signOut();
                    if (mounted) {
                      context.go('/dashboard');
                      _snack('Signed out', Colors.orange);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        _actionTile(
            'Export My Data',
            'Download all your sessions & moods',
            Icons.download_outlined,
            const Color(0xFF00b4d8),
            () => _snack('Export coming soon', const Color(0xFF00b4d8))),
        const SizedBox(height: 8),
        _actionTile('Reset Progress', 'Clear all sessions and start fresh',
            Icons.refresh_outlined, Colors.orange, _confirmReset),
        const SizedBox(height: 8),
        _actionTile('Delete Account', 'Permanently remove all data',
            Icons.delete_outline, Colors.red, _confirmDelete),
        const SizedBox(height: 24),

        _label('ABOUT'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF))),
          child: Column(children: [
            _aboutRow('App', 'Mindfulness Garden'),
            _aboutRow('Version', '1.0.7'),
            _aboutRow('Package', 'com.mindfulgarden.mindfulness_garden'),
            Builder(builder: (ctx) {
              final p = ctx.watch<AppProvider>().voicePersonality;
              final name = p.name.toUpperCase();
              return _aboutRow('AI Coach', '$name Neural Interface');
            }),
          ]),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _toggleTile(String title, String sub, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1AFFFFFF))),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF9d4edd), size: 22),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          Text(sub,
              style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
        ])),
        Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF9d4edd)),
      ]),
    );
  }

  Widget _actionTile(String title, String sub, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF))),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(sub,
                    style: const TextStyle(
                        color: Color(0x66FFFFFF), fontSize: 12)),
              ])),
          Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
        ]),
      ),
    );
  }

  Widget _aboutRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(k,
              style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 13)),
          const Spacer(),
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      );

  void _confirmReset() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: const Color(0xFF1a1a2e),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Reset Progress?',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text(
                        'This will clear all sessions, moods and streaks. Cannot be undone.',
                        style:
                            TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0x33FFFFFF))),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.white)))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _snack('Reset coming soon', Colors.orange);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              child: const Text('Reset',
                                  style: TextStyle(color: Colors.white)))),
                    ]),
                  ])),
            ));
  }

  void _confirmDelete() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: const Color(0xFF1a1a2e),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Delete Account?',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text(
                        'All data will be permanently deleted. This cannot be undone.',
                        style:
                            TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0x33FFFFFF))),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.white)))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _snack('Delete coming soon', Colors.red);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.white)))),
                    ]),
                  ])),
            ));
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF00b4d8),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.5));

  Widget _field(TextEditingController ctrl, String hint, IconData icon) {
    return Theme(
      data: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false)),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF))),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 15),
            prefixIcon: Icon(icon, color: const Color(0x66FFFFFF), size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _multiField(
      TextEditingController ctrl, String hint, IconData icon, int lines) {
    return Theme(
      data: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false)),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF))),
        child: TextField(
          controller: ctrl,
          maxLines: lines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 14),
            prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(icon, color: const Color(0x66FFFFFF), size: 20)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF9d4edd) : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? const Color(0xFF9d4edd) : const Color(0x33FFFFFF)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : const Color(0xB3FFFFFF),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _radioTile(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0x269d4edd) : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  selected ? const Color(0xFF9d4edd) : const Color(0x1AFFFFFF)),
        ),
        child: Row(children: [
          Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  selected ? const Color(0xFF9d4edd) : const Color(0x66FFFFFF),
              size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : const Color(0xB3FFFFFF),
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal))),
        ]),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day} ${[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][d.month - 1]} ${d.year}';
}
