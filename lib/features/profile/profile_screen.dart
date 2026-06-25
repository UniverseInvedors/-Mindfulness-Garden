import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/presentation/providers/auth_provider.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/services/ai_service.dart';
import 'package:pranaverse/services/backend_integration_service.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_card.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_button.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_icon.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/l10n/app_localizations.dart';

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
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _aiService = AiService();
  final _backendService = BackendIntegrationService();
  late TabController _tabCtrl;

  String _avatar = '🧘';
  String _age = '', _goal = '';
  final List<String> _conditions = [];
  bool _saving = false;
  bool _notificationsOn = true;
  bool _soundsOn = true;
  String _reminderTime = '08:00';
  
  // Auth state
  bool _isLoginMode = true;
  bool _isAuthLoading = false;
  bool _isAuthenticated = false;
  
  // Backend data
  int _backendStreak = 0;
  int _backendPlants = 0;
  int _backendSessions = 0;
  int _backendMinutes = 0;
  bool _isLoadingBackendData = false;

  static const _avatars = [
    '🧘',
    '🌸',
    '🌿',
    '🦋',
    '🌺',
    '🍃',
    '🌼',
    '🌻',
    '🌷',
    '💐',
    '🌹',
    '🪷',
    '🍀',
    '🌴',
    '🌵',
    '🌲',
    '🌳',
    '🌱',
    '🌾',
    '🌰',
    '🎋'
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
  // TODO: Move these to AppLocalizations for proper i18n
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
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
    _checkAuthStatus();
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

  Future<void> _checkAuthStatus() async {
    await _backendService.initialize();
    final client = _backendService.client;
    if (client != null && client.tokenManager.getAccessToken() != null) {
      setState(() => _isAuthenticated = true);
      await _loadBackendData();
    }
  }

  Future<void> _loadBackendData() async {
    if (!_isAuthenticated) return;
    setState(() => _isLoadingBackendData = true);
    try {
      final allProgress = await _backendService.getAllProgress();
      setState(() {
        _backendStreak = allProgress['current_streak'] ?? 0;
        _backendPlants = allProgress['plants_grown'] ?? 0;
        _backendSessions = allProgress['total_sessions'] ?? 0;
        _backendMinutes = allProgress['total_minutes'] ?? 0;
      });
    } catch (e) {
      print('Failed to load backend data: $e');
    } finally {
      setState(() => _isLoadingBackendData = false);
    }
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      _snack(l10n.pleaseEnterEmailPassword, Colors.red);
      return;
    }

    setState(() => _isAuthLoading = true);
    try {
      await _backendService.initialize();
      final success = await _backendService.login(email, password);
      if (success) {
        setState(() => _isAuthenticated = true);
        await _loadBackendData();
        _snack(l10n.loginSuccessful, const Color(0xFF38b000));
        _passwordCtrl.clear();
      } else {
        _snack(l10n.loginFailed, Colors.red);
      }
    } catch (e) {
      _snack('${l10n.loginError} ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _snack(l10n.pleaseFillAllFields, Colors.red);
      return;
    }

    if (password.length < 6) {
      _snack(l10n.passwordTooShort, Colors.red);
      return;
    }

    setState(() => _isAuthLoading = true);
    try {
      await _backendService.initialize();
      final success = await _backendService.register(email, password, firstName, lastName);
      if (success) {
        setState(() => _isAuthenticated = true);
        _snack(l10n.registrationSuccessful, const Color(0xFF38b000));
        _passwordCtrl.clear();
        _firstNameCtrl.clear();
        _lastNameCtrl.clear();
      } else {
        _snack(l10n.registrationFailed, Colors.red);
      }
    } catch (e) {
      _snack('${l10n.registrationError} ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _backendService.logout();
      setState(() => _isAuthenticated = false);
      _snack(l10n.logoutSuccessful, const Color(0xFF38b000));
    } catch (e) {
      _snack('${l10n.logoutError} ${e.toString()}', Colors.red);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(l10n.pleaseEnterName, Colors.red);
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
    _snack(l10n.profileSaved, const Color(0xFF38b000));
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
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative gradient circles
            Positioned(
              top: -size.height * 0.15,
              right: -size.width * 0.15,
              child: Container(
                width: size.width * 0.4,
                height: size.width * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.1,
              child: Container(
                width: size.width * 0.3,
                height: size.width * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Main content
            Column(
              children: [
                // Custom app bar
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
                      vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
                    ),
                    child: Row(
                      children: [
                        GlassIcon(
                          icon: Icons.arrow_back,
                          onTap: () => context.canPop() ? context.pop() : context.go('/main'),
                          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                          iconColor: Colors.white,
                          blur: 10,
                          opacity: 0.1,
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
                        Expanded(
                          child: Text(l10n.myProfile,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
                              )),
                        ),
                        Builder(builder: (ctx) {
                          final user = ctx.watch<UserProvider>().user;
                          if (user == null || user.email.isEmpty) {
                            return GlassIcon(
                              icon: Icons.login,
                              onTap: () => context.go('/auth'),
                              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                              iconColor: Colors.white,
                              blur: 10,
                              opacity: 0.1,
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
                        GlassIcon(
                          icon: _saving ? Icons.hourglass_empty : Icons.save,
                          onTap: _saving ? null : _save,
                          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                          iconColor: Colors.white,
                          blur: 10,
                          opacity: 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tab bar
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
                    vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 16),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0x66FFFFFF),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: l10n.profile),
                      Tab(text: l10n.health),
                      Tab(text: l10n.settings),
                      Tab(text: l10n.premium)
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [_buildProfileTab(), _buildHealthTab(), _buildSettingsTab(), _buildPremiumTab()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- PROFILE TAB ----------------------------------------------------------

  Widget _buildProfileTab() {
    final l10n = AppLocalizations.of(context)!;
    // Show login/signup form if not authenticated
    if (!_isAuthenticated) {
      return _buildAuthSection();
    }

    final user = context.watch<UserProvider>().user;
    // Use backend data when available, fallback to local storage
    final streak = _isAuthenticated ? _backendStreak : LocalStorageService.getCurrentStreak();
    final sessions = LocalStorageService.getSessions();
    final totalMin = _isAuthenticated ? _backendMinutes : sessions.fold(0, (s, e) => s + e.durationMinutes);
    final moods = LocalStorageService.getAllMoods();
    final plants = _isAuthenticated ? _backendPlants : (LocalStorageService.getSetting('garden_plants_grown') ?? 0);
    final sessionCount = _isAuthenticated ? _backendSessions : sessions.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar + name hero with glassmorphism
        GlassCard(
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsivePadding(context, mobilePadding: 24),
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24)),
          blur: 20,
          opacity: 0.1,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9D4EDD).withOpacity(0.2),
              const Color(0xFF00B4D8).withOpacity(0.1),
            ],
          ),
          child: Column(
            children: [
              Stack(children: [
                Container(
                  width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 100, tabletWidth: 110, desktopWidth: 120),
                  height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 100, tabletHeight: 110, desktopHeight: 120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4), blurRadius: 24, spreadRadius: 4)
                    ],
                  ),
                  child: Center(
                      child: Text(_avatar, style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 50, tabletSize: 55, desktopSize: 60)))),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: GlassContainer(
                        width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 32, tabletWidth: 36, desktopWidth: 40),
                        height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 32, tabletHeight: 36, desktopHeight: 40),
                        borderRadius: BorderRadius.circular(16),
                        blur: 10,
                        opacity: 0.2,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 16, tabletSize: 18, desktopSize: 20)),
                      ),
                    )),
              ]),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
              Center(
                child: Text(user?.name ?? l10n.myProfile,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 22, tabletSize: 24, desktopSize: 26),
                        fontWeight: FontWeight.w800)),
              ),
              if (_emailCtrl.text.isNotEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 4)),
                    child: Text(_emailCtrl.text,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 13, tabletSize: 14, desktopSize: 15))),
                  ),
                ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
              GlassContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
                  vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 6),
                ),
                borderRadius: BorderRadius.circular(20),
                blur: 10,
                opacity: 0.15,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
                child: Text('${l10n.gardenLevel} ${user?.gardenLevel ?? 1}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14))),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

        // Stats grid with glassmorphism cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10),
          mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10),
          childAspectRatio: 1.1,
          children: [
            _statCard('🔥', '$streak', l10n.streak, Theme.of(context).colorScheme.tertiary),
            _statCard('🧘', '${sessions.length}', l10n.sessions,
                Theme.of(context).colorScheme.primary),
            _statCard('⏱️', '$totalMin', l10n.minutes, Theme.of(context).colorScheme.secondary),
            _statCard(
                '📊', '${moods.length}', l10n.moodLogs, Theme.of(context).colorScheme.error),
            _statCard('🌱', '$plants', l10n.plants, Colors.green),
            _statCard('🏆', 'Lv.${user?.gardenLevel ?? 1}', l10n.garden,
                Colors.amber),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

        // Personal info with glassmorphism
        _label(l10n.personalInfo),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10)),
        _field(_nameCtrl, l10n.yourName, Icons.person_outline),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10)),
        _field(_emailCtrl, l10n.emailOptional, Icons.email_outlined),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10)),
        _multiField(_bioCtrl, l10n.bio,
            Icons.notes_outlined, 3),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

        // Joined date with glassmorphism
        if (user != null)
          GlassCard(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 14)),
            blur: 15,
            opacity: 0.1,
            child: Row(children: [
              Icon(Icons.calendar_today_outlined,
                  color: Colors.white.withOpacity(0.5), size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 18, tabletSize: 20, desktopSize: 22)),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10)),
              Text('${l10n.memberSince} ${_fmtDate(user.joinedDate)}',
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.5), fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 13, tabletSize: 14, desktopSize: 15))),
            ]),
          ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.saveProfile,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
        
        // Logout button
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.signOut,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return GlassCard(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
      ),
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 16)),
      blur: 15,
      opacity: 0.1,
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.1),
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24))),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 2)),
        Text(value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 16, desktopSize: 18))),
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.6),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 9, tabletSize: 10, desktopSize: 11))),
      ]),
    );
  }

  // --- AUTH SECTION ----------------------------------------------------------

  Widget _buildAuthSection() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Auth card with glassmorphism
        GlassCard(
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsivePadding(context, mobilePadding: 24),
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24)),
          blur: 20,
          opacity: 0.1,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9D4EDD).withOpacity(0.2),
              const Color(0xFF00B4D8).withOpacity(0.1),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_isLoginMode ? l10n.signIn : l10n.createAccount,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                )),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
            Text(_isLoginMode ? l10n.accessPremiumFeatures : l10n.joinMindfulnessGarden,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                )),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),
            
            // Email field
            _field(_emailCtrl, l10n.email, Icons.email_outlined),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
            
            // Password field
            _field(_passwordCtrl, l10n.password, Icons.lock_outlined, isPassword: true),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
            
            // Name fields for signup
            if (!_isLoginMode) ...[
              _field(_firstNameCtrl, l10n.firstName, Icons.person_outline),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
              _field(_lastNameCtrl, l10n.lastName, Icons.person_outline),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
            ],
            
            // Login/Signup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAuthLoading ? null : (_isLoginMode ? _handleLogin : _handleSignup),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9d4edd),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isAuthLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isLoginMode ? l10n.signIn : l10n.createAccount,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
            
            // Toggle between login/signup
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(_isLoginMode ? "${l10n.dontHaveAccount} ${l10n.createAccount}" : "${l10n.alreadyHaveAccount} ${l10n.signIn}",
                    style: TextStyle(
                      color: const Color(0xFF9d4edd),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                    )),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // --- PREMIUM TAB -----------------------------------------------------------

  Widget _buildPremiumTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Premium header
        GlassCard(
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsivePadding(context, mobilePadding: 24),
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24)),
          blur: 20,
          opacity: 0.1,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.2),
              const Color(0xFFFFA500).withOpacity(0.1),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Premium Features',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 22, tabletSize: 24, desktopSize: 26),
                      )),
                  Text(_isAuthenticated ? 'You are logged in' : 'Sign in to unlock premium features',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                      )),
                ]),
              ),
            ]),
          ]),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),
        
        // Premium features list
        _buildPremiumFeature('?????', 'Advanced Meditations', 'Access to 500+ guided sessions'),
        _buildPremiumFeature('??', 'Premium Audio', 'High-quality binaural beats & music'),
        _buildPremiumFeature('??', 'Detailed Analytics', 'Track your mindfulness journey'),
        _buildPremiumFeature('??', 'Exclusive Plants', 'Unlock rare garden plants'),
        _buildPremiumFeature('??', 'Achievements', 'Earn badges and compete on leaderboards'),
        _buildPremiumFeature('??', 'Community', 'Join groups and share experiences'),
        
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),
        
        // Logout button if authenticated
        if (_isAuthenticated)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Sign Out',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ),
      ]),
    );
  }

  Widget _buildPremiumFeature(String emoji, String title, String description) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
      ),
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 16)),
      blur: 15,
      opacity: 0.1,
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 17, desktopSize: 18),
                )),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 4)),
            Text(description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 13, tabletSize: 14, desktopSize: 15),
                )),
          ]),
        ),
        Icon(Icons.lock_outline, color: _isAuthenticated ? Colors.green : Colors.grey, size: 20),
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

  // --- HEALTH TAB -----------------------------------------------------------

  Widget _buildHealthTab() {
    final l10n = AppLocalizations.of(context)!;
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
            const Text('??', style: TextStyle(fontSize: 36)),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.saveProfile,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  // --- SETTINGS TAB ---------------------------------------------------------

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
        riverpod.Consumer(builder: (ctx, ref, _) {
          return Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(
                AppLanguage.english.displayName,
                false,
                () => context.read<AppSettingsProvider>().setLanguage(AppLanguage.english)),
            _chip(
                AppLanguage.hindi.displayName,
                false,
                () => context.read<AppSettingsProvider>().setLanguage(AppLanguage.hindi)),
            _chip(
                AppLanguage.bengali.displayName,
                false,
                () => context.read<AppSettingsProvider>().setLanguage(AppLanguage.bengali)),
          ]);
        }),
        const SizedBox(height: 20),
        _label('VOICE PERSONALITY'),
        const SizedBox(height: 10),
        Builder(builder: (ctx) {
          final current = ctx.watch<AppSettingsProvider>().voicePersonality;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(
                'Buddha',
                current == VoicePersonality.buddha,
                () => ctx
                    .read<AppSettingsProvider>()
                    .setVoicePersonality(VoicePersonality.buddha)),
            _chip(
                'Zeno',
                current == VoicePersonality.zeno,
                () => ctx
                    .read<AppSettingsProvider>()
                    .setVoicePersonality(VoicePersonality.zeno)),
            _chip(
                'Monk',
                current == VoicePersonality.monk,
                () => ctx
                    .read<AppSettingsProvider>()
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
            _aboutRow('Package', 'com.mindfulgarden.pranaverse'),
            Builder(builder: (ctx) {
              final p = ctx.watch<AppSettingsProvider>().voicePersonality;
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

  // --- HELPERS --------------------------------------------------------------

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF00b4d8),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.5));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
      ),
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 14)),
      blur: 15,
      opacity: 0.1,
      child: Theme(
        data: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false)),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 15, tabletSize: 16, desktopSize: 17)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0x4DFFFFFF), fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 15, tabletSize: 16, desktopSize: 17)),
          prefixIcon: Icon(icon, color: const Color(0x66FFFFFF), size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
            vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
          ),
        ),
      ),
      ),
    );
  }

  Widget _multiField(
      TextEditingController ctrl, String hint, IconData icon, int lines) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
      ),
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 14)),
      blur: 15,
      opacity: 0.1,
      child: Theme(
        data: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false)),
        child: TextField(
          controller: ctrl,
          maxLines: lines,
          style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0x4DFFFFFF), fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16)),
            prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: lines * 20),
                child: Icon(icon, color: const Color(0x66FFFFFF), size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24))),
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







