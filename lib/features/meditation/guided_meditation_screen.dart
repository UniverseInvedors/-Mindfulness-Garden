import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindfulness_garden/core/services/ad_service.dart';
import 'package:mindfulness_garden/core/services/audio_service.dart';
import 'package:mindfulness_garden/core/services/tts_service.dart';
import 'package:mindfulness_garden/core/widgets/meditation_scene_widget.dart';
import 'package:video_player/video_player.dart';

class GuidedMeditationScreen extends StatefulWidget {
  const GuidedMeditationScreen({super.key});

  @override
  State<GuidedMeditationScreen> createState() => _GuidedMeditationScreenState();
}

class _GuidedMeditationScreenState extends State<GuidedMeditationScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int? _selectedId;
  bool _isLoading = false;
  final Map<int, bool> _favorites = {};
  String _selectedCategory = 'All';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final AudioService _audio = AudioService();
  final TtsService _tts = TtsService();

  final List<Map<String, dynamic>> _sessions = [
    {
      'id': 1,
      'title': 'Morning Mindfulness',
      'teacher': 'Sarah Johnson',
      'duration': '10 min',
      'category': 'Morning',
      'difficulty': 'Beginner',
      'description': 'Start your day with clarity and peace',
      'videoAsset': 'assets/videos/morning_meditation.mp4',
      'color': const Color(0xFFff9e00),
      'icon': Icons.wb_sunny,
      'rating': 4.8,
      'plays': 1245,
      'tts':
          'Good morning. Find a comfortable seat, close your eyes, and take a deep breath. Let today begin with peace.',
    },
    {
      'id': 2,
      'title': 'Stress Release',
      'teacher': 'Michael Chen',
      'duration': '15 min',
      'category': 'Stress Relief',
      'difficulty': 'Intermediate',
      'description': 'Release tension and find calm',
      'videoAsset': 'assets/videos/stress_release.mp4',
      'color': const Color(0xFFf72585),
      'icon': Icons.self_improvement,
      'rating': 4.9,
      'plays': 892,
      'tts':
          'Let go of all tension. With each exhale, release the stress from your body. You are safe. You are calm.',
    },
    {
      'id': 3,
      'title': 'Deep Sleep',
      'teacher': 'Emma Wilson',
      'duration': '20 min',
      'category': 'Sleep',
      'difficulty': 'All Levels',
      'description': 'Gentle guidance into restful sleep',
      'videoAsset': 'assets/videos/deep_sleep.mp4',
      'color': const Color(0xFF560bad),
      'icon': Icons.bedtime,
      'rating': 4.7,
      'plays': 1567,
      'tts':
          'Allow your body to sink into complete relaxation. Your mind is quiet. Drift gently into peaceful sleep.',
    },
    {
      'id': 4,
      'title': 'Focus & Concentration',
      'teacher': 'David Park',
      'duration': '12 min',
      'category': 'Focus',
      'difficulty': 'Advanced',
      'description': 'Sharpen your mind and attention',
      'videoAsset': 'assets/videos/focus_concentration.mp4',
      'color': const Color(0xFF4361ee),
      'icon': Icons.psychology,
      'rating': 4.6,
      'plays': 734,
      'tts':
          'Bring your full attention to this moment. Notice your breath. Stay present and focused.',
    },
    {
      'id': 5,
      'title': 'Anxiety Relief',
      'teacher': 'Lisa Taylor',
      'duration': '8 min',
      'category': 'Anxiety',
      'difficulty': 'Beginner',
      'description': 'Calm your anxious thoughts',
      'videoAsset': 'assets/videos/anxiety_relief.mp4',
      'color': const Color(0xFF7209b7),
      'icon': Icons.favorite,
      'rating': 4.9,
      'plays': 1123,
      'tts':
          'You are safe right now. Breathe in slowly. Breathe out slowly. You are in control.',
    },
    {
      'id': 6,
      'title': 'Body Scan',
      'teacher': 'Robert Kim',
      'duration': '18 min',
      'category': 'Body Awareness',
      'difficulty': 'Intermediate',
      'description': 'Connect with your body sensations',
      'videoAsset': 'assets/videos/meditation_demo.mp4',
      'color': const Color(0xFF4cc9f0),
      'icon': Icons.accessibility_new,
      'rating': 4.8,
      'plays': 987,
      'tts':
          'Starting from the top of your head, slowly scan down through your body. Notice any sensations without judgment.',
    },
  ];

  List<String> get _cats => [
        'All',
        'Morning',
        'Stress Relief',
        'Sleep',
        'Focus',
        'Anxiety',
        'Body Awareness',
      ];

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 'All'
      ? _sessions
      : _sessions.where((s) => s['category'] == _selectedCategory).toList();

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _play(Map<String, dynamic> session) async {
    setState(() {
      _selectedId = session['id'];
      _isLoading = true;
    });

    _chewieController?.dispose();
    _chewieController = null;
    await _videoController?.dispose();
    _videoController = null;
    await _audio.stopSound();
    await _tts.stop();

    try {
      _videoController = VideoPlayerController.asset(session['videoAsset']);
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5],
        materialProgressColors: ChewieProgressColors(
          playedColor: session['color'],
          handleColor: session['color'],
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        placeholder: Container(
          color: const Color(0xFF0a0a1a),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (_, __) => _audioFallback(session),
      );

      setState(() {
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _selectedId == session['id']) {
          _tts.speak(session['tts']);
        }
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });

      await _audio.setVolume(0.35);
      await _audio.playSound('piano');

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _selectedId == session['id']) {
          _tts.speak(session['tts']);
        }
      });
    }
  }

  Widget _audioFallback(Map<String, dynamic> session) => Container(
        color: const Color(0xFF0a0a1a),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (session['color'] as Color).withOpacity(0.8),
                        (session['color'] as Color).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Icon(session['icon'], size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                session['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Video could not start. Voice guidance is playing instead.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The session has already started with audio.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.65)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _play(session),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Video'),
              ),
            ],
          ),
        ),
      );

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4361ee).withOpacity(0.8),
                      const Color(0xFF4361ee).withOpacity(0.2),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a session to begin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_sessions.length} sessions available',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      );

  Widget _guidedInstructorScene(Map<String, dynamic> session) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MeditationSceneWidget(
          breathPhase: _isLoading ? BreathPhase.idle : BreathPhase.inhale,
          pose: ZenoPose.lotus,
          environment: SceneEnvironment.zenTemple,
          timeOfDay: SceneTimeOfDay.dawn,
          instruction: session['tts'],
          isActive: !_isLoading,
          height: double.infinity,
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(115),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(41)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.record_voice_over,
                    size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  _isLoading ? 'Preparing guide' : 'Voice guide speaking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _catColor(String category) {
    switch (category.toLowerCase()) {
      case 'morning':
        return const Color(0xFFff9e00);
      case 'stress relief':
        return const Color(0xFFf72585);
      case 'sleep':
        return const Color(0xFF560bad);
      case 'focus':
        return const Color(0xFF4361ee);
      case 'anxiety':
        return const Color(0xFF7209b7);
      case 'body awareness':
        return const Color(0xFF4cc9f0);
      default:
        return const Color(0xFF4361ee);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _pulseCtrl.dispose();
    _audio.stopSound();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSession = _selectedId != null
        ? _sessions.firstWhere((s) => s['id'] == _selectedId)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      bottomNavigationBar: AdService().buildBanner(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/main'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guided Meditation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Expert-led sessions',
                          style: TextStyle(fontSize: 13, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  if (selectedSession != null)
                    IconButton(
                      onPressed: () => setState(() {
                        _favorites[selectedSession['id']] =
                            !(_favorites[selectedSession['id']] ?? false);
                      }),
                      icon: Icon(
                        (_favorites[selectedSession['id']] ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (_favorites[selectedSession['id']] ?? false)
                            ? Colors.red
                            : Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: selectedSession != null
                        ? _guidedInstructorScene(selectedSession)
                        : _placeholder(),
                  ),
                  if (_isLoading && selectedSession != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.72),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: selectedSession['color'],
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Loading local video...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your voice guidance will begin automatically.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.68),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (selectedSession != null && !_isLoading)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (selectedSession['color'] as Color)
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              selectedSession['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final cat = _cats[i];
                  final active = cat == _selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active
                            ? _catColor(cat)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Meditation Library',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filtered.length} sessions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _sessionCard(_filtered[i]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(Map<String, dynamic> session) {
    final isSelected = _selectedId == session['id'];
    final isFav = _favorites[session['id']] ?? false;
    final color = session['color'] as Color;

    return GestureDetector(
      onTap: () => _play(session),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.6)],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      session['icon'],
                      size: 50,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        session['duration'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isFav)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(Icons.favorite, size: 18, color: Colors.red),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session['teacher'],
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${session['rating']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          session['difficulty'],
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
