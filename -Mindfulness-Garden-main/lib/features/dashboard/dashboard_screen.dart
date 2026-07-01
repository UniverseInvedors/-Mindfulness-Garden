import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/core/widgets/breathing_visualizer.dart';
import 'package:pranaverse/core/widgets/enhanced_garden_widget.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_button.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_card.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_icon.dart';
import 'package:pranaverse/data/models/mood_model.dart';
import 'package:pranaverse/data/models/session_model.dart';
import 'package:pranaverse/presentation/providers/mood_provider.dart';
import 'package:pranaverse/presentation/providers/session_provider.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/l10n/app_localizations.dart';
import 'package:pranaverse/features/dashboard/widgets/location_time_widget.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/mixins/theme_audio_mixin.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, ThemeAudioMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    startThemeAudio();
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
    stopThemeAudio();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final appSettings = context.watch<AppSettingsProvider>();
    final user = userProvider.user;
    final sessions = sessionProvider.sessions;
    final mood = moodProvider.todayMood;
    final event = _seasonalEvent();
    final plan = _buildPlan(userProvider, sessionProvider, moodProvider);
    final message = _buildCompanionMessage(userProvider, sessions, mood);
    final rewards = _buildRewards(userProvider);
    final leaderboard = _buildLeaderboard(userProvider);

    // Get auto background image if enabled
    final bgImage = appSettings.autoThemeService.autoBackgroundEnabled
        ? appSettings.autoThemeService.getCurrentBackgroundImage()
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          image: bgImage != null
              ? DecorationImage(
                  image: AssetImage(bgImage),
                  fit: BoxFit.cover,
                  opacity: 0.15, // Subtle background
                )
              : null,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
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
                          GlassIcon(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.go('/main'),
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobileSize: 24,
                              tabletSize: 26,
                              desktopSize: 28,
                            ),
                            iconColor: Theme.of(context).colorScheme.onSurface,
                            blur: 10,
                            opacity: 0.1,
                          ),
                          const Spacer(),
                          if (user?.email == null ||
                              user?.email.isEmpty == true)
                            GlassIcon(
                              icon: Icons.login_rounded,
                              onTap: () => context.go('/auth'),
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobileSize: 24,
                                tabletSize: 26,
                                desktopSize: 28,
                              ),
                              iconColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              blur: 10,
                              opacity: 0.1,
                            ),
                          GlassIcon(
                            icon: Icons.calendar_month_rounded,
                            onTap: () => context.go('/progress'),
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobileSize: 24,
                              tabletSize: 26,
                              desktopSize: 28,
                            ),
                            iconColor: Theme.of(context).colorScheme.onSurface,
                            blur: 10,
                            opacity: 0.1,
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobileSpacing: 10,
                            ),
                          ),
                          GlassIcon(
                            icon: Icons.notifications_none_rounded,
                            onTap: () {},
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobileSize: 24,
                              tabletSize: 26,
                              desktopSize: 28,
                            ),
                            iconColor: Theme.of(context).colorScheme.onSurface,
                            blur: 10,
                            opacity: 0.1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Location & Time Widget
                      const LocationTimeWidget(),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            0,
                            -6 * Curves.easeInOut.transform(_controller.value),
                          ),
                          child: child,
                        ),
                        child: _hero(
                          context,
                          user?.name.isNotEmpty == true
                              ? user!.name
                              : l10n.myProfile,
                          user?.currentStreak ?? 0,
                          event,
                          message,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 20,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              l10n.minutes,
                              '${user?.totalMinutes ?? 0}',
                              Icons.timelapse_rounded,
                              Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobileSpacing: 12,
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              l10n.sessions,
                              '${user?.totalSessions ?? sessions.length}',
                              Icons.self_improvement_rounded,
                              Colors.lightGreen,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobileSpacing: 12,
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              l10n.garden,
                              'Lv ${user?.gardenLevel ?? 1}',
                              Icons.park_rounded,
                              Colors.lightGreen.shade300,
                              footer: '${user?.achievementCount ?? 0} charms',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 20,
                        ),
                      ),
                      _banner(context, event),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section(
                        'Today\'s Plan',
                        'Your personalized yoga and meditation schedule',
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: plan.length,
                          separatorBuilder: (_, __) => SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobileSpacing: 16,
                            ),
                          ),
                          itemBuilder: (context, index) =>
                              _planCard(context, plan[index]),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section(
                        'AI Companion Insight',
                        'Personalized guidance from Zeno',
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      _companionCard(message, mood),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section('Living Garden', 'Grow your mindfulness garden'),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      _gardenCard(
                        context,
                        user?.gardenLevel ?? 1,
                        user?.currentStreak ?? 0,
                        sessions.length,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section(
                        'Breathing Studio',
                        'Guided breathing exercises',
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _cardIntro(
                              'Master your breath with guided exercises',
                              'Open',
                              () => context.go('/breathing'),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                mobileSpacing: 14,
                              ),
                            ),
                            const BreathingVisualizer(size: 210),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section('Momentum Circle', 'Track your progress streak'),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      _socialCard(
                        context,
                        leaderboard,
                        user?.currentStreak ?? 0,
                        user?.totalMinutes ?? 0,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section(
                        'Reward Vault',
                        'Unlock achievements and rewards',
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
                      _card(
                        child: Column(
                          children: rewards.map(_rewardTile).toList(),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 16,
                        ),
                      ),
                      // ── Earn bonus seeds by watching a rewarded ad ──────
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF39D353,
                                    ).withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.eco_rounded,
                                    color: Color(0xFF39D353),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Bonus Garden Seeds',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Watch a short ad to earn extra seeds',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.62),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            RewardedAdButton(
                              label: 'Watch ad for +10 seeds',
                              onRewarded: (amount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '🌱 +$amount seeds added to your garden!',
                                    ),
                                    backgroundColor: const Color(0xFF39D353),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 24,
                        ),
                      ),
                      _section('Quick Actions', 'Start your session instantly'),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 12,
                        ),
                      ),
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

  Widget _hero(
    BuildContext context,
    String name,
    int streak,
    _Seasonal event,
    String message,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(28),
      blur: 25,
      opacity: 0.12,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.9),
          Theme.of(context).colorScheme.primary.withOpacity(0.75),
          Theme.of(context).colorScheme.secondary.withOpacity(0.65),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                fontSize: 24,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streak days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      event.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.shortLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/meditation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Start Session',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              GlassButton(
                onPressed: () => context.go('/garden'),
                blur: 10,
                opacity: 0.1,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                child: Text(
                  'Open Garden',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobileSize: 15,
                      tabletSize: 16,
                      desktopSize: 17,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context, _Seasonal event) => GlassContainer(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 28),
        ),
        blur: 15,
        opacity: 0.2,
        gradient: LinearGradient(colors: [event.start, event.end]),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(
                context,
                mobileWidth: 58,
              ),
              height: ResponsiveHelper.getResponsiveContainerHeight(
                context,
                mobileHeight: 58,
              ),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                event.icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 28,
              ),
            ),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 16,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobileSpacing: 6,
                    ),
                  ),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.88),
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _companionCard(String message, MoodModel? mood) {
    final moodLabel = mood?.mood.isNotEmpty == true ? mood!.mood : 'Unlogged';
    final rating = mood?.rating ?? 0;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.favorite_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobileSpacing: 14,
                ),
              ),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobileSpacing: 16,
            ),
          ),
          Wrap(
            spacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobileSpacing: 10,
            ),
            runSpacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobileSpacing: 10,
            ),
            children: [
              _tag(Icons.mood_rounded, 'Mood: $moodLabel'),
              _tag(
                Icons.star_outline_rounded,
                rating > 0
                    ? 'Energy ${rating.toStringAsFixed(1)}/5'
                    : 'Rate today',
              ),
              _tag(Icons.auto_awesome_rounded, 'AI Companion Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gardenCard(
    BuildContext context,
    int level,
    int streak,
    int sessions,
  ) =>
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardIntro(
              'Grow your mindfulness garden',
              'Play',
              () => context.go('/garden'),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 14,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child:
                  EnhancedGardenWidget(level: level, streak: streak, size: 240),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 14,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _mini(
                    'Garden Power',
                    '${min(100, 30 + (level * 8))}%',
                    Colors.green,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobileSpacing: 10,
                  ),
                ),
                Expanded(
                  child:
                      _mini('Session Fuel', '$sessions boosts', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _socialCard(
    BuildContext context,
    List<_Board> board,
    int streak,
    int minutes,
  ) =>
      GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 28),
        ),
        blur: 12,
        opacity: 0.1,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.3),
            Theme.of(context).colorScheme.surface.withOpacity(0.2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Weekly Calm League',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobileSize: 18,
                        tabletSize: 19,
                        desktopSize: 20,
                      ),
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                GlassButton(
                  onPressed: () => _shareProgress(streak, minutes),
                  blur: 8,
                  opacity: 0.15,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.ios_share_rounded,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          mobileSize: 18,
                          tabletSize: 19,
                          desktopSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobileSpacing: 6,
                        ),
                      ),
                      const Text('Share'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 14,
              ),
            ),
            ...board.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobileSpacing: 10,
                  ),
                ),
                child: _boardTile(entry),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 6,
              ),
            ),
            Text(
              'Friendly ranking helps retention without making the app feel stressful.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5563)),
            ),
          ],
        ),
      );

  Widget _quickActions(BuildContext context) {
    final actions = [
      _Action(
        'Meditate',
        Icons.self_improvement_rounded,
        const Color(0xFF4CAF50),
        '/meditation',
      ),
      _Action('Garden', Icons.eco_rounded, const Color(0xFF81C784), '/garden'),
      _Action(
        'Breathing',
        Icons.air_rounded,
        const Color(0xFFA5D6A7),
        '/breathing',
      ),
      _Action(
        'Mood',
        Icons.mood_rounded,
        const Color(0xFFC8E6C9),
        '/mood-tracker',
      ),
      _Action(
        'Progress',
        Icons.insights_rounded,
        const Color(0xFF66BB6A),
        '/progress',
      ),
      _Action(
        'Settings',
        Icons.settings_rounded,
        const Color(0xFF43A047),
        '/settings',
      ),
    ];
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return GlassContainer(
          borderRadius: BorderRadius.circular(50),
          blur: 15,
          opacity: 0.15,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              action.color.withOpacity(0.8),
              action.color.withOpacity(0.6),
            ],
          ),
          onTap: () => context.go(action.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 22),
                ),
                SizedBox(height: 6),
                Flexible(
                  child: Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _planCard(BuildContext context, _Plan item) => GlassContainer(
        width: ResponsiveHelper.getResponsiveContainerWidth(
          context,
          mobileWidth: 260,
        ),
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 30),
        ),
        blur: 15,
        opacity: 0.15,
        gradient: LinearGradient(
          colors: [item.color, item.color.withOpacity(0.72)],
        ),
        onTap: () => context.go(item.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(
                context,
                mobileWidth: 52,
              ),
              height: ResponsiveHelper.getResponsiveContainerHeight(
                context,
                mobileHeight: 52,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
            const Spacer(),
            Text(
              item.metric,
              style: TextStyle(
                color: Colors.white70,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 13,
                  tabletSize: 14,
                  desktopSize: 15,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 8,
              ),
            ),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 22,
                  tabletSize: 24,
                  desktopSize: 26,
                ),
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 8,
              ),
            ),
            Text(
              item.subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 14,
                  tabletSize: 15,
                  desktopSize: 16,
                ),
                height: 1.4,
              ),
            ),
          ],
        ),
      );

  Widget _rewardTile(_Reward reward) {
    final percent = (reward.progress * 100).round();
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobileSpacing: 12,
        ),
      ),
      child: GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 22),
        ),
        blur: 8,
        opacity: 0.05,
        gradient: LinearGradient(
          colors: [
            reward.color.withOpacity(0.08),
            reward.color.withOpacity(0.04),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(
                context,
                mobileWidth: 48,
              ),
              height: ResponsiveHelper.getResponsiveContainerHeight(
                context,
                mobileHeight: 48,
              ),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(reward.icon, color: reward.color),
            ),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 14,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobileSize: 16,
                        tabletSize: 17,
                        desktopSize: 18,
                      ),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF183028),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobileSpacing: 4,
                    ),
                  ),
                  Text(
                    reward.subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobileSize: 13,
                        tabletSize: 14,
                        desktopSize: 15,
                      ),
                      height: 1.4,
                      color: const Color(0xFF4D6259),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobileSpacing: 10,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: reward.progress,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(reward.color),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 12,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                color: reward.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boardTile(_Board entry) => GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 18),
        ),
        blur: 6,
        opacity: entry.emphasized ? 0.12 : 0.05,
        gradient: LinearGradient(
          colors: entry.emphasized
              ? [entry.color.withOpacity(0.12), entry.color.withOpacity(0.06)]
              : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)],
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(
                context,
                mobileWidth: 42,
              ),
              height: ResponsiveHelper.getResponsiveContainerHeight(
                context,
                mobileHeight: 42,
              ),
              decoration: BoxDecoration(
                color: entry.color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.bolt_rounded, color: entry.color),
            ),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 12,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2D38),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobileSpacing: 3,
                    ),
                  ),
                  Text(
                    entry.highlight,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF5B6876)),
                  ),
                ],
              ),
            ),
            Text(
              entry.score,
              style: TextStyle(color: entry.color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );

  Widget _section(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      );

  Widget _card({required Widget child}) => GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 28),
        ),
        blur: 12,
        opacity: 0.08,
        child: child,
      );

  Widget _cardIntro(String text, String cta, VoidCallback onTap) => Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 15,
                  tabletSize: 16,
                  desktopSize: 17,
                ),
                height: 1.45,
                color: const Color(0xFF355047),
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobileSpacing: 12,
            ),
          ),
          GlassButton(
            onPressed: onTap,
            blur: 8,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(12),
            child: Text(cta),
          ),
        ],
      );

  Widget _icon(IconData icon, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      );

  Widget _pill(IconData icon, String label) => GlassContainer(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(
            context,
            mobilePadding: 12,
          ),
          vertical: ResponsiveHelper.getResponsivePadding(
            context,
            mobilePadding: 10,
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        blur: 8,
        opacity: 0.12,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 8,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _tag(IconData icon, String label) => GlassCard(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(
            context,
            mobilePadding: 12,
          ),
          vertical: ResponsiveHelper.getResponsivePadding(
            context,
            mobilePadding: 10,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        blur: 6,
        opacity: 0.1,
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F4EC), Color(0xFFE8F2E4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF34564B)),
            SizedBox(
              width: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 8,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF34564B),
              ),
            ),
          ],
        ),
      );

  Widget _stat(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? footer,
  }) =>
      GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24),
        ),
        blur: 10,
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveContainerWidth(
                context,
                mobileWidth: 40,
              ),
              height: ResponsiveHelper.getResponsiveContainerHeight(
                context,
                mobileHeight: 40,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 20,
                  tabletSize: 22,
                  desktopSize: 24,
                ),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 4,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 13,
                  tabletSize: 14,
                  desktopSize: 15,
                ),
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            if (footer != null) ...[
              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobileSpacing: 10,
                ),
              ),
              Text(
                footer,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobileSize: 12,
                    tabletSize: 13,
                    desktopSize: 14,
                  ),
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _mini(String label, String value, Color color) => GlassCard(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 18),
        ),
        blur: 6,
        opacity: 0.08,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.09), color.withOpacity(0.04)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF50635A),
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 13,
                  tabletSize: 14,
                  desktopSize: 15,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobileSpacing: 6,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 18,
                  tabletSize: 20,
                  desktopSize: 22,
                ),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  List<_Plan> _buildPlan(
    UserProvider userProvider,
    SessionProvider sessionProvider,
    MoodProvider moodProvider,
  ) {
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
        '/meditation',
      ),
      _Plan(
        streak > 2
            ? 'Boost your garden combo'
            : 'Start your first garden quest',
        'Plant, water, and trigger reward momentum.',
        'Lv ${userProvider.gardenLevel} garden',
        const Color(0xFFB57A37),
        Icons.yard_rounded,
        '/garden',
      ),
      _Plan(
        totalMinutes > 60 ? 'Track your recovery mood' : 'Log how today feels',
        'Mood data sharpens your companion suggestions.',
        moodProvider.todayMood == null ? 'Not logged yet' : 'Mood ready',
        const Color(0xFF6975D9),
        Icons.mood_rounded,
        '/mood-tracker',
      ),
    ];
  }

  String _buildCompanionMessage(
    UserProvider userProvider,
    List<SessionModel> sessions,
    MoodModel? mood,
  ) {
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
        Color(0xFFF1B870),
      );
    }
    if (month >= 6 && month <= 8) {
      return const _Seasonal(
        'Summer Flow Event',
        'Sunlit challenges, warmer breathing scenes, and higher combo gains on mindful care actions.',
        'Summer flow',
        Icons.wb_sunny_rounded,
        Color(0xFF3D8C97),
        Color(0xFFF0B35C),
      );
    }
    if (month >= 9 && month <= 11) {
      return const _Seasonal(
        'Harvest Calm Event',
        'Seasonal quests reward rare seeds, cozy ambience, and stronger progression bursts.',
        'Harvest live',
        Icons.park_rounded,
        Color(0xFF7B5A43),
        Color(0xFFD89558),
      );
    }
    return const _Seasonal(
      'Winter Glow Event',
      'Gentle night palettes, focus rituals, and bonus calm points for consistent check-ins.',
      'Winter glow',
      Icons.ac_unit_rounded,
      Color(0xFF4B698A),
      Color(0xFF85AABF),
    );
  }

  List<_Reward> _buildRewards(UserProvider userProvider) => [
        _Reward(
          'Moonleaf Seed Pack',
          userProvider.currentStreak >= 3
              ? 'Unlocked from your active streak momentum.'
              : 'Reach a 3-day streak to unlock this seasonal seed pack.',
          (userProvider.currentStreak / 3).clamp(0, 1).toDouble(),
          Icons.eco_rounded,
          const Color(0xFF2F7C67),
        ),
        _Reward(
          'Golden Watering Can',
          userProvider.totalSessions >= 10
              ? 'Unlocked by steady mindfulness sessions.'
              : 'Complete 10 total sessions to earn this prestige care tool.',
          (userProvider.totalSessions / 10).clamp(0, 1).toDouble(),
          Icons.water_drop_rounded,
          const Color(0xFFC18A3F),
        ),
        _Reward(
          'Aurora Companion Skin',
          userProvider.gardenLevel >= 5
              ? 'Unlocked for growing a stronger sanctuary.'
              : 'Reach garden level 5 to give your guide a premium look.',
          (userProvider.gardenLevel / 5).clamp(0, 1).toDouble(),
          Icons.auto_awesome_rounded,
          const Color(0xFF727CE0),
        ),
      ];

  List<_Board> _buildLeaderboard(UserProvider userProvider) => [
        const _Board('Ava', '184 calm pts', 'Bloom streak', Color(0xFF5B76D8)),
        _Board(
          'You',
          '${userProvider.totalMinutes + (userProvider.currentStreak * 12)} calm pts',
          '${userProvider.currentStreak} day streak',
          const Color(0xFF2C7A65),
          emphasized: true,
        ),
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
  const _Plan(
    this.title,
    this.subtitle,
    this.metric,
    this.color,
    this.icon,
    this.route,
  );
  final String title;
  final String subtitle;
  final String metric;
  final Color color;
  final IconData icon;
  final String route;
}

class _Seasonal {
  const _Seasonal(
    this.title,
    this.description,
    this.shortLabel,
    this.icon,
    this.start,
    this.end,
  );
  final String title;
  final String description;
  final String shortLabel;
  final IconData icon;
  final Color start;
  final Color end;
}

class _Reward {
  const _Reward(
    this.title,
    this.subtitle,
    this.progress,
    this.icon,
    this.color,
  );
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color color;
}

class _Board {
  const _Board(
    this.name,
    this.score,
    this.highlight,
    this.color, {
    this.emphasized = false,
  });
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
