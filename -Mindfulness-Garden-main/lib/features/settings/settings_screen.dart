import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/core/widgets/character/teacher_avatar.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/l10n/app_localizations.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart'
    as user_prov;
import 'package:pranaverse/services/audio_manager_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoPlaySounds = true;
  bool _vibrationEnabled = true;
  double _volumeLevel = 0.7;
  TimeOfDay _dailyReminder = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = context.watch<AppSettingsProvider>();
    final teacher = ref.watch(teacherPreferenceProvider);
    final userProvider = context.watch<user_prov.UserProvider>();
    final colors = Theme.of(context).colorScheme;
    final languages = [
      AppLanguage.english,
      AppLanguage.hindi,
      AppLanguage.bengali,
    ];
    final languageItems = {
      for (final language in languages)
        AppCopy.languageName(appSettings.language, language): language,
    };

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.background,
              Color.alphaBlend(
                colors.primary.withOpacity(0.15),
                colors.surface,
              ),
              Color.alphaBlend(
                const Color(0xFF4CD97B).withOpacity(0.09),
                colors.background,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: _buildHeader(context, l10n),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        _buildProfileSection(context, userProvider, l10n),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.uiTheme,
                          Icons.palette_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildUiThemePicker(
                          context,
                          appSettings.uiTheme,
                          appSettings,
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.personality,
                          Icons.psychology_alt_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTeacherPicker(context, teacher),
                        const SizedBox(height: 12),
                        _buildTeacherStudioButton(context),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.aiTutorVoice,
                          Icons.record_voice_over_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildVoiceSection(context, appSettings.voiceEnabled),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.general,
                          Icons.tune_rounded,
                        ),
                        const SizedBox(height: 12),
                        // Auto Theme & Background Settings
                        _buildSettingSwitch(
                          context,
                          title: 'Auto Theme',
                          subtitle:
                              'Automatically switch between light/dark theme based on time',
                          icon: Icons.brightness_auto_rounded,
                          value: appSettings.autoThemeService.autoThemeEnabled,
                          onChanged: (value) {
                            appSettings.autoThemeService.setAutoTheme(value);
                          },
                        ),
                        _buildSettingSwitch(
                          context,
                          title: 'Auto Background',
                          subtitle:
                              'Change backgrounds based on season and date',
                          icon: Icons.wallpaper_rounded,
                          value: appSettings
                              .autoThemeService.autoBackgroundEnabled,
                          onChanged: (value) {
                            appSettings.autoThemeService.setAutoBackground(
                              value,
                            );
                          },
                        ),
                        _buildSettingDropdown(
                          context,
                          title: l10n.language,
                          icon: Icons.language_rounded,
                          value: AppCopy.languageName(
                            appSettings.language,
                            appSettings.language,
                          ),
                          items: languageItems.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            final selected =
                                languageItems[value] ?? AppLanguage.english;
                            context.read<AppSettingsProvider>().setLanguage(
                                  selected,
                                );
                          },
                        ),
                        _buildSettingTime(
                          context,
                          title: l10n.dailyReminder,
                          subtitle: l10n.dailyReminderSubtitle,
                          icon: Icons.notifications_active_outlined,
                          time: _dailyReminder,
                        ),
                        _buildSettingSwitch(
                          context,
                          title: l10n.autoPlaySounds,
                          subtitle: l10n.autoPlaySoundsSubtitle,
                          icon: Icons.music_note_outlined,
                          value: _autoPlaySounds,
                          onChanged: (value) =>
                              setState(() => _autoPlaySounds = value),
                        ),
                        _buildSettingSwitch(
                          context,
                          title: l10n.vibration,
                          subtitle: l10n.vibrationSubtitle,
                          icon: Icons.vibration_rounded,
                          value: _vibrationEnabled,
                          onChanged: (value) =>
                              setState(() => _vibrationEnabled = value),
                        ),
                        _buildSettingSwitch(
                          context,
                          title: AppCopy.of(context, 'Notifications'),
                          subtitle: AppCopy.of(
                            context,
                            'Daily reminders and garden streaks',
                          ),
                          icon: Icons.notifications_none_rounded,
                          value: _notificationsEnabled,
                          onChanged: (value) =>
                              setState(() => _notificationsEnabled = value),
                        ),
                        _buildSettingSlider(
                          context,
                          title: l10n.volumeLevel,
                          icon: Icons.volume_up_outlined,
                          value: _volumeLevel,
                          onChanged: (value) =>
                              setState(() => _volumeLevel = value),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          'Garden & Weather',
                          Icons.park_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingSwitch(
                          context,
                          title: 'Auto Weather',
                          subtitle:
                              'Automatically set garden weather based on your location and time',
                          icon: Icons.wb_sunny_outlined,
                          value:
                              appSettings.autoThemeService.autoWeatherEnabled,
                          onChanged: (value) {
                            appSettings.autoThemeService.setAutoWeather(value);
                          },
                        ),
                        if (!appSettings.autoThemeService.autoWeatherEnabled)
                          _buildSettingDropdown(
                            context,
                            title: 'Garden Weather',
                            icon: Icons.cloud_outlined,
                            value: appSettings.autoThemeService.manualWeather,
                            items: const [
                              'Sunny',
                              'Cloudy',
                              'Rainy',
                              'Stormy',
                              'Snowy',
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                appSettings.autoThemeService
                                    .setManualWeather(value);
                              }
                            },
                          ),
                        _buildSettingSwitch(
                          context,
                          title: 'Auto Day/Night Cycle',
                          subtitle: 'Match garden time with real-world time',
                          icon: Icons.brightness_6_outlined,
                          value:
                              appSettings.autoThemeService.autoDayNightEnabled,
                          onChanged: (value) {
                            appSettings.autoThemeService.setAutoDayNight(value);
                          },
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.data,
                          Icons.storage_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingButton(
                          context,
                          title: l10n.exportData,
                          subtitle: l10n.exportDataSubtitle,
                          icon: Icons.file_download_outlined,
                          onTap: () => _exportData(context),
                        ),
                        _buildSettingButton(
                          context,
                          title: l10n.clearData,
                          subtitle: l10n.clearDataSubtitle,
                          icon: Icons.delete_sweep_outlined,
                          danger: true,
                          onTap: () => _showClearDataDialog(context),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          context,
                          l10n.about,
                          Icons.info_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingButton(
                          context,
                          title: l10n.privacyPolicy,
                          subtitle: l10n.privacyPolicySubtitle,
                          icon: Icons.privacy_tip_outlined,
                          onTap: () => _openPrivacyPolicy(context),
                        ),
                        _buildSettingButton(
                          context,
                          title: l10n.termsOfService,
                          subtitle: l10n.termsOfServiceSubtitle,
                          icon: Icons.description_outlined,
                          onTap: () => _openTerms(context),
                        ),
                        _buildSettingButton(
                          context,
                          title: l10n.rateApp,
                          subtitle: l10n.rateAppSubtitle,
                          icon: Icons.star_border_rounded,
                          onTap: () => _rateApp(context),
                        ),
                        _buildSettingButton(
                          context,
                          title: l10n.appVersion,
                          subtitle: 'v1.0.0',
                          icon: Icons.verified_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        _buildSignOutButton(context, l10n),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _roundIconButton(
          context,
          icon: Icons.arrow_back_rounded,
          onTap: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppCopy.of(context, 'Personalize your garden'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _roundIconButton(
          context,
          icon: Icons.restart_alt_rounded,
          onTap: () => context.read<AppSettingsProvider>().resetToDefaults(),
        ),
      ],
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    user_prov.UserProvider userProvider,
    AppLocalizations l10n,
  ) {
    final colors = Theme.of(context).colorScheme;
    final user = userProvider.user;

    return _settingsCard(
      context,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, const Color(0xFF4CD97B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? l10n.myProfile,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  (user?.email ?? '').isEmpty
                      ? AppCopy.of(context, 'Local garden profile')
                      : user!.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _roundIconButton(
            context,
            icon: Icons.edit_rounded,
            onTap: () => context.push('/profile'),
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUiThemePicker(
    BuildContext context,
    AppUiTheme selectedUiTheme,
    AppSettingsProvider settings,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 560 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AppUiTheme.values.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, i) {
        final theme = AppUiTheme.values[i];
        final data = appUiThemes[theme]!;
        final selected = selectedUiTheme == theme;
        return _themeTile(context, theme, data, selected, settings);
      },
    );
  }

  Widget _themeTile(
    BuildContext context,
    AppUiTheme theme,
    AppUiThemeData data,
    bool selected,
    AppSettingsProvider settings,
  ) {
    final accent = data.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        settings.setUiTheme(theme);
        VoiceService().speak(
          AppCopy.tr(
            settings.language,
            'themeSelectedVoice',
            vars: {'theme': AppCopy.tr(settings.language, data.name)},
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.13 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white.withOpacity(0.14),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_themeIcon(theme), color: Colors.white, size: 19),
                ),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? accent : Colors.white38,
                  size: 18,
                ),
              ],
            ),
            const Spacer(),
            Text(
              AppCopy.tr(settings.language, data.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherPicker(BuildContext context, TeacherPersonality teacher) {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TeacherPersonality.values.map((personality) {
          final appearance = TeacherAppearance.personalities[personality]!;
          final selected = personality == teacher;
          return Padding(
            padding: EdgeInsets.only(
              right: personality == TeacherPersonality.values.last ? 0 : 10,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                AudioManagerService().playButtonClick();
                HapticFeedback.selectionClick();
                await ref
                    .read(teacherPreferenceProvider.notifier)
                    .setTeacher(personality);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 96,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected
                      ? appearance.auraPrimary.withOpacity(0.16)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? appearance.auraPrimary
                        : Colors.white.withOpacity(0.14),
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TeacherAvatar(
                        teacher: personality,
                        selected: selected,
                        background: false,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppCopy.of(context, appearance.name),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeacherStudioButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: () => context.push('/teachers'),
      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
      label: Text(AppCopy.of(context, 'Open Teacher Studio')),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: colors.secondary.withOpacity(0.55)),
        backgroundColor: colors.secondary.withOpacity(0.08),
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context, bool voiceEnabled) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSettingSwitch(
      context,
      title: l10n.aiTutorVoice,
      subtitle: l10n.buddhaGuide,
      icon: Icons.spatial_audio_off_outlined,
      value: voiceEnabled,
      onChanged: (value) {
        context.read<AppSettingsProvider>().setVoiceEnabled(value);
      },
    );
  }

  Widget _buildSettingSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingCard(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          AudioManagerService().playButtonClick();
          HapticFeedback.selectionClick();
          onChanged(newValue);
        },
        activeThumbColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildSettingDropdown(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildSettingCard(
      context,
      title: title,
      subtitle: value,
      icon: icon,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Theme.of(context).colorScheme.surface,
          iconEnabledColor: Colors.white70,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (newValue) {
            AudioManagerService().playButtonClick();
            HapticFeedback.selectionClick();
            onChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildSettingTime(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required TimeOfDay time,
  }) {
    final colors = Theme.of(context).colorScheme;
    final value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return _buildSettingCard(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: TextButton(
        onPressed: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (newTime != null) {
            setState(() => _dailyReminder = newTime);
          }
        },
        child: Text(value, style: TextStyle(color: colors.secondary)),
      ),
    );
  }

  Widget _buildSettingSlider(
    BuildContext context, {
    required String title,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    return _settingsCard(
      context,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _settingIcon(context, icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            onChangeEnd: (newValue) {
              HapticFeedback.selectionClick();
            },
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: colors.secondary,
            inactiveColor: Colors.white.withOpacity(0.18),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? Theme.of(context).colorScheme.error : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        AudioManagerService().playButtonClick();
        HapticFeedback.selectionClick();
        onTap();
      },
      child: _buildSettingCard(
        context,
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: danger ? Theme.of(context).colorScheme.error : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: color.withOpacity(0.70),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _signOut(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(l10n.signOut),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF8A80),
          side: BorderSide(color: const Color(0xFFFF8A80).withOpacity(0.55)),
          backgroundColor: const Color(0xFFFF8A80).withOpacity(0.07),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    Color? iconColor,
  }) {
    return _settingsCard(
      context,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _settingIcon(context, icon, iconColor: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.66),
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Widget _settingsCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _settingIcon(BuildContext context, IconData icon, {Color? iconColor}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: (iconColor ?? colors.secondary).withOpacity(0.16),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: iconColor ?? colors.secondary, size: 20),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.82),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _roundIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final size = compact ? 42.0 : 44.0;
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: compact ? 19 : 21),
      ),
    );
  }

  IconData _themeIcon(AppUiTheme theme) {
    switch (theme) {
      case AppUiTheme.gardenSerenity:
        return Icons.spa_rounded;
      case AppUiTheme.skyCalm:
        return Icons.cloud_outlined;
      case AppUiTheme.sunriseGlow:
        return Icons.wb_sunny_outlined;
      case AppUiTheme.roseHarmony:
        return Icons.favorite_border_rounded;
      case AppUiTheme.lavenderDream:
        return Icons.auto_awesome_rounded;
      case AppUiTheme.midnightZen:
        return Icons.nightlight_round;
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportComingSoon)));
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearData(context);
            },
            child: Text(l10n.clear, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.dataCleared)));
  }

  void _openPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.privacyPolicySoon)));
  }

  void _openTerms(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.termsSoon)));
  }

  void _rateApp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ratingSoon)));
  }

  void _signOut(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutQuestion),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.signedOut)));
            },
            child: Text(
              l10n.signOut,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
