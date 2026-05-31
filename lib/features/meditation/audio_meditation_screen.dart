import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class AudioMeditationScreen extends StatefulWidget {
  const AudioMeditationScreen({super.key});

  @override
  State<AudioMeditationScreen> createState() => _AudioMeditationScreenState();
}

class _AudioMeditationScreenState extends State<AudioMeditationScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isPlaying = false;
  Duration _duration = const Duration(minutes: 10);
  Duration _position = Duration.zero;
  double _volume = 0.7;
  int _selectedSoundIndex = 0;
  bool _isFavorite = false;
  double _breathInDuration = 4.0;
  double _breathOutDuration = 6.0;

  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 1,
      'name': 'Ocean Waves',
      'icon': Icons.waves,
      'color': Colors.blue,
      'asset': 'sounds/ocean.mp3',
      'description': 'Calming ocean waves'
    },
    {
      'id': 2,
      'name': 'Forest Rain',
      'icon': Icons.forest,
      'color': Colors.green,
      'asset': 'sounds/rainforest.mp3',
      'description': 'Gentle rain in forest'
    },
    {
      'id': 3,
      'name': 'Zen Garden',
      'icon': Icons.spa,
      'color': Colors.teal,
      'asset': 'sounds/zen.mp3',
      'description': 'Peaceful garden sounds'
    },
    {
      'id': 4,
      'name': 'Singing Bowl',
      'icon': Icons.music_note,
      'color': Colors.orange,
      'asset': 'sounds/bowl.mp3',
      'description': 'Healing vibrations'
    },
    {
      'id': 5,
      'name': 'Mountain Wind',
      'icon': Icons.wind_power,
      'color': Colors.cyan,
      'asset': 'sounds/wind.mp3',
      'description': 'Gentle mountain breeze'
    },
    {
      'id': 6,
      'name': 'Night Crickets',
      'icon': Icons.nightlight,
      'color': Colors.indigo,
      'asset': 'sounds/night.mp3',
      'description': 'Peaceful night sounds'
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _setupAudio();
    _listenToAudioEvents();
  }

  Future<void> _setupAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(_volume);
  }

  void _listenToAudioEvents() {
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // In production, uncomment and use actual assets:
      // await _audioPlayer.play(AssetSource(_sounds[_selectedSoundIndex]['asset']));
      // For demo, simulate loading
      await Future.delayed(const Duration(milliseconds: 300));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  void _onSeekChanged(double value) {
    final newPosition = Duration(
      milliseconds: (value * _duration.inMilliseconds).toInt(),
    );
    _audioPlayer.seek(newPosition);
    setState(() {
      _position = newPosition;
    });
  }

  void _selectSound(int index) {
    setState(() {
      _selectedSoundIndex = index;
    });
    // In production: Stop current and play new sound
    _stopPlayback();
    Future.delayed(const Duration(milliseconds: 300), _togglePlayback);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              expandedHeight: 100,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0a0a1a),
                        const Color(0xFF0a0a1a).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Audio Meditation',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Immerse in sound',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Timer Display
                  _buildTimerDisplay(theme, size),
                  const SizedBox(height: 40),

                  // Breathing Settings
                  _buildBreathingSettings(theme),
                  const SizedBox(height: 40),

                  // Progress Bar
                  _buildProgressBar(theme),
                  const SizedBox(height: 40),

                  // Controls
                  _buildControls(theme, size),
                  const SizedBox(height: 40),

                  // Volume Control
                  _buildVolumeControl(theme),
                  const SizedBox(height: 40),

                  // Sound Selection
                  _buildSoundSelection(theme),
                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(ThemeData theme, Size size) {
    return Center(
      child: Column(
        children: [
          // Animated Timer
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 0.5, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Outer ring
                      CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds / _duration.inMilliseconds
                              : 0.0,
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                            Text(
                              '/ ${_formatDuration(_duration)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Breath Awareness',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow the rhythm of your breath',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingSettings(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BREATHING PATTERN',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBreathSetting(
                  'Breathe In',
                  '${_breathInDuration.toInt()}s',
                  Colors.blue,
                      (value) {
                    setState(() {
                      _breathInDuration = value;
                    });
                  },
                  _breathInDuration,
                  2,
                  8,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildBreathSetting(
                  'Breathe Out',
                  '${_breathOutDuration.toInt()}s',
                  Colors.green,
                      (value) {
                    setState(() {
                      _breathOutDuration = value;
                    });
                  },
                  _breathOutDuration,
                  2,
                  10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPresetButton('4-7-8', () {
                setState(() {
                  _breathInDuration = 4;
                  _breathOutDuration = 8;
                });
              }),
              _buildPresetButton('Box (4-4)', () {
                setState(() {
                  _breathInDuration = 4;
                  _breathOutDuration = 4;
                });
              }),
              _buildPresetButton('Equal (5-5)', () {
                setState(() {
                  _breathInDuration = 5;
                  _breathOutDuration = 5;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreathSetting(
      String label,
      String value,
      Color color,
      Function(double) onChanged,
      double currentValue,
      double min,
      double max,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
            label: '${currentValue.toInt()}s',
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.blue.withOpacity(0.3),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: progress,
            onChanged: _onSeekChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(ThemeData theme, Size size) {
    return Column(
      children: [
        // Skip buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(
                Icons.skip_previous,
                'Prev',
                    () {
                  _onSeekChanged(0);
                },
              ),
              _buildControlButton(
                Icons.skip_next,
                'Next',
                    () {
                  _onSeekChanged(1.0);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Main play button
        GestureDetector(
          onTap: _togglePlayback,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPlaying ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isPlaying
                          ? [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)]
                          : [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying ? Colors.red : Colors.blue).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Stop button
        _buildControlButton(
          Icons.stop,
          'Stop',
          _stopPlayback,
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volume_down, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.blue.withOpacity(0.3),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: _onVolumeChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.volume_up, color: Colors.white.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                '${(_volume * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMBIENT SOUNDS',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sounds.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sound = _sounds[index];
              final isSelected = _selectedSoundIndex == index;

              return GestureDetector(
                onTap: () => _selectSound(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 100 : 90,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        sound['color'].withOpacity(0.3),
                        sound['color'].withOpacity(0.1),
                      ],
                    )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? sound['color'].withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sound['icon'],
                        size: isSelected ? 32 : 28,
                        color: isSelected ? sound['color'] : Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sound['name'],
                        style: TextStyle(
                          fontSize: isSelected ? 14 : 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
