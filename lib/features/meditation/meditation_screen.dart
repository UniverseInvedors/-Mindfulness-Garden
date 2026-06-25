import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_button.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_icon.dart';
import 'package:pranaverse/core/services/localization_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/widgets/exercise_scene_shell.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _breathAnimation;
  // color animation previously unused; keep for future visual refinements
  late Animation<Color?> _colorAnimation;

  bool _isPlaying = false;
  // total duration placeholder (not used in compact UI)
  final Duration _duration = const Duration(minutes: 10);
  final Duration _position = Duration.zero;
  int _breathCycle = 0;
  String _breathPhase = 'Inhale';
  double _breathProgress = 0.0;
  int _selectedSound = 0;

  final List<Map<String, dynamic>> _sounds = [
    {
      'name': 'Forest',
      'icon': Icons.forest,
      'color': const Color(0xFF4CAF50),
      'description': 'Nature sounds',
    },
    {
      'name': 'Rain',
      'icon': Icons.water_drop,
      'color': const Color(0xFF66BB6A),
      'description': 'Gentle rainfall',
    },
    {
      'name': 'Stream',
      'icon': Icons.waves,
      'color': const Color(0xFF81C784),
      'description': 'Flowing water',
    },
    {
      'name': 'Bowl',
      'icon': Icons.music_note,
      'color': const Color(0xFFA5D6A7),
      'description': 'Singing bowl',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _breathAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF4CAF50).withValues(alpha: 0.3),
      end: const Color(0xFF81C784).withValues(alpha: 0.3),
    ).animate(_animationController);

    _setupBreathingCycle();
  }

  void _setupBreathingCycle() {
    _animationController.addListener(() {
      final value = _animationController.value;
      if (value < 0.5) {
        // Inhale phase
        setState(() {
          _breathPhase = 'Inhale';
          _breathProgress = value * 2;
        });
      } else {
        // Exhale phase
        setState(() {
          _breathPhase = 'Exhale';
          _breathProgress = (value - 0.5) * 2;
        });
      }

      // Complete cycle
      if (value == 1.0) {
        setState(() {
          _breathCycle++;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _animationController.stop();
    } else {
      // In production: await _audioPlayer.play(AssetSource('sounds/ambient.mp3'));
      await Future.delayed(const Duration(milliseconds: 300));
      _animationController.repeat();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _selectSound(int index) {
    setState(() {
      _selectedSound = index;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showBenefits() {
    final lang = VoiceService().appLanguage;
    final text = LocalizationService.translate('benefits_meditation', lang);
    VoiceService().speak(text);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Benefits',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close',
                    style: TextStyle(color: Colors.white70)))
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  BreathPhase get _scenePhase =>
      _breathPhase == 'Inhale' ? BreathPhase.inhale : BreathPhase.exhale;

  @override
  Widget build(BuildContext context) {
    return ExerciseSceneShell(
      title: 'Meditation',
      breathPhase: _scenePhase,
      instruction: _isPlaying ? _breathPhase : 'Tap play to begin',
      isActive: _isPlaying,
      initialEnvironment: SceneEnvironment.forest,
      initialTimeOfDay: SceneTimeOfDay.morning,
      onBack: () => Navigator.of(context).pop(),
      headerActions: [
        GlassIcon(
          icon: Icons.help_outline,
          onTap: _showBenefits,
          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 18, tabletSize: 20, desktopSize: 22),
          iconColor: Colors.white,
          blur: 10,
          opacity: 0.1,
          isCircular: true,
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 4)),
        GlassIcon(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onTap: _togglePlayback,
          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
          iconColor: Colors.white,
          blur: 10,
          opacity: 0.1,
          isCircular: true,
        ),
      ],
      bottomPanel: _buildBottomPanel(),
    );
  }

  Widget _buildBottomPanel() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 4),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 36),
            height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 4),
            margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
            borderRadius: BorderRadius.circular(2),
            blur: 6,
            opacity: 0.15,
          ),

          // Timer + phase
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 36, tabletSize: 38, desktopSize: 40),
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontFamily: 'RobotoMono',
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_breathPhase,
                      style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 18, tabletSize: 19, desktopSize: 20),
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text('Cycle $_breathCycle',
                      style:
                          TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14), color: Colors.white54)),
                ],
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
          GlassButton(
            onPressed: _showBenefits,
            blur: 10,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 18, tabletSize: 19, desktopSize: 20)),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
                const Text('Benefits'),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 14)),

          // Breathing visualizer (compact)
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (_, __) => GlassContainer(
              width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 80) + _breathProgress * 40,
              height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 80) + _breathProgress * 40,
              borderRadius: BorderRadius.circular(50),
              blur: 15,
              opacity: 0.3,
              gradient: LinearGradient(
                colors: [
                  (_breathPhase == 'Inhale' ? const Color(0xFF4CAF50) : const Color(0xFF81C784)).withAlpha(80),
                  (_breathPhase == 'Inhale' ? const Color(0xFF4CAF50) : const Color(0xFF81C784)).withAlpha(40),
                ],
              ),
              child: Center(
                child: Icon(
                  _breathPhase == 'Inhale' ? Icons.air : Icons.water_drop,
                  color: Colors.white,
                  size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 28, tabletSize: 30, desktopSize: 32),
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 14)),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlBtn(context, Icons.replay_30, () {}),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),
              GestureDetector(
                onTap: _togglePlayback,
                child: GlassContainer(
                  width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 64),
                  height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 64),
                  borderRadius: BorderRadius.circular(32),
                  blur: 15,
                  opacity: 0.3,
                  gradient: LinearGradient(
                    colors: [
                      (_isPlaying ? Colors.red : Colors.blue).withAlpha(200),
                      (_isPlaying ? Colors.red : Colors.blue).withAlpha(100),
                    ],
                  ),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                      size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 32, tabletSize: 34, desktopSize: 36), color: Colors.white),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),
              _controlBtn(context, Icons.forward_30, () {}),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 14)),

          // Sound selector
          SizedBox(
            height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 72),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sounds.length,
              separatorBuilder: (_, __) => SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 10)),
              itemBuilder: (_, i) {
                final s = _sounds[i];
                final sel = _selectedSound == i;
                return GestureDetector(
                  onTap: () => _selectSound(i),
                  child: GlassContainer(
                    duration: const Duration(milliseconds: 250),
                    width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 64),
                    borderRadius: BorderRadius.circular(14),
                    blur: sel ? 12 : 8,
                    opacity: sel ? 0.3 : 0.15,
                    gradient: LinearGradient(
                      colors: sel
                          ? [(s['color'] as Color).withAlpha(60), (s['color'] as Color).withAlpha(30)]
                          : [Colors.white.withAlpha(15), Colors.white.withAlpha(8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s['icon'] as IconData,
                            size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 22, tabletSize: 23, desktopSize: 24),
                            color: sel ? s['color'] as Color : Colors.white54),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 4)),
                        Text(s['name'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 10, tabletSize: 11, desktopSize: 12),
                              color: sel ? Colors.white : Colors.white54,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlBtn(BuildContext context, IconData icon, VoidCallback onTap) => GlassIcon(
        icon: icon,
        onTap: onTap,
        size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 22, tabletSize: 23, desktopSize: 24),
        iconColor: Colors.white,
        blur: 8,
        opacity: 0.15,
        isCircular: true,
      );
}
