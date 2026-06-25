import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import 'flame_garden/garden_game.dart';

class GardenGameplayScreen extends ConsumerStatefulWidget {
  const GardenGameplayScreen({super.key});

  @override
  ConsumerState<GardenGameplayScreen> createState() => _GardenGameplayScreenState();
}

class _GardenGameplayScreenState extends ConsumerState<GardenGameplayScreen> {
  late GardenGame _gardenGame;

  @override
  void initState() {
    super.initState();
    _gardenGame = GardenGame(
      onGardenInteract: (interaction) {
        _handleGardenInteraction(interaction);
      },
    );
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
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
                        _buildWeatherButton(),
                        _buildTimeButton(),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _buildControlButton(
                          Icons.add,
                          'Add Plant',
                          () => _showAddPlantDialog(),
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          Icons.nature,
                          'Add Decoration',
                          () => _showAddDecorationDialog(),
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          Icons.pets,
                          'Add NPC',
                          () => _showAddNPCDialog(),
                        ),
                        const Spacer(),
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

  Widget _buildWeatherButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.wb_sunny, color: Colors.white),
        onPressed: () => _showWeatherDialog(),
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
        onPressed: () => _showTimeDialog(),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWeatherOption('Sunny', Icons.wb_sunny, WeatherType.sunny),
            _buildWeatherOption('Cloudy', Icons.cloud, WeatherType.cloudy),
            _buildWeatherOption('Rainy', Icons.grain, WeatherType.rainy),
            _buildWeatherOption('Snowy', Icons.ac_unit, WeatherType.snowy),
            _buildWeatherOption('Stormy', Icons.flash_on, WeatherType.stormy),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherOption(String label, IconData icon, WeatherType type) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () {
        _gardenGame.gardenWorld.setWeather(type);
        Navigator.pop(context);
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
        content: Column(
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
    );
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Add Plant',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlantOption('Flower', PlantType.flower),
            _buildPlantOption('Tree', PlantType.tree),
            _buildPlantOption('Bush', PlantType.bush),
            _buildPlantOption('Grass', PlantType.grass),
            _buildPlantOption('Fern', PlantType.fern),
            _buildPlantOption('Bamboo', PlantType.bamboo),
            _buildPlantOption('Lotus', PlantType.lotus),
            _buildPlantOption('Cherry Blossom', PlantType.cherryBlossom),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantOption(String label, PlantType type) {
    return ListTile(
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () {
        _gardenGame.gardenWorld.addPlant(
          Vector2(0, 0),
          type,
        );
        Navigator.pop(context);
      },
    );
  }

  void _showAddDecorationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Add Decoration',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDecorationOption('Rock', DecorationType.rock),
            _buildDecorationOption('Path', DecorationType.path),
            _buildDecorationOption('Bridge', DecorationType.bridge),
            _buildDecorationOption('Fountain', DecorationType.fountain),
            _buildDecorationOption('Lantern', DecorationType.lantern),
            _buildDecorationOption('Bench', DecorationType.bench),
            _buildDecorationOption('Statue', DecorationType.statue),
            _buildDecorationOption('Waterfall', DecorationType.waterfall),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationOption(String label, DecorationType type) {
    return ListTile(
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () {
        _gardenGame.gardenWorld.addDecoration(
          Vector2(0, 0),
          type,
        );
        Navigator.pop(context);
      },
    );
  }

  void _showAddNPCDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Add NPC',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNPCOption('Gardener', NPCType.gardener),
            _buildNPCOption('Butterfly', NPCType.butterfly),
            _buildNPCOption('Bird', NPCType.bird),
            _buildNPCOption('Rabbit', NPCType.rabbit),
            _buildNPCOption('Turtle', NPCType.turtle),
          ],
        ),
      ),
    );
  }

  Widget _buildNPCOption(String label, NPCType type) {
    return ListTile(
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () {
        _gardenGame.gardenWorld.addNPC(
          Vector2(0, 0),
          type,
        );
        Navigator.pop(context);
      },
    );
  }

  void _showSettingsDialog() {
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
              title: Text('Pause Day/Night Cycle', style: TextStyle(color: Colors.white)),
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
                  _gardenGame.gardenWorld.dayNightCycle.setCycleSpeed(value / 100);
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
