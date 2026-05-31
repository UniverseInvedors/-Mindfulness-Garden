import 'package:flutter/material.dart';
import 'dart:math';

class EnhancedGardenWidget extends StatefulWidget {
  final int level;
  final int streak;
  final double size;

  const EnhancedGardenWidget({
    super.key,
    required this.level,
    required this.streak,
    this.size = 300,
  });

  @override
  State<EnhancedGardenWidget> createState() => _EnhancedGardenWidgetState();
}

class _EnhancedGardenWidgetState extends State<EnhancedGardenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Random _random = Random();
  final List<Plant> _plants = [];
  final List<Insect> _insects = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _generateGarden();
  }

  void _generateGarden() {
    _plants.clear();
    _insects.clear();

    // Generate plants based on level
    final int plantCount = (3 + (widget.level ~/ 2)).clamp(3, 8);
    for (int i = 0; i < plantCount; i++) {
      _plants.add(
        Plant(
          type: PlantType.values[_random.nextInt(PlantType.values.length)],
          x: _random.nextDouble() * 0.8 + 0.1,
          y: _random.nextDouble() * 0.4 + 0.3,
          size: 0.3 + _random.nextDouble() * 0.5,
          growth: _random.nextDouble(),
        ),
      );
    }

    // Generate insects based on streak
    final int insectCount = (widget.streak ~/ 3).clamp(0, 4);
    for (int i = 0; i < insectCount; i++) {
      _insects.add(
        Insect(
          type: InsectType.values[_random.nextInt(InsectType.values.length)],
          x: _random.nextDouble() * 0.9,
          y: _random.nextDouble() * 0.3 + 0.1,
          speed: 0.3 + _random.nextDouble() * 0.7,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant EnhancedGardenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level || oldWidget.streak != widget.streak) {
      _generateGarden();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final plantCount = _plants.length;
    final insectCount = _insects.length;

    return Container(
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primaryContainer.withAlpha(20),
            colors.secondaryContainer.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Stack(
        children: [
          // Animated sky
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.primaryContainer.withAlpha(30),
                      colors.surface,
                    ],
                  ),
                ),
              );
            },
          ),

          // Sun
          Positioned(
            top: 20,
            right: 30,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, sin(_animation.value * pi * 2) * 5),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.tertiary.withAlpha(100),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),

          // Ground
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // Grass
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.secondary.withAlpha(100),
                    colors.secondary.withAlpha(150),
                  ],
                ),
              ),
            ),
          ),

          // Plants
          for (final plant in _plants)
            Positioned(
              left: plant.x * widget.size,
              bottom: plant.y * widget.size,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      sin(_animation.value * pi * 2 + plant.x) * 3,
                    ),
                    child: Container(
                      width: 30 + (widget.level * 2),
                      height: 30 + (widget.level * 2),
                      decoration: BoxDecoration(
                        color: _getPlantColor(plant.type).withAlpha(180),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getPlantColor(plant.type).withAlpha(80),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getPlantIcon(plant.type),
                        color: Colors.white,
                        size: 20 + (widget.level * 1.5),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Insects
          for (final insect in _insects)
            Positioned(
              left: insect.x * widget.size,
              bottom: insect.y * widget.size,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(_animation.value * pi * 2 * insect.speed + insect.x) *
                          20,
                      cos(
                            _animation.value * pi * 2 * insect.speed * 0.5 +
                                insect.y,
                          ) *
                          10,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getInsectColor(insect.type).withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getInsectIcon(insect.type),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Meditation spot
          Positioned(
            bottom: 40,
            left: (widget.size / 2) - 30,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    color: colors.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Text(
                    'MEDITATING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats badge
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_nature, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${widget.level}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        '$plantCount plants • $insectCount insects',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlantIcon(PlantType type) {
    switch (type) {
      case PlantType.flower:
        return Icons.local_florist;
      case PlantType.tree:
        return Icons.park;
      case PlantType.bush:
        return Icons.forest;
      case PlantType.herb:
        return Icons.grass;
      case PlantType.succulent:
        return Icons.spa;
    }
  }

  Color _getPlantColor(PlantType type) {
    switch (type) {
      case PlantType.flower:
        return Colors.pink;
      case PlantType.tree:
        return Colors.green;
      case PlantType.bush:
        return Colors.green.shade700;
      case PlantType.herb:
        return Colors.lightGreen;
      case PlantType.succulent:
        return Colors.green.shade400;
    }
  }

  IconData _getInsectIcon(InsectType type) {
    switch (type) {
      case InsectType.butterfly:
        return Icons.bug_report;
      case InsectType.bee:
        return Icons.hive;
      case InsectType.ladybug:
        return Icons.circle;
      case InsectType.dragonfly:
        return Icons.flight;
    }
  }

  Color _getInsectColor(InsectType type) {
    switch (type) {
      case InsectType.butterfly:
        return Colors.purple;
      case InsectType.bee:
        return Colors.yellow.shade700;
      case InsectType.ladybug:
        return Colors.red;
      case InsectType.dragonfly:
        return Colors.blue;
    }
  }
}

enum PlantType { flower, tree, bush, herb, succulent }

enum InsectType { butterfly, bee, ladybug, dragonfly }

class Plant {
  final PlantType type;
  final double x;
  final double y;
  final double size;
  final double growth;

  Plant({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.growth,
  });
}

class Insect {
  final InsectType type;
  final double x;
  final double y;
  final double speed;

  Insect({
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
  });
}
