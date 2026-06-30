import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/sound_service.dart';
import '../../core/themes/app_theme.dart';
import '../../services/audio_manager_service.dart';
import '../../services/audio_constants.dart';
import 'flame_garden/garden_game.dart';

class GardenGameplayScreen extends ConsumerStatefulWidget {
  const GardenGameplayScreen({super.key});

  @override
  ConsumerState<GardenGameplayScreen> createState() =>
      _GardenGameplayScreenState();
}

class _GardenGameplayScreenState extends ConsumerState<GardenGameplayScreen> {
  late GardenGame _gardenGame;
  Timer? _statusTimer;
  WeatherType _currentWeather = WeatherType.sunny;

  @override
  void initState() {
    super.initState();
    _gardenGame = GardenGame(
      onGardenInteract: (interaction) {
        _handleGardenInteraction(interaction);
      },
      onWeatherChanged: (weather) {
        if (mounted) {
          setState(() => _currentWeather = weather);
          _playWeatherSound(weather.name);
        }
      },
    );

    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Initialize enhanced audio system
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    final audioManager = AudioManagerService();
    await audioManager.initialize();

    // Start background music
    await audioManager.playBackgroundMusic(AudioConstants.musicSpring);

    // Set garden day ambience
    await audioManager.setGardenAmbience(true);

    debugPrint('Garden audio initialized - Music and ambience playing');
  }

  Future<void> _playWeatherSound(String weather) async {
    final audioManager = AudioManagerService();
    debugPrint('Changing weather sound to: $weather');

    switch (weather.toLowerCase()) {
      case 'rainy':
        await audioManager.playBackgroundMusic(AudioConstants.musicRainy);
        await audioManager.playAmbience(AudioConstants.natureRain);
        break;
      case 'sunny':
        await audioManager.playBackgroundMusic(AudioConstants.musicSpring);
        await audioManager.playAmbience(AudioConstants.natureBirds);
        break;
      case 'stormy':
        await audioManager.playBackgroundMusic(AudioConstants.musicWinter);
        await audioManager.playAmbience(AudioConstants.natureWind);
        break;
      case 'snowy':
        await audioManager.playBackgroundMusic(AudioConstants.musicWinter);
        await audioManager.playAmbience(AudioConstants.natureWind);
        break;
      case 'cloudy':
        await audioManager.playBackgroundMusic(AudioConstants.musicSpring);
        await audioManager.playAmbience(AudioConstants.natureForest);
        break;
      default:
        await audioManager.playBackgroundMusic(AudioConstants.musicSpring);
        await audioManager.setGardenAmbience(true);
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _handleGardenInteraction(String interaction) {
    // Handle garden interactions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interacted with: $interaction'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Flame Game Widget
            GameWidget(game: _gardenGame),

            // UI Overlay
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () async {
                            await AudioManagerService().playButtonClick();
                            HapticFeedback.selectionClick();
                            if (mounted) context.pop();
                          },
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Mindfulness Garden',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildActionButton(
                            Icons.local_florist, 'Tend', _tendGarden),
                        const SizedBox(width: 8),
                        _buildWeatherButton(),
                        _buildTimeButton(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGardenStatusCard(),
                  ),

                  const Spacer(),

                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _buildControlButton(
                          Icons.add,
                          'Add Plant',
                          () => _showAddPlantDialog(),
                        ),
                        _buildControlButton(
                          Icons.nature,
                          'Add Decoration',
                          () => _showAddDecorationDialog(),
                        ),
                        _buildControlButton(
                          Icons.pets,
                          'Add NPC',
                          () => _showAddNPCDialog(),
                        ),
                        _buildControlButton(
                          Icons.settings,
                          'Settings',
                          () => _showSettingsDialog(),
                        ),
                      ],
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

  Widget _buildGardenStatusCard() {
    final timeLabel =
        _gardenGame.gardenWorld.dayNightCycle.getTimeDescription();
    final weatherLabel = _currentWeather.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          _buildStatusChip(_currentWeather.emoji, weatherLabel),
          const SizedBox(width: 8),
          _buildStatusChip(Icons.access_time, timeLabel),
          const Spacer(),
          Text(
            'Tap plants to help them grow',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(dynamic icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon is IconData
              ? Icon(icon, size: 16, color: Colors.white)
              : Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeatherButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.wb_sunny, color: Colors.white),
        onPressed: () async {
          await AudioManagerService().playButtonClick();
          if (mounted) _showWeatherDialog();
        },
      ),
    );
  }

