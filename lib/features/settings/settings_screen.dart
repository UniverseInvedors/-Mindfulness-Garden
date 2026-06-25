import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/l10n/app_localizations.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart' as user_prov;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = context.watch<AppSettingsProvider>();
    final teacher = ref.watch(teacherPreferenceProvider);
    final userProvider = context.watch<user_prov.UserProvider>();
    
    final bool _notificationsEnabled = true;
    bool _autoPlaySounds = true;
    bool _vibrationEnabled = true;
    double _volumeLevel = 0.7;
    
    final AppLanguage _selectedLanguage = appSettings.language;
    final AppUiTheme _selectedUiTheme = appSettings.uiTheme;
    final bool _darkModeEnabled = appSettings.themeMode == ThemeMode.dark;
    final bool _voiceEnabled = appSettings.voiceEnabled;
    final VoicePersonality _voicePersonality = appSettings.voicePersonality;

    final List<AppLanguage> _languages = [
      AppLanguage.english,
      AppLanguage.hindi,
      AppLanguage.bengali,
    ];

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/main'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context, primaryColor, onSurfaceColor, userProvider, l10n),
            const SizedBox(height: 32),

            // UI Theme Section
            _buildSectionTitle(context, l10n.uiTheme, onSurfaceColor),
            _buildUiThemePicker(context, _selectedUiTheme),
            const SizedBox(height: 24),

            // Teacher Selection Section
            _buildSectionTitle(context, l10n.personality, onSurfaceColor),
            _buildTeacherPicker(context, ref, teacher),
            const SizedBox(height: 24),

            // Voice / AI Tutor Section
            _buildSectionTitle(context, l10n.aiTutorVoice, onSurfaceColor),
            _buildVoiceSection(context, _voiceEnabled, _voicePersonality),
            const SizedBox(height: 24),

            // General Settings
            _buildSectionTitle(context, l10n.general, onSurfaceColor),
            _buildSettingDropdown(
              context,
              ref,
              title: l10n.language,
              value: _selectedLanguage.displayName,
              items: _languages.map((l) => l.displayName).toList(),
              onChanged: (value) {
                if (value != null) {
                  final selected = _languages.firstWhere(
                    (lang) => lang.displayName == value,
                    orElse: () => AppLanguage.english,
                  );
                  context.read<AppSettingsProvider>().setLanguage(selected);
                }
              },
            ),
            _buildSettingTime(
              context,
              title: l10n.dailyReminder,
              subtitle: l10n.dailyReminderSubtitle,
              time: const TimeOfDay(hour: 9, minute: 0),
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Audio Settings
            _buildSectionTitle(context, l10n.audio, onSurfaceColor),
            _buildSettingSwitch(
              context,
              title: l10n.autoPlaySounds,
              subtitle: l10n.autoPlaySoundsSubtitle,
              value: _autoPlaySounds,
              onChanged: (value) {},
            ),
            _buildSettingSwitch(
              context,
              title: l10n.vibration,
              subtitle: l10n.vibrationSubtitle,
              value: _vibrationEnabled,
              onChanged: (value) {},
            ),
            _buildSettingSlider(
              context,
              title: l10n.volumeLevel,
              value: _volumeLevel,
              onChanged: (value) {},
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Data Section
            _buildSectionTitle(context, l10n.data, onSurfaceColor),
            _buildSettingButton(
              context,
              title: l10n.exportData,
              subtitle: l10n.exportDataSubtitle,
              onTap: () => _exportData(context),
            ),
            _buildSettingButton(
              context,
              title: l10n.clearData,
              subtitle: l10n.clearDataSubtitle,
              onTap: () => _showClearDataDialog(context),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle(context, l10n.about, onSurfaceColor),
            _buildSettingButton(
              context,
              title: l10n.privacyPolicy,
              subtitle: l10n.privacyPolicySubtitle,
              onTap: () => _openPrivacyPolicy(context),
            ),
            _buildSettingButton(
              context,
              title: l10n.termsOfService,
              subtitle: l10n.termsOfServiceSubtitle,
              onTap: () => _openTerms(context),
            ),
            _buildSettingButton(
              context,
              title: l10n.rateApp,
              subtitle: l10n.rateAppSubtitle,
              onTap: () => _rateApp(context),
            ),
            _buildSettingButton(
              context,
              title: l10n.appVersion,
              subtitle: 'v1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 40),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _signOut(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.red.withAlpha(76)),
                ),
                child: Text(
                  l10n.signOut,
                  style: TextStyle(
                    color: Colors.red.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherPicker(BuildContext context, WidgetRef ref, TeacherPersonality teacher) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TeacherPersonality.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final personality = TeacherPersonality.values[i];
          final appearance = TeacherAppearance.personalities[personality]!;
          final selected = personality == teacher;
          return GestureDetector(
            onTap: () async {
              await ref.read(teacherPreferenceProvider.notifier).setTeacher(personality);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: selected
                    ? appearance.auraPrimary.withAlpha(60)
                    : Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? appearance.auraPrimary : Colors.white.withAlpha(30),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTeacherIcon(personality),
                    color: selected ? appearance.auraPrimary : Colors.white70,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appearance.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getTeacherIcon(TeacherPersonality personality) {
    switch (personality) {
      case TeacherPersonality.buddha:
        return Icons.self_improvement;
      case TeacherPersonality.zeno:
        return Icons.person;
      case TeacherPersonality.monk:
        return Icons.accessibility;
    }
  }

  Widget _buildUiThemePicker(BuildContext context, AppUiTheme selectedUiTheme) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppUiTheme.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final theme = AppUiTheme.values[i];
          final data = appUiThemes[theme]!;
          final selected = selectedUiTheme == theme;
          return GestureDetector(
            onTap: () {
              context.read<AppSettingsProvider>().setUiTheme(theme);
              VoiceService().speak('${data.name} ${l10n.themeSelected}');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: data.gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? data.primary : Colors.white.withAlpha(30),
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: data.primary.withAlpha(80),
                            blurRadius: 12,
                            spreadRadius: 2)
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(data.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.normal,
                      )),
                  if (selected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: data.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context, bool voiceEnabled, VoicePersonality voicePersonality) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildSettingSwitch(
          context,
          title: l10n.aiTutorVoice,
          subtitle: l10n.buddhaGuide,
          value: voiceEnabled,
          onChanged: (v) {
            context.read<AppSettingsProvider>().setVoiceEnabled(v);
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.personality,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: VoicePersonality.values.map((p) {
                  final selected = voicePersonality == p;
                  final label = p.name[0].toUpperCase() + p.name.substring(1);
                  final emoji = p == VoicePersonality.buddha
                      ? '🧘'
                      : p == VoicePersonality.zeno
                          ? '🤖'
                          : '🙏';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<AppSettingsProvider>().setVoicePersonality(p);
                        VoiceService().speak(p == VoicePersonality.buddha
                            ? l10n.iAmBuddha
                            : p == VoicePersonality.zeno
                                ? l10n.iAmZeno
                                : l10n.begin);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(40)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(label,
                                style: TextStyle(
                                  color:
                                      selected ? Colors.white : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, Color primaryColor, Color textColor, user_prov.UserProvider userProvider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.user?.name ?? l10n.myProfile,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  userProvider.user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withAlpha(150),
                      ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: textColor.withAlpha(150)),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                      ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }


  Widget _buildSettingSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingCard(
      context,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingDropdown(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildSettingCard(
      context,
      title: title,
      subtitle: '',
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSettingTime(
    BuildContext context, {
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required Color primaryColor,
  }) {
    return _buildSettingCard(
      context,
      title: title,
      subtitle: subtitle,
      trailing: TextButton(
        onPressed: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (newTime != null) {
            // Handle time selection
          }
        },
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildSettingSlider(
    BuildContext context, {
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            onChanged: onChanged,
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(value * 100).toInt()}%',
            activeColor: primaryColor,
            inactiveColor: Colors.grey.withAlpha(76),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.exportComingSoon)),
    );
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
    // TODO: Open privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.privacyPolicySoon)),
    );
  }

  void _openTerms(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Open terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.termsSoon)),
    );
  }

  void _rateApp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Open app store rating
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
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.signedOut)),
              );
            },
            child: Text(l10n.signOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
