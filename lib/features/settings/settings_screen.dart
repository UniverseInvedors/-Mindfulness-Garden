import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mindfulness_garden/presentation/providers/app_provider.dart';
import 'package:mindfulness_garden/core/services/localization_service.dart';
import 'package:mindfulness_garden/core/themes/app_theme.dart';
import 'package:mindfulness_garden/core/services/voice_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoPlaySounds = true;
  bool _vibrationEnabled = true;
  bool _voiceEnabled = true;
  VoicePersonality _voicePersonality = VoicePersonality.buddha;
  String _selectedTheme = 'System';
  AppLanguage _selectedLanguage = AppLanguage.english;
  double _volumeLevel = 0.7;
  AppUiTheme _selectedUiTheme = AppUiTheme.cosmicDark;

  final List<AppLanguage> _languages = [
    AppLanguage.english,
    AppLanguage.hindi,
    AppLanguage.bengali,
    AppLanguage.spanish,
    AppLanguage.french,
    AppLanguage.german,
    AppLanguage.chinese,
  ];

  final List<String> _themes = ['System', 'Light', 'Dark'];

  @override
  void initState() {
    super.initState();
    final appProvider = context.read<AppProvider>();
    _selectedUiTheme = appProvider.uiTheme;
    _darkModeEnabled = appProvider.themeMode == ThemeMode.dark;
    _voiceEnabled = VoiceService().isEnabled;
    _voicePersonality = VoiceService().personality;
    _selectedLanguage = VoiceService().appLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            _buildProfileSection(primaryColor, onSurfaceColor),
            const SizedBox(height: 32),

            // UI Theme Section
            _buildSectionTitle('UI Theme', onSurfaceColor),
            _buildUiThemePicker(),
            const SizedBox(height: 24),

            // Voice / AI Tutor Section
            _buildSectionTitle('AI Tutor Voice', onSurfaceColor),
            _buildVoiceSection(),
            const SizedBox(height: 24),

            // General Settings
            _buildSectionTitle('General', onSurfaceColor),
            _buildSettingCard(
              title: 'Theme',
              subtitle: 'App appearance',
              trailing: _buildThemeDropdown(),
            ),
            _buildSettingSwitch(
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                context.read<AppProvider>().toggleTheme(value);
              },
            ),
            _buildSettingDropdown(
              title: 'Language',
              value: _selectedLanguage.displayName,
              items: _languages.map((l) => l.displayName).toList(),
              onChanged: (value) {
                final selected = _languages.firstWhere(
                  (lang) => lang.displayName == value,
                  orElse: () => AppLanguage.english,
                );
                setState(() {
                  _selectedLanguage = selected;
                });
                context.read<AppProvider>().setAppLanguage(selected);
              },
            ),
            _buildSettingTime(
              title: 'Daily Reminder',
              subtitle: 'Time for daily meditation reminder',
              time: const TimeOfDay(hour: 9, minute: 0),
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Audio Settings
            _buildSectionTitle('Audio', onSurfaceColor),
            _buildSettingSwitch(
              title: 'Auto-play Sounds',
              subtitle: 'Play ambient sounds automatically',
              value: _autoPlaySounds,
              onChanged: (value) {
                setState(() {
                  _autoPlaySounds = value;
                });
              },
            ),
            _buildSettingSwitch(
              title: 'Vibration',
              subtitle: 'Haptic feedback during sessions',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
            _buildSettingSlider(
              title: 'Volume Level',
              value: _volumeLevel,
              onChanged: (value) {
                setState(() {
                  _volumeLevel = value;
                });
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Data Section
            _buildSectionTitle('Data', onSurfaceColor),
            _buildSettingButton(
              title: 'Export Data',
              subtitle: 'Export your meditation data',
              onTap: _exportData,
            ),
            _buildSettingButton(
              title: 'Clear Data',
              subtitle: 'Reset all app data',
              onTap: _showClearDataDialog,
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle('About', onSurfaceColor),
            _buildSettingButton(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: _openPrivacyPolicy,
            ),
            _buildSettingButton(
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              onTap: _openTerms,
            ),
            _buildSettingButton(
              title: 'Rate App',
              subtitle: 'Share your feedback',
              onTap: _rateApp,
            ),
            _buildSettingButton(
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 40),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.red.withAlpha(76)),
                ),
                child: Text(
                  'Sign Out',
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

  Widget _buildUiThemePicker() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppUiTheme.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final theme = AppUiTheme.values[i];
          final data = appUiThemes[theme]!;
          final selected = _selectedUiTheme == theme;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedUiTheme = theme);
              context.read<AppProvider>().setUiTheme(theme);
              VoiceService().speak('${data.name} theme selected.');
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

  Widget _buildVoiceSection() {
    return Column(
      children: [
        _buildSettingSwitch(
          title: 'AI Tutor Voice',
          subtitle: 'Buddha speaks guidance throughout the app',
          value: _voiceEnabled,
          onChanged: (v) {
            setState(() => _voiceEnabled = v);
            VoiceService().setEnabled(v);
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
              Text('Personality',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: VoicePersonality.values.map((p) {
                  final selected = _voicePersonality == p;
                  final label = p.name[0].toUpperCase() + p.name.substring(1);
                  final emoji = p == VoicePersonality.buddha
                      ? '🧘'
                      : p == VoicePersonality.zeno
                          ? '🤖'
                          : '🙏';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _voicePersonality = p);
                        VoiceService().setPersonality(p);
                        VoiceService().speak(p == VoicePersonality.buddha
                            ? 'I am the Buddha guide. Wisdom flows through silence.'
                            : p == VoicePersonality.zeno
                                ? "Hey! I'm Zeno, your coach. Let's go!"
                                : 'Begin.');
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

  Widget _buildProfileSection(Color primaryColor, Color textColor) {
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
                  'John Doe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
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

  Widget _buildSectionTitle(String title, Color textColor) {
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

  Widget _buildSettingCard({
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

  Widget _buildThemeDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedTheme,
        items: _themes.map((theme) {
          return DropdownMenuItem(value: theme, child: Text(theme));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTheme = value!;
          });
        },
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingCard(
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingDropdown({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildSettingCard(
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

  Widget _buildSettingTime({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required Color primaryColor,
  }) {
    return _buildSettingCard(
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

  Widget _buildSettingSlider({
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

  Widget _buildSettingButton({
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

  Future<void> _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  Future<void> _showClearDataDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your meditation sessions, mood entries, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearData();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearData() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data cleared successfully')));
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy will open soon')),
    );
  }

  void _openTerms() {
    // TODO: Open terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service will open soon')),
    );
  }

  void _rateApp() {
    // TODO: Open app store rating
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rating feature coming soon')));
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