  Widget _buildTimeButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.access_time, color: Colors.white),
        onPressed: () async {
          await AudioManagerService().playButtonClick();
          if (mounted) _showTimeDialog();
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: label,
        onPressed: () async {
          await AudioManagerService().playButtonClick();
          onTap();
        },
      ),
    );
  }

  void _tendGarden() {
    unawaited(AudioManagerService().playHealSound());
    unawaited(AudioManagerService().playSparkleSound());
    HapticFeedback.mediumImpact();
    _gardenGame.gardenWorld.tendGarden();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🌟 Your garden is thriving!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        await AudioManagerService().playButtonClick();
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeatherDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Select Weather',
          style: TextStyle(color: Colors.white),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWeatherOption('Sunny', Icons.wb_sunny, WeatherType.sunny),
                _buildWeatherOption('Cloudy', Icons.cloud, WeatherType.cloudy),
                _buildWeatherOption('Rainy', Icons.grain, WeatherType.rainy),
                _buildWeatherOption('Snowy', Icons.ac_unit, WeatherType.snowy),
                _buildWeatherOption(
                    'Stormy', Icons.flash_on, WeatherType.stormy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherOption(String label, IconData icon, WeatherType type) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () async {
        await AudioManagerService().playButtonClick();
        HapticFeedback.selectionClick();
        _gardenGame.gardenWorld.setWeather(type);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  void _showTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Set Time of Day',
          style: TextStyle(color: Colors.white),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _gardenGame.gardenWorld.dayNightCycle.timeOfDay,
                  onChanged: (value) {
                    _gardenGame.gardenWorld.setTimeOfDay(value);
                    setState(() {});
                  },
                  min: 0.0,
                  max: 1.0,
                ),
                Text(
                  _gardenGame.gardenWorld.dayNightCycle.getTimeDescription(),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.3),
                      Colors.teal.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🌱 Choose a Plant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        await AudioManagerService().playButtonClick();
                        HapticFeedback.selectionClick();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // Plant Grid - Scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildPlantCard('🌸', 'Flower', PlantType.flower),
                      _buildPlantCard('🌳', 'Tree', PlantType.tree),
                      _buildPlantCard('🌿', 'Bush', PlantType.bush),
                      _buildPlantCard('🌾', 'Grass', PlantType.grass),
                      _buildPlantCard('🪴', 'Fern', PlantType.fern),
                      _buildPlantCard('🎋', 'Bamboo', PlantType.bamboo),
                      _buildPlantCard('🪷', 'Lotus', PlantType.lotus),
                      _buildPlantCard('🌸', 'Cherry', PlantType.cherryBlossom),
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

  Widget _buildPlantCard(String emoji, String name, PlantType type) {
    return GestureDetector(
      onTap: () async {
        await AudioManagerService().playPlantSound();
        await AudioManagerService().playButtonClick();
        HapticFeedback.mediumImpact();
        _gardenGame.gardenWorld.addPlant(
          Vector2(0, 0),
          type,
        );
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.withValues(alpha: 0.2),
              Colors.teal.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed - replaced with _buildPlantCard

  void _showAddDecorationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.3),
                      Colors.blue.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🎨 Garden Decorations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        await AudioManagerService().playButtonClick();
                        HapticFeedback.selectionClick();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // Decoration Grid - Scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildDecorationCard('🪨', 'Rock', DecorationType.rock),
                      _buildDecorationCard('🛤️', 'Path', DecorationType.path),
                      _buildDecorationCard(
                          '🌉', 'Bridge', DecorationType.bridge),
                      _buildDecorationCard(
                          '⛲', 'Fountain', DecorationType.fountain),
                      _buildDecorationCard(
                          '🏮', 'Lantern', DecorationType.lantern),
                      _buildDecorationCard('🪑', 'Bench', DecorationType.bench),
                      _buildDecorationCard(
                          '🗿', 'Statue', DecorationType.statue),
                      _buildDecorationCard(
                          '💧', 'Waterfall', DecorationType.waterfall),
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

  Widget _buildDecorationCard(String emoji, String name, DecorationType type) {
    return GestureDetector(
      onTap: () async {
        await AudioManagerService().playSfx(AudioConstants.uiSelect2);
        await AudioManagerService().playButtonClick();
        HapticFeedback.mediumImpact();
        _gardenGame.gardenWorld.addDecoration(
          Vector2(0, 0),
          type,
        );
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withValues(alpha: 0.2),
              Colors.blue.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed - replaced with _buildDecorationCard

  void _showAddNPCDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.3),
                      Colors.pink.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🐾 Garden Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        await AudioManagerService().playButtonClick();
                        HapticFeedback.selectionClick();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // NPC Grid - Scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildNPCCard('👨‍🌾', 'Gardener', NPCType.gardener),
                      _buildNPCCard('🦋', 'Butterfly', NPCType.butterfly),
                      _buildNPCCard('🐦', 'Bird', NPCType.bird),
                      _buildNPCCard('🐰', 'Rabbit', NPCType.rabbit),
                      _buildNPCCard('🐢', 'Turtle', NPCType.turtle),
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

  Widget _buildNPCCard(String emoji, String name, NPCType type) {
    return GestureDetector(
      onTap: () async {
        await AudioManagerService().playSuccess();
        await AudioManagerService().playButtonClick();
        HapticFeedback.lightImpact();
        _gardenGame.gardenWorld.addNPC(
          Vector2(0, 0),
          type,
        );
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withValues(alpha: 0.2),
              Colors.pink.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed - replaced with _buildNPCCard

  void _showSettingsDialog() {
    unawaited(AudioManagerService().playButtonClick());
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Garden Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Pause Day/Night Cycle',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: _gardenGame.gardenWorld.dayNightCycle.isPaused,
                onChanged: (value) {
                  if (value) {
                    _gardenGame.gardenWorld.dayNightCycle.pause();
                  } else {
                    _gardenGame.gardenWorld.dayNightCycle.resume();
                  }
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: Text('Cycle Speed', style: TextStyle(color: Colors.white)),
              subtitle: Slider(
                value: _gardenGame.gardenWorld.dayNightCycle.cycleSpeed * 100,
                onChanged: (value) {
                  _gardenGame.gardenWorld.dayNightCycle
                      .setCycleSpeed(value / 100);
                  setState(() {});
                },
                min: 0,
                max: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
