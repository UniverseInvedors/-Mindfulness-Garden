import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mindfulness_garden/core/widgets/exercise_scene_shell.dart';
import 'package:mindfulness_garden/core/widgets/meditation_scene_widget.dart';

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
  late Animation<Color?> _colorAnimation;

  bool _isPlaying = false;
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
      'color': Colors.green,
      'description': 'Nature sounds',
    },
    {
      'name': 'Ocean',
      'icon': Icons.waves,
      'color': Colors.blue,
      'description': 'Waves crashing',
    },
    {
      'name': 'Rain',
      'icon': Icons.water_drop,
      'color': Colors.blueAccent,
      'description': 'Gentle rainfall',
    },
    {
      'name': 'Bowl',
      'icon': Icons.music_note,
      'color': Colors.orange,
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
      begin: Colors.blue.withValues(alpha: 0.3),
      end: Colors.green.withValues(alpha: 0.3),
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
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 20),
          ),
        ),
      ],
      bottomPanel: _buildBottomPanel(),
    );
  }

  Widget _buildBottomPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Timer + phase
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_breathPhase,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text('Cycle $_breathCycle',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Breathing visualizer (compact)
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (_, __) => Container(
              width: 80 + _breathProgress * 40,
              height: 80 + _breathProgress * 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_breathPhase == 'Inhale' ? Colors.blue : Colors.green)
                    .withAlpha(80),
                border: Border.all(
                  color: _breathPhase == 'Inhale' ? Colors.blue : Colors.green,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_breathPhase == 'Inhale' ? Colors.blue : Colors.green)
                            .withAlpha(80),
                    blurRadius: 16,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  _breathPhase == 'Inhale' ? Icons.air : Icons.water_drop,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlBtn(Icons.replay_30, () {}),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (_isPlaying ? Colors.red : Colors.blue).withAlpha(200),
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying ? Colors.red : Colors.blue)
                            .withAlpha(100),
                        blurRadius: 16,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              _controlBtn(Icons.forward_30, () {}),
            ],
          ),

          const SizedBox(height: 14),

          // Sound selector
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sounds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final s = _sounds[i];
                final sel = _selectedSound == i;
                return GestureDetector(
                  onTap: () => _selectSound(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 64,
                    decoration: BoxDecoration(
                      color: sel
                          ? (s['color'] as Color).withAlpha(60)
                          : Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? s['color'] as Color
                            : Colors.white.withAlpha(30),
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s['icon'] as IconData,
                            size: 22,
                            color: sel ? s['color'] as Color : Colors.white54),
                        const SizedBox(height: 4),
                        Text(s['name'] as String,
                            style: TextStyle(
                              fontSize: 10,
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

  Widget _controlBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}


