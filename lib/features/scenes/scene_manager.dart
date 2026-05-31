// lib/features/scenes/scene_manager.dart
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mindfulness_garden/core/services/asset_service.dart';
import 'package:mindfulness_garden/core/services/audio_service.dart';
import 'package:go_router/go_router.dart';

// Scene Manager Screen Widget
class SceneManager extends StatelessWidget {
  const SceneManager({super.key});

  @override
  Widget build(BuildContext context) {
    final sceneManager = SceneManagerService();
    final scenes = sceneManager.getAvailableScenes();

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        title: const Text('Meditation Scenes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Meditation Environment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a scene to enhance your meditation experience',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: scenes.length,
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  return _buildSceneCard(scene, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneCard(SceneDefinition scene, BuildContext context) {
    return GestureDetector(
      onTap: () {
        SceneManagerService().startSceneDirect(scene, context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scene.color.withOpacity(0.3),
              scene.color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scene.color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(scene.icon, color: Colors.white),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    scene.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scene.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.headphones, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${scene.soundtracks.length} soundtracks',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scene.color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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

// Scene Manager Service (Singleton)
class SceneManagerService {
  static final SceneManagerService _instance = SceneManagerService._internal();
  factory SceneManagerService() => _instance;

  SceneManagerService._internal();

  final AssetService _assetService = AssetService();
  final AudioService _audioService = AudioService();

  // Scene definitions
  static final Map<String, SceneDefinition> _scenes = {
    'waterfall': SceneDefinition(
      id: 'waterfall',
      name: 'Waterfall Sanctuary',
      description: 'A serene waterfall in a mystical forest',
      icon: Icons.water,
      color: const Color(0xFF00b4d8),
      elements: [
        SceneElement(type: 'waterfall', x: 0.5, y: 0.3),
        SceneElement(type: 'river', x: 0.5, y: 0.7),
        SceneElement(type: 'trees', x: 0.2, y: 0.5),
        SceneElement(type: 'trees', x: 0.8, y: 0.5),
        SceneElement(type: 'rocks', x: 0.3, y: 0.6),
        SceneElement(type: 'rocks', x: 0.7, y: 0.6),
      ],
      soundtracks: [
        'assets/sounds/nature/waterfall.mp3',
        'assets/sounds/nature/birds.mp3',
        'assets/sounds/nature/wind.mp3'
      ],
      particleCount: 50,
      backgroundColor: const Color(0xFF0A2472),
    ),
    'forest': SceneDefinition(
      id: 'forest',
      name: 'Ancient Forest',
      description: 'A peaceful forest with ancient trees',
      icon: Icons.park,
      color: const Color(0xFF38b000),
      elements: [
        SceneElement(type: 'tree_large', x: 0.3, y: 0.4),
        SceneElement(type: 'tree_large', x: 0.7, y: 0.4),
        SceneElement(type: 'tree_small', x: 0.2, y: 0.6),
        SceneElement(type: 'tree_small', x: 0.8, y: 0.6),
        SceneElement(type: 'flowers', x: 0.5, y: 0.8),
        SceneElement(type: 'mushrooms', x: 0.4, y: 0.9),
        SceneElement(type: 'mushrooms', x: 0.6, y: 0.9),
      ],
      soundtracks: [
        'assets/sounds/nature/forest.mp3',
        'assets/sounds/nature/birds.mp3',
        'assets/sounds/nature/crickets.mp3'
      ],
      particleCount: 30,
      backgroundColor: const Color(0xFF1B4332),
    ),
    'ocean': SceneDefinition(
      id: 'ocean',
      name: 'Ocean Depths',
      description: 'Tranquil underwater meditation',
      icon: Icons.waves,
      color: const Color(0xFF0077b6),
      elements: [
        SceneElement(type: 'coral_1', x: 0.2, y: 0.7),
        SceneElement(type: 'coral_2', x: 0.8, y: 0.7),
        SceneElement(type: 'seaweed', x: 0.1, y: 0.8),
        SceneElement(type: 'seaweed', x: 0.9, y: 0.8),
        SceneElement(type: 'fish_1', x: 0.4, y: 0.5),
        SceneElement(type: 'fish_2', x: 0.6, y: 0.4),
        SceneElement(type: 'bubbles', x: 0.5, y: 0.3),
      ],
      soundtracks: ['assets/sounds/nature/ocean.mp3'],
      particleCount: 40,
      backgroundColor: const Color(0xFF03045e),
    ),
    'mountain': SceneDefinition(
      id: 'mountain',
      name: 'Mountain Summit',
      description: 'Meditation at the peak of the world',
      icon: Icons.landscape,
      color: const Color(0xFFff6d00),
      elements: [
        SceneElement(type: 'mountain_peak', x: 0.5, y: 0.3),
        SceneElement(type: 'clouds', x: 0.3, y: 0.5),
        SceneElement(type: 'clouds', x: 0.7, y: 0.5),
        SceneElement(type: 'eagle', x: 0.4, y: 0.2),
        SceneElement(type: 'sun', x: 0.2, y: 0.1),
        SceneElement(type: 'trees', x: 0.4, y: 0.8),
        SceneElement(type: 'trees', x: 0.6, y: 0.8),
      ],
      soundtracks: ['assets/sounds/nature/wind.mp3'],
      particleCount: 20,
      backgroundColor: const Color(0xFF1a759f),
    ),
    'cosmic': SceneDefinition(
      id: 'cosmic',
      name: 'Cosmic Meditation',
      description: 'Float among the stars and galaxies',
      icon: Icons.star,
      color: const Color(0xFF9d4edd),
      elements: [
        SceneElement(type: 'planet_1', x: 0.3, y: 0.4),
        SceneElement(type: 'planet_2', x: 0.7, y: 0.5),
        SceneElement(type: 'stars', x: 0.5, y: 0.5),
        SceneElement(type: 'nebula', x: 0.2, y: 0.2),
        SceneElement(type: 'nebula', x: 0.8, y: 0.3),
        SceneElement(type: 'comet', x: 0.1, y: 0.1),
      ],
      soundtracks: ['assets/sounds/meditation/bowl.mp3'],
      particleCount: 100,
      backgroundColor: const Color(0xFF10002b),
    ),
  };

  // Get all available scenes
  List<SceneDefinition> getAvailableScenes() {
    return _scenes.values.toList();
  }

  // Get scene by ID
  SceneDefinition? getScene(String sceneId) {
    return _scenes[sceneId];
  }

  // Start a scene directly from scene object
  void startSceneDirect(SceneDefinition scene, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SceneScreen(scene: scene),
      ),
    );
  }

  // Start a scene by ID
  Future<void> startScene(String sceneId, BuildContext context) async {
    final scene = getScene(sceneId);
    if (scene == null) return;

    // Preload scene assets
    await _preloadSceneAssets(scene);

    // Navigate to scene
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SceneScreen(scene: scene),
      ),
    );
  }

  // Preload scene assets
  Future<void> _preloadSceneAssets(SceneDefinition scene) async {
    final assets = [
      for (var soundtrack in scene.soundtracks) soundtrack,
    ];

    for (var asset in assets) {
      await _assetService.getAsset(asset);
    }
  }
}

// Scene definition classes
class SceneDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<SceneElement> elements;
  final List<String> soundtracks;
  final int particleCount;
  final Color backgroundColor;

  const SceneDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.elements,
    required this.soundtracks,
    required this.particleCount,
    required this.backgroundColor,
  });
}

class SceneElement {
  final String type;
  final double x; // 0.0 to 1.0
  final double y; // 0.0 to 1.0

