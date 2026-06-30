// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MainMenuScreen — Modern redesign
//
// Layout:
//   • Full-screen 2.5D garden scene as hero background
//   • Frosted-glass header with greeting + stats
//   • Horizontal feature rows (Breathe, Meditate, Yoga, Wellness, Community)
//   • "Begin Today" featured CTA
//   • Bottom nav bar (Home, Garden, Progress, Profile)
// ─────────────────────────────────────────────────────────────────────────────

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MainMenuContent();
  }
}

class _MainMenuContent extends StatefulWidget {
  const _MainMenuContent();

  @override
  State<_MainMenuContent> createState() => _MainMenuContentState();
}

class _MainMenuContentState extends State<_MainMenuContent>
    with TickerProviderStateMixin {
  late AnimationController _ambientCtrl;
  int _tapCount = 0;
  int _selectedNav = 0;

  ColorScheme get colors => Theme.of(context).colorScheme;

  // ── Feature rows ────────────────────────────────────────────────────────────
  static const _rows = [
    _FeatureRow(
      label: 'BREATHE',
      emoji: '🌬️',
      color: Color(0xFF00b4d8),
      items: [
        _FeatureItem('Zeno Breathing', Icons.air, '/breathing/zeno',
            Color(0xFF00b4d8), 'Stress relief'),
        _FeatureItem('Box Breathing', Icons.crop_square, '/breathing/box',
            Color(0xFF4361ee), 'Focus & calm'),
        _FeatureItem('4-7-8 Breathing', Icons.nightlight_round,
            '/breathing/478', Color(0xFF9d4edd), 'Sleep & anxiety'),
        _FeatureItem('Breath Awareness', Icons.self_improvement,
            '/breathing/awareness', Color(0xFFffb700), 'Mindfulness'),
        _FeatureItem('Alternate Nostril', Icons.air_outlined,
            '/breathing/alternate', Color(0xFFf72585), 'Balance'),
        _FeatureItem('Diaphragmatic', Icons.waves_outlined,
            '/breathing/diaphragmatic', Color(0xFF38b000), 'Deep relax'),
      ],
    ),
    _FeatureRow(
      label: 'MEDITATE',
      emoji: '🧘',
      color: Color(0xFF9d4edd),
      items: [
        _FeatureItem('Guided Meditation', Icons.headphones,
            '/guided-meditation', Color(0xFF9d4edd), 'Expert-led'),
        _FeatureItem('Audio Meditation', Icons.music_note, '/audio-meditation',
            Color(0xFF4361ee), 'Immersive sound'),
        _FeatureItem('Meditation Scenes', Icons.landscape, '/scenes',
            Color(0xFF00b4d8), '5 environments'),
        _FeatureItem('AI Coach', Icons.psychology, '/ai-coach',
            Color(0xFF7209b7), 'Personalised'),
        _FeatureItem('Binaural Beats', Icons.waves, '/binaural-beats',
            Color(0xFF3a86ff), 'Brainwaves'),
        _FeatureItem('Sound Therapy', Icons.spa, '/sound-therapy',
            Color(0xFF4cc9f0), 'Frequencies'),
      ],
    ),
    _FeatureRow(
      label: 'YOGA',
      emoji: '🏯',
      color: Color(0xFFe9c46a),
      items: [
        _FeatureItem('Yoga with Zeno', Icons.self_improvement, '/yoga',
            Color(0xFFe9c46a), '2.5D immersive'),
        _FeatureItem('Meditation Music', Icons.library_music, '/music',
            Color(0xFF4361ee), 'Curated tracks'),
      ],
    ),
    _FeatureRow(
      label: 'WELLNESS',
      emoji: '🌿',
      color: Color(0xFF38b000),
      items: [
        _FeatureItem('My Garden', Icons.spa, '/garden', Color(0xFF38b000),
            'Grow & harvest'),
        _FeatureItem('Mood Tracker', Icons.emoji_emotions, '/mood-tracker',
            Color(0xFFf72585), 'Daily logging'),
        _FeatureItem('Sleep Tracker', Icons.bedtime, '/sleep',
            Color(0xFF3a0ca3), 'Sleep analysis'),
        _FeatureItem('Heart Rate', Icons.favorite, '/heart-rate',
            Color(0xFFe63946), 'Biometrics'),
        _FeatureItem('Progress', Icons.insights, '/progress', Color(0xFF9d4edd),
            'Your journey'),
      ],
    ),
    _FeatureRow(
      label: 'COMMUNITY',
      emoji: '👥',
      color: Color(0xFFffb700),
      items: [
        _FeatureItem('Daily Challenges', Icons.emoji_events, '/challenges',
            Color(0xFFffb700), 'Daily missions'),
        _FeatureItem('Friends', Icons.people, '/friends', Color(0xFFf48c06),
            'Meditate together'),
        _FeatureItem('Achievements', Icons.stars, '/achievements',
            Color(0xFFe85d04), 'Badges & rewards'),
        _FeatureItem('Analytics', Icons.insights, '/analytics',
            Color(0xFF8DD9C4), 'Your trends'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
      VoiceService().initialize();
      // Start garden bg music
      final hour = DateTime.now().hour;
      if (hour >= 6 && hour < 20) {
        SoundService().playGardenDay();
      } else {
        SoundService().playGardenNight();
      }
    });
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    SoundService().stopBg();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _navigate(String route) {
    _tapCount++;
    // Interstitial: fire every 3rd navigation, with placement context + cooldown
    if (_tapCount % 3 == 0) {
      AdService().showInterstitial(placement: AdPlacement.menuNavigation);
    }

    const valid = [
      '/breathing',
      '/breathing/zeno',
      '/breathing/box',
      '/breathing/478',
      '/breathing/awareness',
      '/breathing/alternate',
      '/breathing/diaphragmatic',
      '/guided-meditation',
      '/audio-meditation',
      '/meditation',
      '/scenes',
      '/ai-coach',
      '/binaural-beats',
      '/sound-therapy',
      '/music',
      '/yoga',
      '/garden',
      '/mood-tracker',
      '/sleep',
      '/heart-rate',
      '/progress',
      '/challenges',
      '/friends',
      '/achievements',
      '/analytics',
      '/subscription',
      '/settings',
      '/profile',
    ];

    if (valid.contains(route)) {
      context.push(route);
    } else {
      _showComingSoon(route);
    }
  }

  void _showComingSoon(String route) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppCopy.read(context, 'Coming Soon'),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
            AppCopy.read(context, 'routeComingSoon', vars: {'route': route}),
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppCopy.read(context, 'OK'),
                style: const TextStyle(color: Color(0xFF00b4d8))),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _greeting() => AppCopy.greeting(AppCopy.languageOf(context));

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      extendBody: false,
      body: Stack(
        children: [
          // ── Hero: live 2.5D scene ──────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isDesktop ? size.height * 0.5 : size.height * 0.42,
            child: Consumer(
              builder: (context, ref, _) {
                final themeSettings = ref.watch(themePreferenceProvider);
                return MeditationSceneWidget(
                  breathPhase: BreathPhase.idle,
                  pose: ZenoPose.sitting,
                  environment: themeSettings.environment,
                  timeOfDay: themeSettings.timeOfDay,
                  instruction: '',
                  isActive: true,
                  height: isDesktop ? size.height * 0.5 : size.height * 0.42,
                  teacher: ref.watch(teacherPreferenceProvider),
                );
              },
            ),
          ),

          // ── Gradient fade from scene to content ────────────────────────────
          Positioned(
            top: isDesktop ? size.height * 0.35 : size.height * 0.28,
            left: 0,
            right: 0,
            height: size.height * 0.16,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, colors.surface],
                ),
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Space for the hero scene
                SliverToBoxAdapter(
                    child: SizedBox(
                        height: isDesktop
                            ? size.height * 0.38
                            : size.height * 0.30)),

                // ── Greeting + stats card ──────────────────────────────────
                SliverToBoxAdapter(child: _buildGreetingCard(user)),

                // ── Featured CTA ───────────────────────────────────────────
                SliverToBoxAdapter(child: _buildFeaturedCTA()),

                // ── Feature rows ───────────────────────────────────────────
                for (final row in _rows) ...[
                  SliverToBoxAdapter(child: _buildRowHeader(row)),
                  SliverToBoxAdapter(child: _buildFeatureRow(row)),
                ],

                // Bottom padding for nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // ── Top bar (transparent, over scene) ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(user),
            ),
          ),
        ],
      ),

      // ── Bottom nav bar — banner sits above it, zero layout impact when empty ──
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar(UserProvider user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // App name
          Text(
            AppCopy.of(context, 'Mindfulness Garden'),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              shadows: [const Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          const Spacer(),
          // Settings
          _glassIconBtn(
              Icons.settings_outlined, () => context.push('/settings')),
          const SizedBox(width: 8),
          // Subscription
          _glassIconBtn(Icons.workspace_premium_outlined,
              () => context.push('/subscription')),
        ],
      ),
    );
  }

  Widget _glassIconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            shape: BoxShape.circle,
            border: Border.all(color: colors.onSurface.withAlpha(40)),
          ),
          child: Icon(icon, color: colors.onSurface, size: 18),
        ),
      );

  // ── Greeting + stats card ────────────────────────────────────────────────────
  Widget _buildGreetingCard(UserProvider user) {
    final avatar =
        LocalStorageService.getSetting('profile_avatar') as String? ?? '🧘';
    final sessions = LocalStorageService.getSessions();
    final totalMin = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        0,
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
      ),
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ),
        decoration: BoxDecoration(
          color: colors.onSurface.withAlpha(12),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(context,
                mobileRadius: 24),
          ),
          border: Border.all(color: colors.onSurface.withAlpha(25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: ResponsiveHelper.getResponsiveContainerWidth(context,
                        mobileWidth: 56, tabletWidth: 64, desktopWidth: 72),
                    height: ResponsiveHelper.getResponsiveContainerHeight(
                        context,
                        mobileHeight: 56,
                        tabletHeight: 64,
                        desktopHeight: 72),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withAlpha(100),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(avatar,
                            style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobileSize: 26,
                                        tabletSize: 30,
                                        desktopSize: 34)))),
                  ),
                ),
                SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context,
                        mobileSpacing: 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                          style: TextStyle(
                              color: colors.onSurface.withAlpha(160),
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobileSize: 13,
                                  tabletSize: 15,
                                  desktopSize: 17))),
                      SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(context,
                              mobileSpacing: 2)),
                      Text(
                          user.currentUser?.name ??
                              AppCopy.of(context, 'Mindful Gardener'),
                          style: TextStyle(
                              color: colors.onSurface,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobileSize: 20,
                                  tabletSize: 24,
                                  desktopSize: 28),
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                // Streak badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsivePadding(context,
                        mobilePadding: 12),
                    vertical: ResponsiveHelper.getResponsivePadding(context,
                        mobilePadding: 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(40),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(context,
                          mobileRadius: 16),
                    ),
                    border: Border.all(color: Colors.orange.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department,
                          color: Colors.orange,
                          size: ResponsiveHelper.getResponsiveIconSize(context,
                              mobileSize: 18, tabletSize: 20, desktopSize: 22)),
                      SizedBox(
                          width: ResponsiveHelper.getResponsiveSpacing(context,
                              mobileSpacing: 4)),
                      Text('${user.currentUser?.currentStreak ?? 0}',
                          style: TextStyle(
                              color: colors.onSurface,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobileSize: 16,
                                  tabletSize: 18,
                                  desktopSize: 20),
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context,
                    mobileSpacing: 16)),

            // Stats strip
            Row(
              children: [
                _statChip('${sessions.length}', AppCopy.of(context, 'Sessions'),
                    const Color(0xFF9d4edd)),
                SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context,
                        mobileSpacing: 10)),
                _statChip('$totalMin', AppCopy.of(context, 'Minutes'),
                    const Color(0xFF00b4d8)),
                SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context,
                        mobileSpacing: 10)),
                _statChip('${user.currentUser?.gardenLevel ?? 1}',
                    AppCopy.of(context, 'Garden Lv'), const Color(0xFF38b000)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 18, fontWeight: FontWeight.w800)),
              Text(label,
                  style: TextStyle(
                      color: colors.onSurface.withAlpha(140), fontSize: 10)),
            ],
          ),
        ),
      );

  // ── Featured CTA ─────────────────────────────────────────────────────────────
  Widget _buildFeaturedCTA() {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        0,
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
      ),
      child: GestureDetector(
        onTap: () {
          VoiceService().speakBreathingIntro();
          _navigate('/breathing/zeno');
        },
        child: Container(
          height: ResponsiveHelper.getResponsiveContainerHeight(context,
              mobileHeight: 90, tabletHeight: 100, desktopHeight: 110),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveBorderRadius(context,
                  mobileRadius: 22),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9d4edd).withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.onSurface.withAlpha(15),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.onSurface.withAlpha(10),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsivePadding(context,
                      mobilePadding: 22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getResponsiveContainerWidth(
                          context,
                          mobileWidth: 52,
                          tabletWidth: 60,
                          desktopWidth: 68),
                      height: ResponsiveHelper.getResponsiveContainerHeight(
                          context,
                          mobileHeight: 52,
                          tabletHeight: 60,
                          desktopHeight: 68),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: colors.onSurface,
                          size: ResponsiveHelper.getResponsiveIconSize(context,
                              mobileSize: 30, tabletSize: 34, desktopSize: 38)),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(context,
                            mobileSpacing: 16)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppCopy.of(context, 'Begin Today'),
                              style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobileSize: 20,
                                          tabletSize: 24,
                                          desktopSize: 28),
                                  fontWeight: FontWeight.w800)),
                          Text(
                              AppCopy.of(context,
                                  'Start a 2-min Zeno breathing session'),
                              style: TextStyle(
                                  color: colors.onSurface.withOpacity(0.7),
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobileSize: 12,
                                          tabletSize: 14,
                                          desktopSize: 16))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: colors.onSurface.withOpacity(0.7),
                        size: ResponsiveHelper.getResponsiveIconSize(context,
                            mobileSize: 16, tabletSize: 18, desktopSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Row header ───────────────────────────────────────────────────────────────
  Widget _buildRowHeader(_FeatureRow row) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 10),
      ),
      child: Row(
        children: [
          Text(row.emoji,
              style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                      mobileSize: 18, tabletSize: 20, desktopSize: 22))),
          SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(context,
                  mobileSpacing: 8)),
          Text(AppCopy.of(context, row.label),
              style: TextStyle(
                color: row.color,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                    mobileSize: 12, tabletSize: 14, desktopSize: 16),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              )),
          const Spacer(),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: row.color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  // ── Feature row (horizontal scroll) ─────────────────────────────────────────
  Widget _buildFeatureRow(_FeatureRow row) {
    return SizedBox(
      height: ResponsiveHelper.getResponsiveContainerHeight(context,
          mobileHeight: 120, tabletHeight: 140, desktopHeight: 160),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
          0,
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
        ),
        itemCount: row.items.length,
        separatorBuilder: (_, __) => SizedBox(
            width: ResponsiveHelper.getResponsiveSpacing(context,
                mobileSpacing: 12)),
        itemBuilder: (_, i) => _buildFeatureCard(row.items[i]),
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return GestureDetector(
      onTap: () => _navigate(item.route),
      child: Container(
        width: ResponsiveHelper.getResponsiveContainerWidth(context,
            mobileWidth: 110, tabletWidth: 130, desktopWidth: 150),
        decoration: BoxDecoration(
          color: colors.onSurface.withAlpha(8),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(context,
                mobileRadius: 18),
          ),
          border: Border.all(color: item.color.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: item.color.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(context,
                  mobileWidth: 46, tabletWidth: 54, desktopWidth: 62),
              height: ResponsiveHelper.getResponsiveContainerHeight(context,
                  mobileHeight: 46, tabletHeight: 54, desktopHeight: 62),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [item.color.withAlpha(180), item.color.withAlpha(80)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withAlpha(80),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(item.icon,
                  color: colors.onSurface,
                  size: ResponsiveHelper.getResponsiveIconSize(context,
                      mobileSize: 22, tabletSize: 26, desktopSize: 30)),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context,
                    mobileSpacing: 6)),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsivePadding(context,
                      mobilePadding: 6)),
              child: Text(AppCopy.of(context, item.title),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colors.onSurface,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                          mobileSize: 11, tabletSize: 13, desktopSize: 15),
                      fontWeight: FontWeight.w600,
                      height: 1.1)),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context,
                    mobileSpacing: 2)),
            Text(AppCopy.of(context, item.subtitle),
                style: TextStyle(
                    color: item.color.withAlpha(200),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                        mobileSize: 9, tabletSize: 10, desktopSize: 11))),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav bar ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.spa_rounded, 'Garden'),
      _NavItem(Icons.insights_rounded, 'Progress'),
      _NavItem(Icons.person_rounded, 'Profile'),
    ];
    const routes = ['/main', '/garden', '/progress', '/profile'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d0d1f),
        border: Border(top: BorderSide(color: colors.onSurface.withAlpha(20))),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 20),
        ],
      ),
      // Use SafeArea to handle system nav bar — no extendBody so this is clean
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getResponsivePadding(context,
                  mobilePadding: 8)),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = _selectedNav == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _selectedNav = i);
                    if (i != 0) context.push(routes[i]);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected
                            ? ResponsiveHelper.getResponsiveContainerWidth(
                                context,
                                mobileWidth: 38,
                                tabletWidth: 44,
                                desktopWidth: 50)
                            : ResponsiveHelper.getResponsiveContainerWidth(
                                context,
                                mobileWidth: 32,
                                tabletWidth: 38,
                                desktopWidth: 44),
                        height: selected
                            ? ResponsiveHelper.getResponsiveContainerHeight(
                                context,
                                mobileHeight: 38,
                                tabletHeight: 44,
                                desktopHeight: 50)
                            : ResponsiveHelper.getResponsiveContainerHeight(
                                context,
                                mobileHeight: 32,
                                tabletHeight: 38,
                                desktopHeight: 44),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF9d4edd).withAlpha(40)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveBorderRadius(context,
                                mobileRadius: 12),
                          ),
                        ),
                        child: Icon(
                          items[i].icon,
                          color: selected
                              ? const Color(0xFF9d4edd)
                              : colors.onSurface.withAlpha(100),
                          size: selected
                              ? ResponsiveHelper.getResponsiveIconSize(context,
                                  mobileSize: 20,
                                  tabletSize: 24,
                                  desktopSize: 28)
                              : ResponsiveHelper.getResponsiveIconSize(context,
                                  mobileSize: 18,
                                  tabletSize: 22,
                                  desktopSize: 26),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(context,
                              mobileSpacing: 4)),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppCopy.of(context, items[i].label),
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF9d4edd)
                                    : colors.onSurface.withAlpha(80),
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobileSize: 10,
                                        tabletSize: 12,
                                        desktopSize: 14),
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Time of day for scene ────────────────────────────────────────────────────
  SceneTimeOfDay _currentTimeOfDay() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 8) return SceneTimeOfDay.dawn;
    if (h >= 8 && h < 17) return SceneTimeOfDay.morning;
    if (h >= 17 && h < 19) return SceneTimeOfDay.dusk;
    if (h >= 19 && h < 21) return SceneTimeOfDay.afternoon;
    return SceneTimeOfDay.night;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow {
  final String label, emoji;
  final Color color;
  final List<_FeatureItem> items;
  const _FeatureRow(
      {required this.label,
      required this.emoji,
      required this.color,
      required this.items});
}

class _FeatureItem {
  final String title, route, subtitle;
  final IconData icon;
  final Color color;
  const _FeatureItem(
      this.title, this.icon, this.route, this.color, this.subtitle);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Keep old data classes for backward compatibility
class MenuCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<MenuItem> screens;
  const MenuCategory(
      {required this.title,
      required this.icon,
      required this.color,
      required this.gradient,
      required this.screens});
}

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final String description;
  final Color color;
  const MenuItem(
      {required this.title,
      required this.icon,
      required this.route,
      required this.description,
      required this.color});
}