  const SceneElement({
    required this.type,
    required this.x,
    required this.y,
  });
}

// Scene Screen Widget
class SceneScreen extends StatefulWidget {
  final SceneDefinition scene;

  const SceneScreen({super.key, required this.scene});

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<Particle> _particles = [];
  final AudioService _audioService = AudioService();
  Timer? _meditationTimer;
  int _remainingSeconds = 300; // 5 minutes default
  bool _isMeditating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Initialize particles
    _initializeParticles();

    // Play scene soundtrack
    _playSoundtrack();
  }

  void _playSoundtrack() async {
    if (widget.scene.soundtracks.isNotEmpty) {
      await _audioService.playSound(widget.scene.soundtracks.first, loop: true);
    }
  }

  void _initializeParticles() {
    for (int i = 0; i < widget.scene.particleCount; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.5 + 0.2,
        color: widget.scene.color,
      ));
    }
  }

  void _startMeditation(int minutes) {
    setState(() {
      _remainingSeconds = minutes * 60;
      _isMeditating = true;
    });

    _meditationTimer?.cancel();
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _isMeditating = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _stopMeditation() {
    _meditationTimer?.cancel();
    setState(() {
      _isMeditating = false;
      _remainingSeconds = 300;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎉 Meditation Complete!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Great job! You completed your meditation session in the ${widget.scene.name}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: widget.scene.backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    widget.scene.backgroundColor.withOpacity(0.9),
                    widget.scene.backgroundColor.withOpacity(0.6),
                    widget.scene.backgroundColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _controller,
                  ),
                );
              },
            ),
          ),

          // Scene elements
          ...widget.scene.elements.map((element) {
            return Positioned(
              left: element.x * size.width - 50,
              top: element.y * size.height - 50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.scene.color.withOpacity(0.1),
                ),
                child: Icon(
                  _getIconForElement(element.type),
                  color: widget.scene.color,
                  size: 40,
                ),
              ),
            );
          }),

          // Meditation timer/controls
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    widget.scene.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.scene.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Timer display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isMeditating ? 'Remaining Time' : 'Select Duration',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _isMeditating ? Colors.green : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!_isMeditating)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTimeButton(5),
                              _buildTimeButton(10),
                              _buildTimeButton(15),
                              _buildTimeButton(20),
                            ],
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_isMeditating) {
                              _stopMeditation();
                            } else {
                              _startMeditation(5); // Default 5 minutes
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isMeditating ? Colors.red : widget.scene.color,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            _isMeditating
                                ? 'Stop Meditation'
                                : 'Start Meditation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  _audioService.stop();
                  _meditationTimer?.cancel();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Sound controls
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _audioService.setVolume(0.3),
                    icon: const Icon(Icons.volume_down, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _audioService.pause();
                    },
                    icon: const Icon(Icons.pause, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _audioService.resume();
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Current time
          Positioned(
            top: 120,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getCurrentTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(int minutes) {
    return GestureDetector(
      onTap: () => _startMeditation(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          '$minutes min',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForElement(String type) {
    switch (type) {
      case 'waterfall':
        return Icons.water;
      case 'river':
        return Icons.waves;
      case 'tree_large':
      case 'tree_small':
      case 'trees':
        return Icons.park;
      case 'flowers':
        return Icons.local_florist;
      case 'mushrooms':
        return Icons.grass;
      case 'rocks':
        return Icons.landscape;
      case 'coral_1':
      case 'coral_2':
        return Icons.water;
      case 'seaweed':
        return Icons.grass;
      case 'fish_1':
      case 'fish_2':
        return Icons.pets;
      case 'bubbles':
        return Icons.bubble_chart;
      case 'mountain_peak':
        return Icons.terrain;
      case 'clouds':
        return Icons.cloud;
      case 'eagle':
        return Icons.flight;
      case 'sun':
        return Icons.wb_sunny;
      case 'planet_1':
      case 'planet_2':
        return Icons.public;
      case 'stars':
        return Icons.star;
      case 'nebula':
        return Icons.blur_on;
      case 'comet':
        return Icons.flash_on;
      default:
        return Icons.spa;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioService.stop();
    _meditationTimer?.cancel();
    super.dispose();
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final angle = 2 * pi * animation.value * particle.speed;
      final offsetX = particle.x * size.width + cos(angle) * 20;
      final offsetY = particle.y * size.height + sin(angle) * 20;

      final opacity =
          0.5 + 0.5 * sin(animation.value * 2 * pi + particle.x * pi);
      paint.color = particle.color.withOpacity(opacity);

      canvas.drawCircle(
        Offset(offsetX, offsetY),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation ||
        particles != oldDelegate.particles;
  }
}

