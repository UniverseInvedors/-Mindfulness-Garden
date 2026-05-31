import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mindfulness_garden/core/services/ad_service.dart';
import 'package:mindfulness_garden/core/services/audio_service.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

// ─── ENUMS ───────────────────────────────────────────────────────────────────
enum Season { spring, summer, monsoon, autumn, winter, snowfall }

enum PlantType {
  flower,
  tree,
  bush,
  herb,
  mushroom,
  cactus,
  bamboo,
  lotus,
  sunflower,
  lavender,
  bonsai,
  rose,
}

enum GardenTool { plant, water, fertilize, harvest, remove, inspect }

enum TileType { soil, path, pond, fence }

enum AchievementType {
  firstPlant,
  tenPlants,
  firstHarvest,
  level5,
  level10,
  allSeasons,
  perfectGarden,
  o2Master,
  streakWeek
}

enum QuestType { plantSeeds, waterPlants, harvestPlants, earnCoins, reachLevel }

// ─── MODELS ──────────────────────────────────────────────────────────────────
class GardenTile {
  final int col, row;
  TileType tileType;
  bool isPlanted;
  PlantType? plantType;
  int growthStage; // 0=empty 1=seed 2=sprout 3=young 4=mature 5=full
  double water, health, fertility;
  bool isGlowing;
  double o2Output;
  int xpValue;
  bool isRare;
  int careCount; // how many times cared for (watered/fertilized)
  DateTime? plantedAt;

  GardenTile({
    required this.col,
    required this.row,
    this.tileType = TileType.soil,
    this.isPlanted = false,
    this.plantType,
    this.growthStage = 0,
    this.water = 0.7,
    this.health = 1.0,
    this.fertility = 0.5,
    this.isGlowing = false,
    this.o2Output = 0.0,
    this.xpValue = 10,
    this.isRare = false,
    this.careCount = 0,
    this.plantedAt,
  });

  Map<String, dynamic> toJson() => {
        'col': col,
        'row': row,
        'tileType': tileType.index,
        'isPlanted': isPlanted,
        'plantType': plantType?.index,
        'growthStage': growthStage,
        'water': water,
        'health': health,
        'fertility': fertility,
        'o2Output': o2Output,
        'xpValue': xpValue,
        'isRare': isRare,
        'careCount': careCount,
        'plantedAt': plantedAt?.toIso8601String(),
      };

  static GardenTile fromJson(Map<String, dynamic> j) {
    final t = GardenTile(
      col: j['col'],
      row: j['row'],
      tileType: TileType.values[j['tileType'] ?? 0],
      isPlanted: j['isPlanted'] ?? false,
      plantType:
          j['plantType'] != null ? PlantType.values[j['plantType']] : null,
      growthStage: j['growthStage'] ?? 0,
      water: (j['water'] ?? 0.7).toDouble(),
      health: (j['health'] ?? 1.0).toDouble(),
      fertility: (j['fertility'] ?? 0.5).toDouble(),
      o2Output: (j['o2Output'] ?? 0.0).toDouble(),
      xpValue: j['xpValue'] ?? 10,
      isRare: j['isRare'] ?? false,
      careCount: j['careCount'] ?? 0,
      plantedAt:
          j['plantedAt'] != null ? DateTime.tryParse(j['plantedAt']) : null,
    );
    return t;
  }
}

class DailyQuest {
  final QuestType type;
  final String title, description, emoji;
  final int target, reward;
  int progress;
  bool completed;

  DailyQuest({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.reward,
    this.progress = 0,
    this.completed = false,
  });

  double get fraction => (progress / target).clamp(0.0, 1.0);
}

class GardenAchievement {
  final AchievementType type;
  final String title, description, emoji;
  final int reward;
  bool unlocked;
  DateTime? unlockedAt;

  GardenAchievement({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.reward,
    this.unlocked = false,
    this.unlockedAt,
  });
}

class ShopItem {
  final String id, name, emoji, description;
  final int cost;
  final String currency; // 'coins' or 'premium'
  final Map<String, dynamic> effect;

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.cost,
    required this.currency,
    required this.effect,
  });
}

class ComboState {
  int count = 0;
  DateTime? lastAction;
  double multiplier = 1.0;

  void increment() {
    final now = DateTime.now();
    if (lastAction != null && now.difference(lastAction!).inSeconds < 5) {
      count++;
      multiplier = 1.0 + (count * 0.15).clamp(0.0, 2.0);
    } else {
      count = 1;
      multiplier = 1.0;
    }
    lastAction = now;
  }

  void reset() {
    count = 0;
    multiplier = 1.0;
    lastAction = null;
  }

  bool get isActive => count >= 3;
  String get label =>
      count >= 3 ? '🔥 x${multiplier.toStringAsFixed(1)} COMBO!' : '';
}

class RainDrop {
  double x, y, speed, length, opacity, windX;
  RainDrop(
      {required this.x,
      required this.y,
      required this.speed,
      required this.length,
      required this.opacity,
      this.windX = -0.0015});
}

class SnowFlake {
  double x, y, size, speed, drift, phase, rotation;
  SnowFlake(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.drift,
      required this.phase,
      this.rotation = 0});
}

class FloatingLabel {
  double x, y, life;
  String text;
  Color color;
  double scale;
  FloatingLabel(
      {required this.x,
      required this.y,
      required this.text,
      required this.color,
      this.life = 1.0,
      this.scale = 1.0});
}

class Particle {
  double x, y, vx, vy, life, size, rotation;
  Color color;
  Particle(
      {required this.x,
      required this.y,
      required this.vx,
      required this.vy,
      required this.color,
      this.life = 1.0,
      this.size = 4,
      this.rotation = 0});
}

class Meditator {
  final double col, row;
  final String emoji;
  double breathPhase;
  String mood; // 'calm', 'happy', 'disturbed'
  String? speechBubble;
  double speechLife;
  Meditator(
      {required this.col,
      required this.row,
      required this.emoji,
      this.breathPhase = 0,
      this.mood = 'calm',
      this.speechBubble,
      this.speechLife = 0});
}

class Butterfly {
  double x, y, phase, speed;
  String emoji;
  Butterfly(
      {required this.x,
      required this.y,
      required this.phase,
      required this.speed,
      required this.emoji});
}

class Bee {
  double x, y, targetCol, targetRow, phase;
  Bee(
      {required this.x,
      required this.y,
      required this.targetCol,
      required this.targetRow,
      required this.phase});
}

// ─── SEASON CONFIG ────────────────────────────────────────────────────────────
class SeasonConfig {
  final String name, emoji, description;
  final Color skyTop, skyMid, skyBottom;
  final Color groundLight, groundDark, groundWet, groundSnow;
  final Color pathColor, pondColor;
  final bool hasRain,
      hasSnow,
      hasLeaves,
      hasFireflies,
      hasFog,
      hasButterflies,
      hasBees;
  final double growthMult, windStrength;
  final String weatherNote;
  final List<String> seasonalPlants; // plants that thrive this season
  final int bonusCoins; // bonus coins per harvest this season
  const SeasonConfig({
    required this.name,
    required this.emoji,
    required this.description,
    required this.skyTop,
    required this.skyMid,
    required this.skyBottom,
    required this.groundLight,
    required this.groundDark,
    required this.groundWet,
    required this.groundSnow,
    required this.pathColor,
    required this.pondColor,
    this.hasRain = false,
    this.hasSnow = false,
    this.hasLeaves = false,
    this.hasFireflies = false,
    this.hasFog = false,
    this.hasButterflies = false,
    this.hasBees = false,
    this.growthMult = 1.0,
    this.windStrength = 0.5,
    this.weatherNote = '',
    this.seasonalPlants = const [],
    this.bonusCoins = 0,
  });
}

const _seasons = {
  Season.spring: SeasonConfig(
    name: 'Spring',
    emoji: '🌸',
    description: 'Warm rains bring new life. Plants grow 40% faster.',
    skyTop: Color(0xFF87CEEB),
    skyMid: Color(0xFFB0E2FF),
    skyBottom: Color(0xFFD4F5C4),
    groundLight: Color(0xFF5DBB63),
    groundDark: Color(0xFF3A8C40),
    groundWet: Color(0xFF2E7D32),
    groundSnow: Color(0xFF5DBB63),
    pathColor: Color(0xFFD4A96A),
    pondColor: Color(0xFF64B5F6),
    growthMult: 1.4,
    windStrength: 0.4,
    hasButterflies: true,
    hasBees: true,
    weatherNote: 'Gentle breeze. Ideal planting conditions.',
    seasonalPlants: ['flower', 'rose', 'lavender'],
    bonusCoins: 5,
  ),
  Season.summer: SeasonConfig(
    name: 'Summer',
    emoji: '☀️',
    description: 'Hot and bright. Water plants often or they wilt.',
    skyTop: Color(0xFF0D47A1),
    skyMid: Color(0xFF1976D2),
    skyBottom: Color(0xFF90CAF9),
    groundLight: Color(0xFF4CAF50),
    groundDark: Color(0xFF2E7D32),
    groundWet: Color(0xFF388E3C),
    groundSnow: Color(0xFF4CAF50),
    pathColor: Color(0xFFBF9B6A),
    pondColor: Color(0xFF29B6F6),
    hasFireflies: true,
    growthMult: 1.2,
    windStrength: 0.2,
    hasBees: true,
    weatherNote: 'High UV. Plants need extra water. Fireflies at dusk.',
    seasonalPlants: ['sunflower', 'cactus', 'herb'],
    bonusCoins: 8,
  ),
  Season.monsoon: SeasonConfig(
    name: 'Monsoon',
    emoji: '🌧️',
    description: 'Heavy rain. Plants auto-water. Fastest growth season.',
    skyTop: Color(0xFF263238),
    skyMid: Color(0xFF37474F),
    skyBottom: Color(0xFF546E7A),
    groundLight: Color(0xFF33691E),
    groundDark: Color(0xFF1B5E20),
    groundWet: Color(0xFF1B5E20),
    groundSnow: Color(0xFF33691E),
    pathColor: Color(0xFF6D4C41),
    pondColor: Color(0xFF1565C0),
    hasRain: true,
    growthMult: 1.6,
    windStrength: 0.8,
    weatherNote: 'Torrential rain. Ground saturated. +60% growth rate.',
    seasonalPlants: ['bamboo', 'lotus', 'mushroom'],
    bonusCoins: 10,
  ),
  Season.autumn: SeasonConfig(
    name: 'Autumn',
    emoji: '🍂',
    description: 'Leaves fall. Growth slows. Harvest before winter.',
    skyTop: Color(0xFFBF360C),
    skyMid: Color(0xFFE64A19),
    skyBottom: Color(0xFFFFCC02),
    groundLight: Color(0xFF8D6E63),
    groundDark: Color(0xFF5D4037),
    groundWet: Color(0xFF4E342E),
    groundSnow: Color(0xFF8D6E63),
    pathColor: Color(0xFFA1887F),
    pondColor: Color(0xFF78909C),
    hasLeaves: true,
    growthMult: 0.8,
    windStrength: 0.7,
    weatherNote: 'Falling leaves. Harvest mature plants before frost.',
    seasonalPlants: ['tree', 'bush', 'bonsai'],
    bonusCoins: 15,
  ),
  Season.winter: SeasonConfig(
    name: 'Winter',
    emoji: '❄️',
    description: 'Cold and still. Most plants dormant. Mushrooms thrive.',
    skyTop: Color(0xFF546E7A),
    skyMid: Color(0xFF78909C),
    skyBottom: Color(0xFFB0BEC5),
    groundLight: Color(0xFFE8F5E9),
    groundDark: Color(0xFFB0BEC5),
    groundWet: Color(0xFFCFD8DC),
    groundSnow: Color(0xFFFFFFFF),
    pathColor: Color(0xFFCFD8DC),
    pondColor: Color(0xFFB3E5FC),
    hasFog: true,
    growthMult: 0.4,
    windStrength: 0.3,
    weatherNote: 'Frost on ground. Only mushrooms & cactus survive well.',
    seasonalPlants: ['mushroom', 'cactus'],
    bonusCoins: 20,
  ),
  Season.snowfall: SeasonConfig(
    name: 'Snowfall',
    emoji: '🌨️',
    description: 'Heavy snow blankets everything. Magical but harsh.',
    skyTop: Color(0xFF37474F),
    skyMid: Color(0xFF546E7A),
    skyBottom: Color(0xFF90A4AE),
    groundLight: Color(0xFFFFFFFF),
    groundDark: Color(0xFFE0E0E0),
    groundWet: Color(0xFFECEFF1),
    groundSnow: Color(0xFFFFFFFF),
    pathColor: Color(0xFFECEFF1),
    pondColor: Color(0xFFE3F2FD),
    hasSnow: true,
    hasFog: true,
    growthMult: 0.3,
    windStrength: 0.6,
    weatherNote: 'Snow covers soil. Plants protected but barely growing.',
    seasonalPlants: ['mushroom'],
    bonusCoins: 25,
  ),
};

// ─── PLANT DATA ──────────────────────────────────────────────────────────────
const _plantData = {
  PlantType.flower: {
    'name': 'Flower',
    'emoji': ['🌰', '🌱', '🌿', '🌸', '🌺', '🌻'],
    'cost': 5,
    'baseReward': 20,
    'tip': 'Loves sunlight. Water daily.'
  },
  PlantType.tree: {
    'name': 'Tree',
    'emoji': ['🌰', '🌱', '🌿', '🌲', '🌳', '🌴'],
    'cost': 15,
    'baseReward': 60,
    'tip': 'Slow grower but high reward.'
  },
  PlantType.bush: {
    'name': 'Bush',
    'emoji': ['🌰', '🌱', '🌿', '🍀', '🌿', '🌳'],
    'cost': 8,
    'baseReward': 30,
    'tip': 'Hardy. Tolerates drought.'
  },
  PlantType.herb: {
    'name': 'Herb',
    'emoji': ['🌰', '🌱', '🌿', '🌿', '🌿', '🌿'],
    'cost': 6,
    'baseReward': 25,
    'tip': 'Fast grower. Needs fertilizer.'
  },
  PlantType.mushroom: {
    'name': 'Mushroom',
    'emoji': ['🌰', '🌱', '🍄', '🍄', '🍄', '🍄'],
    'cost': 10,
    'baseReward': 40,
    'tip': 'Thrives in winter & monsoon.'
  },
  PlantType.cactus: {
    'name': 'Cactus',
    'emoji': ['🌰', '🌱', '🌵', '🌵', '🌵', '🌵'],
    'cost': 12,
    'baseReward': 45,
    'tip': 'Survives extreme conditions.'
  },
  PlantType.bamboo: {
    'name': 'Bamboo',
    'emoji': ['🌰', '🌱', '🎋', '🎋', '🎋', '🎋'],
    'cost': 10,
    'baseReward': 35,
    'tip': 'Grows fast in monsoon.'
  },
  PlantType.lotus: {
    'name': 'Lotus',
    'emoji': ['🌰', '🌱', '🌿', '🪷', '🪷', '🪷'],
    'cost': 20,
    'baseReward': 80,
    'tip': 'Rare beauty. Needs pond nearby.'
  },
  PlantType.sunflower: {
    'name': 'Sunflower',
    'emoji': ['🌰', '🌱', '🌿', '🌻', '🌻', '🌻'],
    'cost': 8,
    'baseReward': 30,
    'tip': 'Follows the sun. Summer bonus.'
  },
  PlantType.lavender: {
    'name': 'Lavender',
    'emoji': ['🌰', '🌱', '🌿', '💜', '💜', '💜'],
    'cost': 15,
    'baseReward': 55,
    'tip': 'Calms meditators. Spring bonus.'
  },
  PlantType.bonsai: {
    'name': 'Bonsai',
    'emoji': ['🌰', '🌱', '🌿', '🎍', '🎍', '🎍'],
    'cost': 25,
    'baseReward': 100,
    'tip': 'Rare. Needs perfect care.'
  },
  PlantType.rose: {
    'name': 'Rose',
    'emoji': ['🌰', '🌱', '🌿', '🌹', '🌹', '🌹'],
    'cost': 12,
    'baseReward': 50,
    'tip': 'Beautiful but delicate.'
  },
};

// ─── SHOP ITEMS ──────────────────────────────────────────────────────────────
const _shopItems = [
  ShopItem(
      id: 'seeds_5',
      name: '5 Seeds',
      emoji: '🌱',
      description: 'Plant 5 more plants',
      cost: 30,
      currency: 'coins',
      effect: {'seeds': 5}),
  ShopItem(
      id: 'seeds_20',
      name: '20 Seeds',
      emoji: '🌱',
      description: 'Bulk seed pack',
      cost: 100,
      currency: 'coins',
      effect: {'seeds': 20}),
  ShopItem(
      id: 'water_full',
      name: 'Full Watering',
      emoji: '💧',
      description: 'Refill water to 100',
      cost: 20,
      currency: 'coins',
      effect: {'water': 100}),
  ShopItem(
      id: 'fertilizer',
      name: '5 Fertilizer',
      emoji: '🧪',
      description: 'Boost plant growth',
      cost: 40,
      currency: 'coins',
      effect: {'fertilizer': 5}),
  ShopItem(
      id: 'rare_seed',
      name: 'Rare Seed',
      emoji: '✨',
      description: 'Plant a rare variant',
      cost: 5,
      currency: 'premium',
      effect: {'rare_seed': 1}),
  ShopItem(
      id: 'grow_boost',
      name: 'Growth Boost',
      emoji: '⚡',
      description: '2x growth for 60 seconds',
      cost: 3,
      currency: 'premium',
      effect: {'grow_boost': 60}),
  ShopItem(
      id: 'bonsai_seed',
      name: 'Bonsai Seed',
      emoji: '🎍',
      description: 'Rare bonsai plant',
      cost: 150,
      currency: 'coins',
      effect: {'plant': 'bonsai'}),
  ShopItem(
      id: 'lotus_seed',
      name: 'Lotus Seed',
      emoji: '🪷',
      description: 'Rare lotus plant',
      cost: 120,
      currency: 'coins',
      effect: {'plant': 'lotus'}),
];

// ─── SCREEN ───────────────────────────────────────────────────────────────────
class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});
  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _adService = AdService();
  final _rng = Random();

  static const int _cols = 16, _rows = 12;

  late List<List<GardenTile>> _grid;

  // Camera — smooth pan with inertia, zoom, and rotation
  double _camX = 0, _camY = 0;
  double _velX = 0, _velY = 0;
  double _zoom = 1.0;
  double _rotation = 0.0;
  Offset? _panStart;
  Offset? _camAtPanStart;
  bool _isPanning = false;
  DateTime? _tapDownTime;
  Offset? _tapDownPos;
  DateTime? _lastTapTime;
  Offset? _lastTapPos;

  // Selection
  GardenTile? _selectedTile;
  bool _showGrid = true;

  Season _season = Season.spring;
  GardenTool _activeTool = GardenTool.plant;
  PlantType _selectedPlantType = PlantType.flower;

  // Resources
  int _coins = 120, _seeds = 10, _waterLevel = 100, _fertilizer = 5;
  int _premiumEnergy = 3;
  int _beautyScore = 0, _xp = 0, _gardenLevel = 1, _xpToNext = 100;
  double _totalO2 = 0;
  int _totalHarvests = 0, _totalPlanted = 0, _totalWatered = 0;
  Set<Season> _visitedSeasons = {};

  // UI state
  bool _showWeatherInfo = false;
  bool _showShop = false;
  bool _showAchievements = false;
  bool _showQuests = false;
  bool _showStats = false;
  bool _showInspectPanel = false;

  // Game systems
  final ComboState _combo = ComboState();
  bool _growBoostActive = false;
  int _growBoostSecondsLeft = 0;
  Timer? _growBoostTimer;

  // Quests
  late List<DailyQuest> _dailyQuests;
  DateTime? _questsDate;

  // Achievements
  late List<GardenAchievement> _achievements;

  // Notification queue
  final List<_Notification> _notifications = [];

  // Weather particles
  final List<RainDrop> _rain = [];
  final List<SnowFlake> _snow = [];
  final List<Particle> _leaves = [];
  final List<Particle> _fireflies = [];
  final List<Particle> _bursts = [];
  final List<FloatingLabel> _labels = [];
  final List<Butterfly> _butterflies = [];
  final List<Bee> _bees = [];

  // Meditators
  late List<Meditator> _meditators;

  late AnimationController _envCtrl, _glowCtrl, _sunCtrl, _fogCtrl;
  late Animation<double> _envAnim, _glowAnim, _sunAnim, _fogAnim;
  Timer? _loop, _growthTimer, _o2Timer, _adTimer;

  SeasonConfig get _cfg => _seasons[_season]!;

  // Y-axis rotation: rotates the camera around the garden center.
  Offset _iso(double col, double row, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.42;

    // Centre the grid so rotation orbits around its middle
    final gc = _cols / 2.0;
    final gr = _rows / 2.0;
    final dc = col - gc;
    final dr = row - gr;

    // Rotate in world-space around Y axis (horizontal plane only)
    final angle = _rotation * pi / 180;
    final cosA = cos(angle);
    final sinA = sin(angle);
    final rc = dc * cosA - dr * sinA;
    final rr = dc * sinA + dr * cosA;

    // Standard isometric projection — use same tile size as painter (72×36)
    const double tW = 72.0, tH = 36.0;
    final wx = (rc - rr) * tW / 2;
    final wy = (rc + rr) * tH / 2;

    return Offset(
      centerX + wx * _zoom + _camX,
      centerY + wy * _zoom + _camY,
    );
  }

  // Inverse: find which tile was tapped.
  // Uses the same tile size as _iso and the painter (72×36).
  GardenTile? _findTileAt(Offset tap, Size size) {
    GardenTile? best;
    double bestDist = double.infinity;

    // Tile half-dimensions in screen space (scaled by zoom)
    const double tW = 72.0, tH = 36.0;
    final hw = tW / 2 * _zoom;
    final hh = tH / 2 * _zoom;

    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        final screenPos = _iso(c + 0.5, r + 0.5, size);
        final dx = tap.dx - screenPos.dx;
        final dy = tap.dy - screenPos.dy;
        // Diamond hit test — dist < 1.2 gives a slightly generous hit zone
        final dist = dx.abs() / hw + dy.abs() / hh;
        if (dist < 1.2 && dist < bestDist) {
          bestDist = dist;
          best = _grid[r][c];
        }
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    _initAchievements();
    _initGrid();
    _loadData();
    _initWeather();
    _initMeditators();
    _initDailyQuests();

    _envCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _sunCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 24))
          ..repeat();
    _fogCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat(reverse: true);
    _envAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_envCtrl);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _sunAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_sunCtrl);
    _fogAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fogCtrl, curve: Curves.easeInOut));

    _startLoop();
    _startGrowthTimer();
    _startO2Timer();
    _startAudio();
    _adTimer = Timer(const Duration(minutes: 3), () {
      if (mounted) _adService.showInterstitial();
    });

    // Track season visit
    _visitedSeasons.add(_season);
  }

  void _initAchievements() {
    _achievements = [
      GardenAchievement(
          type: AchievementType.firstPlant,
          title: 'First Sprout',
          description: 'Plant your first seed',
          emoji: '🌱',
          reward: 20),
      GardenAchievement(
          type: AchievementType.tenPlants,
          title: 'Green Thumb',
          description: 'Have 10 plants growing at once',
          emoji: '🌿',
          reward: 50),
      GardenAchievement(
          type: AchievementType.firstHarvest,
          title: 'First Harvest',
          description: 'Harvest your first plant',
          emoji: '🌾',
          reward: 30),
      GardenAchievement(
          type: AchievementType.level5,
          title: 'Garden Apprentice',
          description: 'Reach garden level 5',
          emoji: '⭐',
          reward: 100),
      GardenAchievement(
          type: AchievementType.level10,
          title: 'Master Gardener',
          description: 'Reach garden level 10',
          emoji: '🏆',
          reward: 250),
      GardenAchievement(
          type: AchievementType.allSeasons,
          title: 'Season Traveler',
          description: 'Experience all 6 seasons',
          emoji: '🌍',
          reward: 150),
      GardenAchievement(
          type: AchievementType.perfectGarden,
          title: 'Perfect Garden',
          description: 'Reach beauty score 500',
          emoji: '🌸',
          reward: 200),
      GardenAchievement(
          type: AchievementType.o2Master,
          title: 'O₂ Master',
          description: 'Produce 100L of oxygen',
          emoji: '🌍',
          reward: 75),
      GardenAchievement(
          type: AchievementType.streakWeek,
          title: 'Dedicated Gardener',
          description: 'Visit garden 7 days in a row',
          emoji: '🔥',
          reward: 120),
    ];
  }

  void _initDailyQuests() {
    final today = DateTime.now();
    final savedDate = LocalStorageService.getSetting('quest_date');
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (savedDate == todayStr) {
      // Load saved quest progress
      final qData = LocalStorageService.getSetting('quest_progress');
      if (qData is String) {
        try {
          final list = jsonDecode(qData) as List;
          _dailyQuests = _buildDailyQuests();
          for (int i = 0; i < list.length && i < _dailyQuests.length; i++) {
            _dailyQuests[i].progress = list[i]['progress'] ?? 0;
            _dailyQuests[i].completed = list[i]['completed'] ?? false;
          }
          return;
        } catch (_) {}
      }
    }
    _dailyQuests = _buildDailyQuests();
    LocalStorageService.saveSetting('quest_date', todayStr);
  }

  List<DailyQuest> _buildDailyQuests() {
    final rng = Random(DateTime.now().day);
    return [
      DailyQuest(
          type: QuestType.plantSeeds,
          title: 'Sow Seeds',
          description: 'Plant ${3 + rng.nextInt(3)} seeds today',
          emoji: '🌱',
          target: 3 + rng.nextInt(3),
          reward: 30),
      DailyQuest(
          type: QuestType.waterPlants,
          title: 'Water Duty',
          description: 'Water ${5 + rng.nextInt(5)} plants today',
          emoji: '💧',
          target: 5 + rng.nextInt(5),
          reward: 25),
      DailyQuest(
          type: QuestType.harvestPlants,
          title: 'Harvest Time',
          description: 'Harvest ${2 + rng.nextInt(2)} plants today',
          emoji: '🌾',
          target: 2 + rng.nextInt(2),
          reward: 50),
      DailyQuest(
          type: QuestType.earnCoins,
          title: 'Coin Collector',
          description: 'Earn 100 coins from garden',
          emoji: '🪙',
          target: 100,
          reward: 40),
    ];
  }

  void _saveQuestProgress() {
    final data = jsonEncode(_dailyQuests
        .map((q) => {'progress': q.progress, 'completed': q.completed})
        .toList());
    LocalStorageService.saveSetting('quest_progress', data);
  }

  void _progressQuest(QuestType type, [int amount = 1]) {
    for (final q in _dailyQuests) {
      if (q.type == type && !q.completed) {
        q.progress = (q.progress + amount).clamp(0, q.target);
        if (q.progress >= q.target) {
          q.completed = true;
          _coins += q.reward;
          _pushNotification('🎯 Quest Complete!',
              '${q.emoji} ${q.title} — +${q.reward} 🪙', Colors.amber);
          HapticFeedback.heavyImpact();
        }
        _saveQuestProgress();
        break;
      }
    }
  }

  void _initGrid() {
    _grid = List.generate(
        _rows,
        (r) => List.generate(_cols, (c) {
              TileType type = TileType.soil;
              if (r == 0 || r == _rows - 1 || c == 0 || c == _cols - 1) {
                type = TileType.fence;
              } else if ((c == 4 || c == 5) && (r == 3 || r == 4))
                type = TileType.pond;
              else if (c == 4 && r > 0 && r < _rows - 1)
                type = TileType.path;
              else if (r == 4 && c > 0 && c < _cols - 1) type = TileType.path;
              return GardenTile(
                  col: c,
                  row: r,
                  tileType: type,
                  fertility: 0.4 + _rng.nextDouble() * 0.4);
            }));

    // Starter plants
    final starters = [
      (2, 1, PlantType.tree, 4),
      (7, 1, PlantType.tree, 3),
      (1, 2, PlantType.flower, 3),
      (3, 2, PlantType.bush, 4),
      (6, 2, PlantType.bamboo, 3),
      (8, 2, PlantType.flower, 2),
      (2, 5, PlantType.herb, 3),
      (7, 5, PlantType.mushroom, 4),
      (1, 6, PlantType.cactus, 3),
      (8, 6, PlantType.flower, 2),
    ];
    for (final s in starters) {
      final t = _grid[s.$2][s.$1];
      if (t.tileType == TileType.soil) {
        t.isPlanted = true;
        t.plantType = s.$3;
        t.growthStage = s.$4;
        t.o2Output = 0.3 + _rng.nextDouble() * 0.5;
        t.xpValue = 10 + s.$4 * 5;
        t.plantedAt =
            DateTime.now().subtract(Duration(hours: _rng.nextInt(24)));
      }
    }
  }

  void _initWeather() {
    for (int i = 0; i < 150; i++) {
      _rain.add(RainDrop(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.014 + _rng.nextDouble() * 0.008,
          length: 0.018 + _rng.nextDouble() * 0.012,
          opacity: 0.35 + _rng.nextDouble() * 0.5,
          windX: -0.001 - _rng.nextDouble() * 0.002));
    }
    for (int i = 0; i < 80; i++) {
      _snow.add(SnowFlake(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          size: 2 + _rng.nextDouble() * 5,
          speed: 0.002 + _rng.nextDouble() * 0.003,
          drift: (_rng.nextDouble() - 0.5) * 0.0015,
          phase: _rng.nextDouble() * pi * 2,
          rotation: _rng.nextDouble() * pi * 2));
    }
    for (int i = 0; i < 5; i++) {
      _butterflies.add(Butterfly(
        x: _rng.nextDouble(),
        y: 0.2 + _rng.nextDouble() * 0.4,
        phase: _rng.nextDouble() * pi * 2,
        speed: 0.001 + _rng.nextDouble() * 0.001,
        emoji: ['🦋', '🦋', '🦋'][_rng.nextInt(3)],
      ));
    }
    for (int i = 0; i < 4; i++) {
      _bees.add(Bee(
        x: _rng.nextDouble(),
        y: 0.3 + _rng.nextDouble() * 0.3,
        targetCol: 1.0 + _rng.nextDouble() * 14,
        targetRow: 1.0 + _rng.nextDouble() * 10,
        phase: _rng.nextDouble() * pi * 2,
      ));
    }
  }

  void _initMeditators() {
    _meditators = [
      Meditator(col: 1.5, row: 1.5, emoji: '🧘', breathPhase: 0, mood: 'calm'),
      Meditator(
          col: 6.5, row: 1.5, emoji: '🧘‍♀️', breathPhase: pi, mood: 'calm'),
      Meditator(
          col: 2.5, row: 6.5, emoji: '🧘', breathPhase: pi / 2, mood: 'calm'),
    ];
  }

  void _loadData() {
    final c = LocalStorageService.getSetting('garden_coins');
    if (c is int) _coins = c;
    final s = LocalStorageService.getSetting('garden_seeds');
    if (s is int) _seeds = s;
    final o = LocalStorageService.getSetting('garden_total_o2');
    if (o is double) _totalO2 = o;
    final l = LocalStorageService.getSetting('garden_level');
    if (l is int) _gardenLevel = l;
    final x = LocalStorageService.getSetting('garden_xp');
    if (x is int) _xp = x;
    final xn = LocalStorageService.getSetting('garden_xp_next');
    if (xn is int) _xpToNext = xn;
    final f = LocalStorageService.getSetting('garden_fertilizer');
    if (f is int) _fertilizer = f;
    final w = LocalStorageService.getSetting('garden_water');
    if (w is int) _waterLevel = w;
    final pe = LocalStorageService.getSetting('garden_premium');
    if (pe is int) _premiumEnergy = pe;
    final th = LocalStorageService.getSetting('garden_total_harvests');
    if (th is int) _totalHarvests = th;
    final tp = LocalStorageService.getSetting('garden_total_planted');
    if (tp is int) _totalPlanted = tp;
    final tw = LocalStorageService.getSetting('garden_total_watered');
    if (tw is int) _totalWatered = tw;
    final sv = LocalStorageService.getSetting('garden_seasons_visited');
    if (sv is String) {
      try {
        final list = jsonDecode(sv) as List;
        _visitedSeasons = list.map((i) => Season.values[i as int]).toSet();
      } catch (_) {}
    }
    // Load achievement states
    final achData = LocalStorageService.getSetting('garden_achievements');
    if (achData is String) {
      try {
        final list = jsonDecode(achData) as List;
        for (int i = 0; i < list.length && i < _achievements.length; i++) {
          _achievements[i].unlocked = list[i]['unlocked'] ?? false;
          if (list[i]['unlockedAt'] != null) {
            _achievements[i].unlockedAt =
                DateTime.tryParse(list[i]['unlockedAt']);
          }
        }
      } catch (_) {}
    }
    // Load grid state
    final gridData = LocalStorageService.getSetting('garden_grid');
    if (gridData is String) {
      try {
        final list = jsonDecode(gridData) as List;
        for (final item in list) {
          final col = item['col'] as int;
          final row = item['row'] as int;
          if (row < _rows && col < _cols) {
            final saved = GardenTile.fromJson(item);
            final t = _grid[row][col];
            t.isPlanted = saved.isPlanted;
            t.plantType = saved.plantType;
            t.growthStage = saved.growthStage;
            t.water = saved.water;
            t.health = saved.health;
            t.fertility = saved.fertility;
            t.o2Output = saved.o2Output;
            t.xpValue = saved.xpValue;
            t.isRare = saved.isRare;
            t.careCount = saved.careCount;
            t.plantedAt = saved.plantedAt;
          }
        }
      } catch (_) {}
    }
    _recalcBeauty();
  }

  Future<void> _saveData() async {
    await LocalStorageService.saveSetting('garden_coins', _coins);
    await LocalStorageService.saveSetting('garden_seeds', _seeds);
    await LocalStorageService.saveSetting('garden_total_o2', _totalO2);
    await LocalStorageService.saveSetting('garden_level', _gardenLevel);
    await LocalStorageService.saveSetting('garden_xp', _xp);
    await LocalStorageService.saveSetting('garden_xp_next', _xpToNext);
    await LocalStorageService.saveSetting('garden_fertilizer', _fertilizer);
    await LocalStorageService.saveSetting('garden_water', _waterLevel);
    await LocalStorageService.saveSetting('garden_premium', _premiumEnergy);
    await LocalStorageService.saveSetting(
        'garden_total_harvests', _totalHarvests);
    await LocalStorageService.saveSetting(
        'garden_total_planted', _totalPlanted);
    await LocalStorageService.saveSetting(
        'garden_total_watered', _totalWatered);
    await LocalStorageService.saveSetting('garden_seasons_visited',
        jsonEncode(_visitedSeasons.map((s) => s.index).toList()));
    // Save achievements
    await LocalStorageService.saveSetting(
        'garden_achievements',
        jsonEncode(_achievements
            .map((a) => {
                  'unlocked': a.unlocked,
                  'unlockedAt': a.unlockedAt?.toIso8601String()
                })
            .toList()));
    // Save grid (only planted tiles to save space)
    final planted = _grid
        .expand((r) => r)
        .where((t) => t.isPlanted)
        .map((t) => t.toJson())
        .toList();
    await LocalStorageService.saveSetting('garden_grid', jsonEncode(planted));
    await LocalStorageService.saveSetting(
        'garden_plants_grown', planted.length);
  }

  void _startLoop() {
    // 30fps is sufficient for particle/weather updates — halves main thread load
    _loop = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      setState(() {
        _updateWeather();
        _updateLabels();
        _updateBursts();
        _updateMeditators();
        _updateCreatures();
        if (_cfg.hasLeaves) _tickLeaves();
        if (_cfg.hasFireflies) _tickFireflies();
        // Camera inertia
        if (!_isPanning && (_velX.abs() > 0.5 || _velY.abs() > 0.5)) {
          final limit = 300.0 * _zoom;
          _camX = (_camX + _velX).clamp(-limit, limit);
          _camY = (_camY + _velY).clamp(-limit * 0.7, limit * 0.7);
          _velX *= 0.90;
          _velY *= 0.90;
          if (_velX.abs() < 0.5) _velX = 0;
          if (_velY.abs() < 0.5) _velY = 0;
        }
        // Notification decay
        _notifications.removeWhere((n) => n.life <= 0);
        for (final n in _notifications) {
          n.life -= 0.02;
        }
      });
    });
  }

  void _updateWeather() {
    if (_cfg.hasRain) {
      for (final d in _rain) {
        d.y += d.speed;
        d.x += d.windX * _cfg.windStrength;
        if (d.y > 1.0 + d.length) {
          d.y = -d.length;
          d.x = _rng.nextDouble();
        }
        if (d.x < -0.05) d.x = 1.05;
      }
    }
    if (_cfg.hasSnow) {
      for (final s in _snow) {
        s.phase += 0.04;
        s.rotation += 0.02;
        s.y += s.speed;
        s.x += s.drift + sin(s.phase) * 0.0008;
        if (s.y > 1.05) {
          s.y = -0.05;
          s.x = _rng.nextDouble();
        }
        if (s.x < 0) s.x = 1.0;
        if (s.x > 1.0) s.x = 0.0;
      }
    }
  }

  void _tickLeaves() {
    if (_leaves.length < 25 && _rng.nextDouble() < 0.04) {
      _leaves.add(Particle(
          x: _rng.nextDouble(),
          y: 0.05 + _rng.nextDouble() * 0.25,
          vx: (_rng.nextDouble() - 0.3) * 0.004 * _cfg.windStrength,
          vy: 0.0015 + _rng.nextDouble() * 0.002,
          color: [
            const Color(0xFFE65100),
            const Color(0xFFBF360C),
            const Color(0xFFF57F17),
            const Color(0xFFFF6F00)
          ][_rng.nextInt(4)],
          size: 7 + _rng.nextDouble() * 7,
          rotation: _rng.nextDouble() * pi * 2));
    }
    for (final p in _leaves) {
      p.x += p.vx;
      p.y += p.vy;
      p.rotation += 0.04;
      p.life -= 0.004;
    }
    _leaves.removeWhere((p) => p.life <= 0 || p.y > 1.0);
  }

  void _tickFireflies() {
    if (_fireflies.length < 12 && _rng.nextDouble() < 0.03) {
      _fireflies.add(Particle(
          x: _rng.nextDouble(),
          y: 0.3 + _rng.nextDouble() * 0.4,
          vx: (_rng.nextDouble() - 0.5) * 0.002,
          vy: (_rng.nextDouble() - 0.5) * 0.001,
          color: Colors.yellowAccent,
          size: 4,
          life: 2.0 + _rng.nextDouble()));
    }
    for (final f in _fireflies) {
      f.x += f.vx + sin(f.life * 3) * 0.001;
      f.y += f.vy + cos(f.life * 2) * 0.0008;
      f.life -= 0.008;
      if (f.x < 0) f.x = 1.0;
      if (f.x > 1.0) f.x = 0.0;
    }
    _fireflies.removeWhere((f) => f.life <= 0);
  }

  void _updateMeditators() {
    for (final m in _meditators) {
      m.breathPhase += 0.025;
      // Decay speech bubble
      if (m.speechLife > 0) {
        m.speechLife -= 0.015;
        if (m.speechLife <= 0) m.speechBubble = null;
      }
    }
  }

  void _updateCreatures() {
    if (_cfg.hasButterflies) {
      for (final b in _butterflies) {
        b.phase += b.speed * 2;
        b.x += sin(b.phase) * 0.003;
        b.y += cos(b.phase * 0.7) * 0.002;
        if (b.x < 0) b.x = 1.0;
        if (b.x > 1.0) b.x = 0.0;
        if (b.y < 0.1) b.y = 0.1;
        if (b.y > 0.8) b.y = 0.8;
      }
    }
    if (_cfg.hasBees) {
      for (final b in _bees) {
        b.phase += 0.08;
        // Buzz toward target
        final tx = b.targetCol / _cols;
        final ty = b.targetRow / _rows;
        b.x += (tx - b.x) * 0.01 + sin(b.phase * 3) * 0.003;
        b.y += (ty - b.y) * 0.01 + cos(b.phase * 2) * 0.002;
        // Pick new target when close
        if ((b.x - tx).abs() < 0.02 && (b.y - ty).abs() < 0.02) {
          b.targetCol = 1.0 + _rng.nextDouble() * 14;
          b.targetRow = 1.0 + _rng.nextDouble() * 10;
        }
      }
    }
  }

  void _updateLabels() {
    for (final l in _labels) {
      l.y -= 0.0025;
      l.life -= 0.018;
    }
    _labels.removeWhere((l) => l.life <= 0);
  }

  void _updateBursts() {
    for (final p in _bursts) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.0002;
      p.life -= 0.025;
    }
    _bursts.removeWhere((p) => p.life <= 0);
  }

  void _startGrowthTimer() {
    _growthTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() {
        for (final row in _grid) {
          for (final t in row) {
            if (!t.isPlanted || t.tileType != TileType.soil) continue;
            // Weather effects on water
            t.water = (t.water - 0.05).clamp(0, 1);
            if (_cfg.hasRain) t.water = (t.water + 0.12).clamp(0, 1);
            if (_season == Season.summer) {
              t.water = (t.water - 0.03).clamp(0, 1);
            }
            if (_cfg.hasSnow) t.water = (t.water + 0.02).clamp(0, 1);
            // Health decay when dry
            if (t.water < 0.2) t.health = (t.health - 0.04).clamp(0, 1);
            if (t.water > 0.5) t.health = (t.health + 0.01).clamp(0, 1);
            // Season-specific plant survival
            final isHardy = t.plantType == PlantType.mushroom ||
                t.plantType == PlantType.cactus;
            if (_season == Season.winter && !isHardy) {
              t.health = (t.health - 0.02).clamp(0, 1);
            }
            if (_season == Season.snowfall && !isHardy) {
              t.health = (t.health - 0.03).clamp(0, 1);
            }
            // Seasonal bonus for matching plants
            final plantName = t.plantType?.name ?? '';
            final isSeasonalBonus = _cfg.seasonalPlants.contains(plantName);
            // Growth
            if (t.water > 0.3 && t.health > 0.3 && t.growthStage < 5) {
              double mult = _cfg.growthMult;
              if (isHardy &&
                  (_season == Season.winter || _season == Season.snowfall)) {
                mult *= 1.5;
              }
              if (isSeasonalBonus) mult *= 1.3;
              if (_growBoostActive) mult *= 2.0;
              if (_rng.nextDouble() < t.fertility * mult * 0.18) {
                t.growthStage++;
                t.o2Output = (t.o2Output + 0.12).clamp(0, 2.5);
                t.isGlowing = true;
                final xpGain = t.isRare ? 25 : 12;
                _addXP(xpGain, t.col.toDouble(), t.row.toDouble(),
                    '+$xpGain XP 🌱');
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => t.isGlowing = false);
                });
                // Notify when fully grown
                if (t.growthStage == 5) {
                  _pushNotification(
                      '🌟 Plant Fully Grown!',
                      '${_plantEmoji(t.plantType!, 5)} ${t.plantType!.name} is ready to harvest!',
                      Colors.greenAccent);
                }
              }
            }
            // Plant death
            if (t.health <= 0) {
              t.isPlanted = false;
              t.plantType = null;
              t.growthStage = 0;
              t.water = 0.5;
              t.health = 1.0;
              t.o2Output = 0;
              _labels.add(FloatingLabel(
                  x: t.col / _cols,
                  y: t.row / _rows,
                  text: '💀 Died',
                  color: Colors.red));
            }
          }
        }
        _recalcBeauty();
        _checkAchievements();
      });
    });
  }

  void _startO2Timer() {
    _o2Timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      double o2 = 0;
      for (final row in _grid) {
        for (final t in row) {
          if (t.isPlanted && t.growthStage > 1) {
            o2 += t.o2Output * t.growthStage * 0.06;
          }
        }
      }
      setState(() {
        _totalO2 += o2;
        if (o2 > 0.05) {
          _labels.add(FloatingLabel(
              x: 0.45 + _rng.nextDouble() * 0.1,
              y: 0.3,
              text: '+${o2.toStringAsFixed(1)}L O₂',
              color: const Color(0xFF00E5FF)));
        }
      });
      _saveData();
    });
  }

  void _checkAchievements() {
    final plantCount = _grid.expand((r) => r).where((t) => t.isPlanted).length;
    _unlockAchievement(AchievementType.firstPlant, _totalPlanted >= 1);
    _unlockAchievement(AchievementType.tenPlants, plantCount >= 10);
    _unlockAchievement(AchievementType.firstHarvest, _totalHarvests >= 1);
    _unlockAchievement(AchievementType.level5, _gardenLevel >= 5);
    _unlockAchievement(AchievementType.level10, _gardenLevel >= 10);
    _unlockAchievement(AchievementType.allSeasons, _visitedSeasons.length >= 6);
    _unlockAchievement(AchievementType.perfectGarden, _beautyScore >= 500);
    _unlockAchievement(AchievementType.o2Master, _totalO2 >= 100);
  }

  void _unlockAchievement(AchievementType type, bool condition) {
    final ach = _achievements.firstWhere((a) => a.type == type);
    if (!ach.unlocked && condition) {
      ach.unlocked = true;
      ach.unlockedAt = DateTime.now();
      _coins += ach.reward;
      _pushNotification('🏆 Achievement Unlocked!',
          '${ach.emoji} ${ach.title} — +${ach.reward} 🪙', Colors.amber);
      HapticFeedback.heavyImpact();
    }
  }

  void _pushNotification(String title, String body, Color color) {
    _notifications.insert(
        0, _Notification(title: title, body: body, color: color));
    if (_notifications.length > 3) _notifications.removeLast();
  }

  void _startAudio() async {
    try {
      await _audio.setVolume(0.3);
      final sound = switch (_season) {
        Season.monsoon => 'rain',
        Season.winter || Season.snowfall => 'wind',
        _ => 'forest',
      };
      await _audio.playSound(sound, loop: true);
    } catch (_) {
      // Audio files may not exist in all builds — fail silently
    }
  }

  void _recalcBeauty() {
    _beautyScore = 0;
    for (final row in _grid) {
      for (final t in row) {
        if (t.isPlanted) {
          _beautyScore += t.growthStage * 9 + (t.health * 5).toInt();
          if (t.isRare) _beautyScore += 20;
        }
      }
    }
  }

  void _addXP(int amount, double col, double row, String text) {
    _xp += amount;
    if (_xp >= _xpToNext) {
      _xp -= _xpToNext;
      _gardenLevel++;
      _xpToNext = (_xpToNext * 1.3).toInt();
      _pushNotification('⭐ Level Up!',
          'Garden Level $_gardenLevel! New plants unlocked!', Colors.yellow);
      HapticFeedback.heavyImpact();
    }
    _labels.add(FloatingLabel(
        x: col / _cols, y: row / _rows, text: text, color: Colors.greenAccent));
  }

  void _spawnBurst(double sx, double sy, Color color, Size size) {
    for (int i = 0; i < 16; i++) {
      final angle = (i / 16) * pi * 2;
      final spd = 0.005 + _rng.nextDouble() * 0.005;
      _bursts.add(Particle(
          x: sx / size.width,
          y: sy / size.height,
          vx: cos(angle) * spd,
          vy: sin(angle) * spd,
          color: color,
          size: 3 + _rng.nextDouble() * 4,
          life: 1.0));
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─── GESTURE HANDLING ─────────────────────────────────────────────────────
  // Single finger: pan the camera (translate X/Y)
  // Rotation is Y-axis only via the control buttons (45° steps)
  // Double-tap: quick action on tile

  void _onPointerDown(PointerDownEvent e) {
    _tapDownTime = DateTime.now();
    _tapDownPos = e.localPosition;
    _panStart = e.localPosition;
    _camAtPanStart = Offset(_camX, _camY);
    _isPanning = false;
    _velX = 0;
    _velY = 0;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_panStart == null || _camAtPanStart == null) return;
    final dx = e.localPosition.dx - _panStart!.dx;
    final dy = e.localPosition.dy - _panStart!.dy;
    if (!_isPanning && (dx.abs() > 12 || dy.abs() > 12)) _isPanning = true;
    if (_isPanning) {
      // Pan limit scales with zoom so you can't pan off-screen when zoomed out
      final limit = 300.0 * _zoom;
      setState(() {
        _camX = (_camAtPanStart!.dx + dx).clamp(-limit, limit);
        _camY = (_camAtPanStart!.dy + dy).clamp(-limit * 0.7, limit * 0.7);
        _velX = e.delta.dx;
        _velY = e.delta.dy;
      });
    }
  }

  void _onPointerUp(PointerUpEvent e, Size size) {
    if (!_isPanning && _tapDownPos != null) {
      final elapsed = DateTime.now()
          .difference(_tapDownTime ?? DateTime.now())
          .inMilliseconds;
      if (elapsed < 500) {
        // Double-tap detection
        if (_lastTapTime != null &&
            _lastTapPos != null &&
            DateTime.now().difference(_lastTapTime!).inMilliseconds < 400 &&
            (_lastTapPos! - _tapDownPos!).distance < 30) {
          _handleDoubleTap(_tapDownPos!, size);
          _lastTapTime = null;
          _lastTapPos = null;
        } else {
          _handleTap(_tapDownPos!, size);
          _lastTapTime = DateTime.now();
          _lastTapPos = _tapDownPos;
        }
      }
    }
    _isPanning = false;
    _panStart = null;
    _camAtPanStart = null;
  }

  void _handleDoubleTap(Offset tap, Size size) {
    // Double-tap: quick water if water tool, or quick harvest if harvest tool
    final hit = _findTileAt(tap, size);
    if (hit == null) return;
    if (hit.isPlanted) {
      if (_activeTool == GardenTool.water || _activeTool == GardenTool.plant) {
        _doWater(hit, tap, size);
      } else if (_activeTool == GardenTool.harvest && hit.growthStage >= 4) {
        _doHarvest(hit, tap, size);
      }
    }
  }

  void _handleTap(Offset tap, Size size) {
    // Check meditator tap first (before tile hit test)
    for (final m in _meditators) {
      final mPos = _iso(m.col, m.row, size);
      if ((tap - mPos).distance < 30) {
        _tapMeditator(m);
        return;
      }
    }

    final hit = _findTileAt(tap, size);
    if (hit == null) {
      setState(() => _selectedTile = null);
      return;
    }

    if (hit.tileType == TileType.pond || hit.tileType == TileType.fence) {
      _showSnack(hit.tileType == TileType.pond
          ? '🌊 That\'s the pond!'
          : '🚧 That\'s the fence!');
      return;
    }

    HapticFeedback.selectionClick();

    switch (_activeTool) {
      case GardenTool.plant:
        if (!hit.isPlanted) {
          _doPlant(hit, tap, size);
        } else {
          setState(() => _selectedTile = hit);
        }
        break;
      case GardenTool.water:
        if (hit.isPlanted) {
          _doWater(hit, tap, size);
        } else {
          _showSnack('Nothing planted here');
        }
        break;
      case GardenTool.fertilize:
        if (hit.isPlanted) {
          _doFertilize(hit, tap, size);
        } else {
          _showSnack('Nothing planted here');
        }
        break;
      case GardenTool.harvest:
        if (hit.isPlanted) {
          _doHarvest(hit, tap, size);
        } else {
          _showSnack('Nothing to harvest');
        }
        break;
      case GardenTool.remove:
        if (hit.isPlanted) _doRemove(hit);
        break;
      case GardenTool.inspect:
        setState(() {
          _selectedTile = hit;
          _showInspectPanel = true;
        });
        break;
    }
  }

  void _tapMeditator(Meditator m) {
    // Seasonal greetings from meditators
    final greetings = switch (_season) {
      Season.spring => [
          '🌸 Ahh, spring!',
          '🌱 New beginnings...',
          '🌼 So peaceful'
        ],
      Season.summer => [
          '☀️ Warm and bright!',
          '🌻 Full of energy!',
          '😎 Perfect day'
        ],
      Season.monsoon => [
          '🌧️ Rain cleanses all',
          '💧 I love the rain...',
          '☂️ Stay dry!'
        ],
      Season.autumn => [
          '🍂 Let things go...',
          '🌾 Time to harvest',
          '🍁 Beautiful decay'
        ],
      Season.winter => [
          '❄️ Still and quiet',
          '🌨️ Inner warmth...',
          '🧣 Brr, cold!'
        ],
      Season.snowfall => [
          '🌨️ Magical snow!',
          '❄️ Pure silence...',
          '⛄ So beautiful'
        ],
    };
    setState(() {
      m.speechBubble = greetings[_rng.nextInt(greetings.length)];
      m.speechLife = 1.0;
      m.mood = 'happy';
    });
    HapticFeedback.lightImpact();
    // Reset mood after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => m.mood = 'calm');
    });
  }

  void _doPlant(GardenTile t, Offset tap, Size size) {
    final data = _plantData[_selectedPlantType]!;
    final seedCost = data['cost'] as int;
    if (_seeds <= 0) {
      _showSnack('No seeds! Buy more in the shop.');
      return;
    }
    if (_coins < seedCost) {
      _showSnack('Need $seedCost 🪙 to plant ${data['name']}');
      return;
    }
    setState(() {
      _seeds--;
      _coins -= seedCost;
      t.isPlanted = true;
      t.plantType = _selectedPlantType;
      t.growthStage = 1;
      t.water = 0.65;
      t.health = 1.0;
      t.o2Output = 0.1;
      t.xpValue = 10;
      t.careCount = 0;
      t.plantedAt = DateTime.now();
      // Rare chance
      t.isRare = _rng.nextDouble() < 0.08;
      if (t.isRare) {
        _spawnBurst(tap.dx, tap.dy, Colors.purple, size);
        _labels.add(FloatingLabel(
            x: tap.dx / size.width,
            y: tap.dy / size.height,
            text: '✨ RARE!',
            color: Colors.purple,
            scale: 1.4));
        _pushNotification('✨ Rare Plant!',
            'You planted a rare ${data['name']}! +2x rewards!', Colors.purple);
      } else {
        _spawnBurst(tap.dx, tap.dy, Colors.lightGreen, size);
        _labels.add(FloatingLabel(
            x: tap.dx / size.width,
            y: tap.dy / size.height,
            text: '🌱 Planted!',
            color: Colors.lightGreen));
      }
      _totalPlanted++;
      _combo.increment();
      if (_combo.isActive) {
        _labels.add(FloatingLabel(
            x: tap.dx / size.width,
            y: (tap.dy - 30) / size.height,
            text: _combo.label,
            color: Colors.orange,
            scale: 1.2));
      }
    });
    _progressQuest(QuestType.plantSeeds);
    _saveData();
  }

  void _doWater(GardenTile t, Offset tap, Size size) {
    if (_waterLevel <= 0) {
      _showSnack('No water! Refill in the shop.');
      return;
    }
    setState(() {
      _waterLevel = (_waterLevel - 8).clamp(0, 100);
      t.water = (t.water + 0.4).clamp(0, 1);
      t.health = (t.health + 0.05).clamp(0, 1);
      t.careCount++;
      _spawnBurst(tap.dx, tap.dy, const Color(0xFF64B5F6), size);
      _labels.add(FloatingLabel(
          x: tap.dx / size.width,
          y: tap.dy / size.height,
          text: '💧 Watered',
          color: const Color(0xFF64B5F6)));
      _totalWatered++;
      _combo.increment();
      if (_combo.isActive) {
        _labels.add(FloatingLabel(
            x: tap.dx / size.width,
            y: (tap.dy - 30) / size.height,
            text: _combo.label,
            color: Colors.orange,
            scale: 1.2));
      }
    });
    _progressQuest(QuestType.waterPlants);
  }

  void _doFertilize(GardenTile t, Offset tap, Size size) {
    if (_fertilizer <= 0) {
      _showSnack('No fertilizer! Buy more in the shop.');
      return;
    }
    setState(() {
      _fertilizer--;
      t.fertility = (t.fertility + 0.3).clamp(0, 1);
      t.health = (t.health + 0.1).clamp(0, 1);
      t.careCount++;
      _spawnBurst(tap.dx, tap.dy, Colors.orange, size);
      _labels.add(FloatingLabel(
          x: tap.dx / size.width,
          y: tap.dy / size.height,
          text: '🧪 Fertilized!',
          color: Colors.orange));
      _combo.increment();
    });
  }

  void _doHarvest(GardenTile t, Offset tap, Size size) {
    if (t.growthStage < 4) {
      _showSnack('Not ready yet — Stage ${t.growthStage}/5');
      return;
    }
    // Compute reward outside setState so we can use it for quest tracking
    final data = _plantData[t.plantType]!;
    final baseReward = data['baseReward'] as int;
    double reward = baseReward * t.growthStage * 0.4 + (t.health * 28);
    if (t.isRare) reward *= 2.0;
    final plantName = t.plantType?.name ?? '';
    if (_cfg.seasonalPlants.contains(plantName)) reward += _cfg.bonusCoins;
    reward *= _combo.multiplier;
    if (t.careCount >= 5) reward *= 1.5;
    final coinReward = reward.toInt();

    setState(() {
      _coins += coinReward;
      _seeds += t.growthStage;
      _spawnBurst(tap.dx, tap.dy, Colors.amber, size);
      _addXP(t.xpValue * t.growthStage * (t.isRare ? 2 : 1), t.col.toDouble(),
          t.row.toDouble(), '+${t.xpValue * t.growthStage} XP 🌟');
      _labels.add(FloatingLabel(
          x: tap.dx / size.width,
          y: tap.dy / size.height,
          text: '+$coinReward 🪙${t.isRare ? " ✨" : ""}',
          color: Colors.amber,
          scale: t.isRare ? 1.4 : 1.0));
      if (t.careCount >= 5) {
        _labels.add(FloatingLabel(
            x: tap.dx / size.width,
            y: (tap.dy - 25) / size.height,
            text: '💚 Perfect Care!',
            color: Colors.greenAccent));
      }
      t.isPlanted = false;
      t.plantType = null;
      t.growthStage = 0;
      t.water = 0.5;
      t.health = 1.0;
      t.o2Output = 0;
      t.isRare = false;
      t.careCount = 0;
      _selectedTile = null;
      _recalcBeauty();
      _totalHarvests++;
      _combo.increment();
      HapticFeedback.mediumImpact();
    });
    _progressQuest(QuestType.harvestPlants);
    _progressQuest(
        QuestType.earnCoins, coinReward); // track actual coins earned
    _saveData();
  }

  void _doRemove(GardenTile t) {
    setState(() {
      t.isPlanted = false;
      t.plantType = null;
      t.growthStage = 0;
      t.water = 0.5;
      t.health = 1.0;
      t.o2Output = 0;
      t.isRare = false;
      t.careCount = 0;
      _selectedTile = null;
      _recalcBeauty();
    });
    _saveData();
  }

  void _buyShopItem(ShopItem item) {
    if (item.currency == 'coins' && _coins < item.cost) {
      _showSnack('Need ${item.cost} 🪙');
      return;
    }
    if (item.currency == 'premium' && _premiumEnergy < item.cost) {
      _showSnack('Need ${item.cost} ⚡ premium energy');
      return;
    }
    setState(() {
      if (item.currency == 'coins') {
        _coins -= item.cost;
      } else {
        _premiumEnergy -= item.cost;
      }

      final e = item.effect;
      if (e.containsKey('seeds')) _seeds += e['seeds'] as int;
      if (e.containsKey('water')) _waterLevel = e['water'] as int;
      if (e.containsKey('fertilizer')) _fertilizer += e['fertilizer'] as int;
      if (e.containsKey('rare_seed')) {
        _seeds += 1;
        _pushNotification(
            '✨ Rare Seed!', 'Next plant you grow will be rare!', Colors.purple);
      }
      if (e.containsKey('grow_boost')) {
        _growBoostActive = true;
        _growBoostSecondsLeft = e['grow_boost'] as int;
        _growBoostTimer?.cancel();
        _growBoostTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) {
            t.cancel();
            return;
          }
          setState(() {
            _growBoostSecondsLeft--;
            if (_growBoostSecondsLeft <= 0) {
              _growBoostActive = false;
              t.cancel();
            }
          });
        });
        _pushNotification('⚡ Growth Boost!', '2x growth speed for 60 seconds!',
            Colors.yellow);
      }
    });
    _pushNotification(
        '🛒 Purchased!', '${item.emoji} ${item.name}', Colors.green);
    _saveData();
  }

  @override
  void dispose() {
    _envCtrl.dispose();
    _glowCtrl.dispose();
    _sunCtrl.dispose();
    _fogCtrl.dispose();
    _loop?.cancel();
    _growthTimer?.cancel();
    _o2Timer?.cancel();
    _adTimer?.cancel();
    _growBoostTimer?.cancel();
    _audio.stopSound();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        // ── VISUAL LAYERS (all IgnorePointer so they never block taps) ──────

        // Sky gradient
        AnimatedContainer(
            duration: const Duration(milliseconds: 1200),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_cfg.skyTop, _cfg.skyMid, _cfg.skyBottom],
              stops: const [0.0, 0.5, 1.0],
            ))),

        // Atmosphere — IgnorePointer so birds/clouds don't block taps
        IgnorePointer(child: _buildAtmosphere(size)),

        // Fog overlay
        if (_cfg.hasFog)
          IgnorePointer(
            child: AnimatedBuilder(
                animation: _fogAnim,
                builder: (_, __) => Positioned.fill(
                    child: Container(
                        color: Colors.white
                            .withOpacity(0.08 + _fogAnim.value * 0.06)))),
          ),

        // Isometric garden — the ONLY interactive layer
        Positioned.fill(
            child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: (e) => _onPointerUp(e, size),
          child: AnimatedBuilder(
            animation: Listenable.merge([_envAnim, _glowAnim]),
            builder: (_, __) => CustomPaint(
              painter: _GardenPainter(
                grid: _grid,
                cols: _cols,
                rows: _rows,
                cfg: _cfg,
                season: _season,
                camX: _camX,
                camY: _camY,
                glowValue: _glowAnim.value,
                selectedTile: _selectedTile,
                meditators: _meditators,
                envValue: _envAnim.value,
                screenSize: size,
                zoom: _zoom,
                rotation: _rotation,
                butterflies: _butterflies,
                bees: _bees,
                showGrid: _showGrid,
              ),
              size: size,
            ),
          ),
        )),

        // Weather overlays — all IgnorePointer
        if (_cfg.hasRain)
          IgnorePointer(
              child: Positioned.fill(
                  child: CustomPaint(painter: _RainPainter(_rain, size)))),
        if (_cfg.hasSnow)
          IgnorePointer(
              child: Positioned.fill(
                  child: CustomPaint(painter: _SnowPainter(_snow, size)))),
        if (_cfg.hasLeaves)
          IgnorePointer(
              child: Positioned.fill(
                  child: CustomPaint(painter: _LeafPainter(_leaves, size)))),
        if (_cfg.hasFireflies)
          IgnorePointer(
              child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, __) => Positioned.fill(
                      child: CustomPaint(
                          painter: _FireflyPainter(
                              _fireflies, size, _glowAnim.value))))),

        // Burst particles + floating labels — IgnorePointer
        IgnorePointer(
            child: Positioned.fill(
                child: CustomPaint(painter: _BurstPainter(_bursts, size)))),
        IgnorePointer(
            child: Positioned.fill(
                child: CustomPaint(painter: _LabelPainter(_labels, size)))),

        // ── UI LAYERS (interactive) ──────────────────────────────────────────
        _buildTopHUD(size),
        _buildSeasonBar(size),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar(size)),
        _buildO2Meter(),
        _buildGrowBoostIndicator(),

        // Notifications — IgnorePointer so they don't block garden taps
        IgnorePointer(child: _buildNotifications(size)),

        // Weather info panel
        if (_showWeatherInfo) _buildWeatherInfo(size),

        // Selected tile panel
        if (_selectedTile != null && _selectedTile!.isPlanted)
          Positioned(
              left: 12,
              right: 72,
              bottom: 185 + MediaQuery.of(context).padding.bottom,
              child: _buildTilePanel(_selectedTile!)),

        // Overlay panels
        if (_showShop) _buildShopPanel(size),
        if (_showAchievements) _buildAchievementsPanel(size),
        if (_showQuests) _buildQuestsPanel(size),
        if (_showStats) _buildStatsPanel(size),

        // Camera controls
        Positioned(
            right: 12,
            bottom: 210 + MediaQuery.of(context).padding.bottom,
            child: _buildCameraControls()),

        // Right side action buttons
        Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 120,
            child: _buildSideButtons()),
      ]),
    );
  }

  Widget _buildAtmosphere(Size size) {
    return AnimatedBuilder(
        animation: _sunAnim,
        builder: (_, __) {
          final w = <Widget>[];

          if (_season == Season.winter || _season == Season.snowfall) {
            w.add(const Positioned(
                top: 28,
                right: 48,
                child: Text('🌕', style: TextStyle(fontSize: 38))));
            for (int i = 0; i < 8; i++) {
              w.add(Positioned(
                  left: 20.0 + i * 40,
                  top: 10.0 + (i % 3) * 15,
                  child: Text('✦',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4 + (i % 3) * 0.2),
                          fontSize: 8))));
            }
          } else {
            final sx = 20 + _sunAnim.value * (size.width - 80);
            final sy = 10 + sin(_sunAnim.value * pi) * -55 + 55;
            if (_season == Season.summer) {
              w.add(Positioned(
                  left: sx - 20,
                  top: sy - 20,
                  child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Colors.yellow.withOpacity(0.35),
                            Colors.transparent
                          ])))));
            }
            w.add(Positioned(
                left: sx,
                top: sy,
                child: Text(_season == Season.summer ? '☀️' : '🌤️',
                    style: const TextStyle(fontSize: 38))));
          }

          // Clouds
          final cloudSpeed = _cfg.windStrength;
          for (int i = 0; i < 5; i++) {
            final offset = (_envAnim.value * cloudSpeed + i * 0.2) % 1.0;
            final cx = offset * (size.width + 120) - 120;
            final cy = 18.0 + i * 20;
            final opacity = _season == Season.monsoon ? 0.92 : 0.6;
            final emoji = _season == Season.monsoon
                ? '🌧️'
                : _season == Season.snowfall
                    ? '🌨️'
                    : '☁️';
            final fs = 24.0 + (i % 3) * 10;
            w.add(Positioned(
                left: cx,
                top: cy,
                child: Opacity(
                    opacity: opacity,
                    child: Text(emoji, style: TextStyle(fontSize: fs)))));
          }

          // Birds
          if (_season == Season.spring || _season == Season.summer) {
            final bx = (_envAnim.value * 0.6 % 1.0) * size.width;
            w.add(Positioned(
                left: bx,
                top: 75,
                child: const Text('🐦 🐦', style: TextStyle(fontSize: 13))));
          }

          // Rainbow in spring
          if (_season == Season.spring) {
            w.add(Positioned(
                left: size.width * 0.1,
                top: size.height * 0.08,
                child: Opacity(
                    opacity: 0.25,
                    child: Container(
                        width: size.width * 0.8,
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                          ]),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(200)),
                        )))));
          }

          return Stack(children: w);
        });
  }

  Widget _buildTopHUD(Size size) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
            child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            GestureDetector(
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/main'),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18)),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: () =>
                    setState(() => _showWeatherInfo = !_showWeatherInfo),
                child: Text('${_cfg.emoji} ${_cfg.name}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
            const Spacer(),
            _hudChip('🌸', '$_beautyScore'),
            const SizedBox(width: 5),
            // XP bar
            Column(mainAxisSize: MainAxisSize.min, children: [
              _hudChip('⭐', 'Lv.$_gardenLevel'),
              const SizedBox(height: 2),
              SizedBox(
                  width: 50,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                          value: (_xp / _xpToNext).clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          color: Colors.yellow,
                          minHeight: 3))),
            ]),
            const SizedBox(width: 5),
            _hudChip('🪙', '$_coins'),
            const SizedBox(width: 5),
            _hudChip('⚡', '$_premiumEnergy'),
          ]),
        )));
  }

  Widget _hudChip(String icon, String val) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Text('$icon $val',
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)));

  Widget _buildSideButtons() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _sideBtn(
          '🛒',
          'Shop',
          () => setState(() {
                _showShop = !_showShop;
                _showAchievements = false;
                _showQuests = false;
                _showStats = false;
              }),
          _showShop),
      const SizedBox(height: 8),
      _sideBtn(
          '🏆',
          'Awards',
          () => setState(() {
                _showAchievements = !_showAchievements;
                _showShop = false;
                _showQuests = false;
                _showStats = false;
              }),
          _showAchievements),
      const SizedBox(height: 8),
      _sideBtn(
          '🎯',
          'Quests',
          () => setState(() {
                _showQuests = !_showQuests;
                _showShop = false;
                _showAchievements = false;
                _showStats = false;
              }),
          _showQuests),
      const SizedBox(height: 8),
      _sideBtn(
          '📊',
          'Stats',
          () => setState(() {
                _showStats = !_showStats;
                _showShop = false;
                _showAchievements = false;
                _showQuests = false;
              }),
          _showStats),
    ]);
  }

  Widget _sideBtn(String emoji, String label, VoidCallback onTap, bool active) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: active
                  ? Border.all(color: Colors.white70, width: 1.5)
                  : Border.all(color: Colors.white24),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 8)),
            ])));
  }

  Widget _buildNotifications(Size size) {
    if (_notifications.isEmpty) return const SizedBox.shrink();
    return Positioned(
        top: 80,
        left: 12,
        right: 70,
        child: Column(
            children: _notifications
                .take(3)
                .map((n) => AnimatedOpacity(
                    opacity: n.life.clamp(0.0, 1.0),
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: n.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: n.color.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                              color: n.color.withOpacity(0.2), blurRadius: 8)
                        ],
                      ),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(n.title,
                                  style: TextStyle(
                                      color: n.color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11)),
                              Text(n.body,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ])),
                      ]),
                    )))
                .toList()));
  }

  Widget _buildGrowBoostIndicator() {
    if (!_growBoostActive) return const SizedBox.shrink();
    return Positioned(
        left: 12,
        bottom: 240 + MediaQuery.of(context).padding.bottom,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.yellow.withOpacity(0.7)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text('2x Growth: ${_growBoostSecondsLeft}s',
                style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
        ));
  }

  Widget _buildWeatherInfo(Size size) {
    return Positioned(
        top: 80,
        left: 12,
        right: 80,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${_cfg.emoji} ${_cfg.name}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const Spacer(),
              GestureDetector(
                  onTap: () => setState(() => _showWeatherInfo = false),
                  child:
                      const Icon(Icons.close, color: Colors.white54, size: 18)),
            ]),
            const SizedBox(height: 6),
            Text(_cfg.description,
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
            const SizedBox(height: 8),
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Text('🌡️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_cfg.weatherNote,
                          style: const TextStyle(
                              color: Color(0xB3FFFFFF), fontSize: 12))),
                ])),
            const SizedBox(height: 8),
            if (_cfg.seasonalPlants.isNotEmpty) ...[
              Text(
                  '🌟 Seasonal Bonus Plants: ${_cfg.seasonalPlants.join(", ")}',
                  style:
                      const TextStyle(color: Colors.greenAccent, fontSize: 11)),
              const SizedBox(height: 6),
            ],
            Wrap(spacing: 6, children: [
              _weatherBadge('Growth', '${(_cfg.growthMult * 100).toInt()}%',
                  _cfg.growthMult >= 1.0 ? Colors.green : Colors.orange),
              _weatherBadge('Wind', _cfg.windStrength > 0.5 ? 'Strong' : 'Calm',
                  _cfg.windStrength > 0.5 ? Colors.blue : Colors.teal),
              _weatherBadge('Bonus', '+${_cfg.bonusCoins}🪙', Colors.amber),
              if (_cfg.hasRain)
                _weatherBadge('Rain', 'Active', Colors.lightBlue),
              if (_cfg.hasSnow) _weatherBadge('Snow', 'Falling', Colors.white),
              if (_cfg.hasFireflies)
                _weatherBadge('Fireflies', 'Active', Colors.yellow),
              if (_cfg.hasButterflies)
                _weatherBadge('Butterflies', 'Flying', Colors.pink),
            ]),
          ]),
        ));
  }

  Widget _weatherBadge(String label, String val, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(children: [
        Text(val,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 11)),
        Text(label,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
      ]),
    );
  }

  Widget _buildSeasonBar(Size size) {
    return Positioned(
        top: 68,
        left: 0,
        right: 0,
        child: SafeArea(
            child: SizedBox(
                height: 44,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: Season.values.map((s) {
                      final cfg = _seasons[s]!;
                      final active = _season == s;
                      final visited = _visitedSeasons.contains(s);
                      return GestureDetector(
                          onTap: () {
                            if (_season == s) return;
                            setState(() {
                              _season = s;
                              _showWeatherInfo = false;
                              _visitedSeasons.add(s);
                            });
                            _audio.stopSound();
                            _startAudio();
                            _checkAchievements();
                          },
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white.withOpacity(0.28)
                                    : Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(18),
                                border: active
                                    ? Border.all(
                                        color: Colors.white70, width: 1.5)
                                    : null,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cfg.emoji,
                                        style: const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 4),
                                    Text(cfg.name,
                                        style: TextStyle(
                                            color: active
                                                ? Colors.white
                                                : Colors.white70,
                                            fontSize: 11,
                                            fontWeight: active
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                                    if (visited && !active) ...[
                                      const SizedBox(width: 3),
                                      const Text('✓',
                                          style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 9)),
                                    ],
                                  ])));
                    }).toList()))));
  }

  Widget _buildBottomBar(Size size) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B4332).withOpacity(0.97),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Resources row
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resBadge('💧', _waterLevel, 100, Colors.blue),
                    _resBadge('🌱', _seeds, 30, Colors.green),
                    _resBadge('🧪', _fertilizer, 15, Colors.orange),
                    GestureDetector(
                        onTap: () => _adService.showRewarded(
                              onRewarded: (_) {
                                setState(() {
                                  _seeds += 5;
                                  _fertilizer += 3;
                                  _waterLevel = 100;
                                  _premiumEnergy += 1;
                                });
                                _showSnack(
                                    '🎁 +5 seeds, +3 fertilizer, water refilled, +1 ⚡!');
                              },
                              onNotAvailable: () =>
                                  _showSnack('No ad available right now.'),
                            ),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.withOpacity(0.5))),
                            child: const Text('📺 Free\nRefill',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)))),
                  ])),
          // Plant type picker — all 12 types
          SizedBox(
              height: 64,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: PlantType.values.map((t) {
                    final data = _plantData[t]!;
                    final sel = _selectedPlantType == t &&
                        _activeTool == GardenTool.plant;
                    final cost = data['cost'] as int;
                    final canAfford = _coins >= cost;
                    return GestureDetector(
                        onTap: () => setState(() {
                              _selectedPlantType = t;
                              _activeTool = GardenTool.plant;
                            }),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.white.withOpacity(0.22)
                                  : Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: sel
                                  ? Border.all(
                                      color: Colors.white60, width: 1.5)
                                  : null,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_plantEmoji(t, 3),
                                      style: const TextStyle(fontSize: 18)),
                                  if (sel)
                                    Text(data['name'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700)),
                                  Text('$cost🪙',
                                      style: TextStyle(
                                          color: canAfford
                                              ? Colors.greenAccent
                                              : Colors.red,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600)),
                                ])));
                  }).toList())),
          // Tools — use spaceEvenly so 6 buttons fit on any screen width
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _toolBtn(GardenTool.plant, '🌱', 'Plant'),
                    _toolBtn(GardenTool.water, '💧', 'Water'),
                    _toolBtn(GardenTool.fertilize, '🧪', 'Feed'),
                    _toolBtn(GardenTool.harvest, '🌾', 'Harvest'),
                    _toolBtn(GardenTool.remove, '✂️', 'Remove'),
                    _toolBtn(GardenTool.inspect, '🔍', 'Inspect'),
                  ])),
        ]),
      ),
    );
  }

  Widget _resBadge(String icon, int val, int max, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('$icon $val',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      SizedBox(
          width: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                  value: (val / max).clamp(0, 1),
                  backgroundColor: Colors.white24,
                  color: color,
                  minHeight: 4))),
    ]);
  }

  Widget _toolBtn(GardenTool tool, String icon, String label) {
    final active = _activeTool == tool;
    return GestureDetector(
        onTap: () => setState(() => _activeTool = tool),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color:
                  active ? Colors.white.withOpacity(0.22) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: Colors.white54) : null,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 9,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.normal)),
            ])));
  }

  Widget _buildO2Meter() {
    return Positioned(
        left: 12,
        bottom: 188 + MediaQuery.of(context).padding.bottom,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🌍 O₂',
                style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700)),
            Text('${_totalO2.toStringAsFixed(1)}L',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            Text(
                '${_grid.expand((r) => r).where((t) => t.isPlanted).length} plants',
                style: const TextStyle(color: Colors.white54, fontSize: 9)),
          ]),
        ));
  }

  Widget _buildTilePanel(GardenTile t) {
    final data = _plantData[t.plantType]!;
    final seasonEffect = _getSeasonEffect(t);
    final isSeasonalBonus =
        _cfg.seasonalPlants.contains(t.plantType?.name ?? '');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: t.isRare
                ? Colors.purple.withOpacity(0.7)
                : Colors.green.withOpacity(0.5),
            width: t.isRare ? 2 : 1),
        boxShadow: t.isRare
            ? [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 12)]
            : [],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Stack(children: [
            Text(_plantEmoji(t.plantType!, t.growthStage),
                style: const TextStyle(fontSize: 32)),
            if (t.isRare)
              const Positioned(
                  right: 0,
                  top: 0,
                  child: Text('✨', style: TextStyle(fontSize: 12))),
          ]),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text((data['name'] as String).toUpperCase(),
                      style: TextStyle(
                          color: t.isRare ? Colors.purple : Colors.greenAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                  if (t.isRare)
                    const Text(' ✨ RARE',
                        style: TextStyle(color: Colors.purple, fontSize: 10)),
                ]),
                Text('Stage ${t.growthStage}/5  •  (${t.col},${t.row})',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11)),
                if (isSeasonalBonus)
                  const Text('🌟 Seasonal Bonus Active!',
                      style:
                          TextStyle(color: Colors.greenAccent, fontSize: 10)),
                if (seasonEffect.isNotEmpty)
                  Text(seasonEffect,
                      style: const TextStyle(
                          color: Color(0xFFFFCC02), fontSize: 10)),
              ])),
          GestureDetector(
              onTap: () => setState(() {
                    _selectedTile = null;
                    _showInspectPanel = false;
                  }),
              child: const Icon(Icons.close, color: Colors.white54, size: 18)),
        ]),
        const SizedBox(height: 10),
        _statBar('💧', t.water, Colors.blue),
        const SizedBox(height: 4),
        _statBar('❤️', t.health, Colors.red),
        const SizedBox(height: 4),
        _statBar('🧪', t.fertility, Colors.orange),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _miniStat(
              'O₂/hr',
              '${(t.o2Output * t.growthStage).toStringAsFixed(1)}L',
              const Color(0xFF00E5FF)),
          _miniStat('XP', '${t.xpValue * t.growthStage}', Colors.amber),
          _miniStat('Care', '${t.careCount}x', Colors.greenAccent),
          _miniStat('Stage', '${t.growthStage}/5', Colors.white),
        ]),
        const SizedBox(height: 8),
        // Care tip
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Text('💡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(data['tip'] as String,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 10))),
            ])),
        // Quick action buttons
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _quickActionBtn('💧 Water', Colors.blue, () {
            final size = MediaQuery.of(context).size;
            final center = _iso(t.col + 0.5, t.row + 0.5, size);
            _doWater(t, center, size);
          })),
          const SizedBox(width: 8),
          Expanded(
              child: _quickActionBtn('🧪 Feed', Colors.orange, () {
            final size = MediaQuery.of(context).size;
            final center = _iso(t.col + 0.5, t.row + 0.5, size);
            _doFertilize(t, center, size);
          })),
          if (t.growthStage >= 4) ...[
            const SizedBox(width: 8),
            Expanded(
                child: _quickActionBtn('🌾 Harvest', Colors.amber, () {
              final size = MediaQuery.of(context).size;
              final center = _iso(t.col + 0.5, t.row + 0.5, size);
              _doHarvest(t, center, size);
            })),
          ],
        ]),
      ]),
    );
  }

  Widget _quickActionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _getSeasonEffect(GardenTile t) {
    if (_cfg.hasRain) return '🌧️ Rain auto-watering +60% growth';
    if (_season == Season.summer) return '☀️ Hot — water frequently!';
    if (_season == Season.winter) {
      final isHardy =
          t.plantType == PlantType.mushroom || t.plantType == PlantType.cactus;
      return isHardy
          ? '❄️ Hardy plant — survives frost'
          : '❄️ Frost risk — health declining';
    }
    if (_season == Season.snowfall) return '🌨️ Snow cover — barely growing';
    if (_season == Season.autumn) return '🍂 Harvest soon before winter!';
    return '';
  }

  Widget _statBar(String icon, double val, Color color) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 6),
      Expanded(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: val.clamp(0, 1),
                  backgroundColor: Colors.white12,
                  color: color,
                  minHeight: 6))),
      const SizedBox(width: 6),
      Text('${(val * 100).toInt()}%',
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _miniStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 14)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ]);
  }

  String _plantEmoji(PlantType t, int stage) {
    final data = _plantData[t];
    if (data == null) return '🌱';
    final emojis = data['emoji'] as List<String>;
    return emojis[stage.clamp(0, 5)];
  }

  // ─── SHOP PANEL ──────────────────────────────────────────────────────────
  Widget _buildShopPanel(Size size) {
    return _buildOverlayPanel(
      title: '🛒 Garden Shop',
      onClose: () => setState(() => _showShop = false),
      child: Column(children: [
        Row(children: [
          _hudChip('🪙', '$_coins'),
          const SizedBox(width: 8),
          _hudChip('⚡', '$_premiumEnergy'),
        ]),
        const SizedBox(height: 12),
        ..._shopItems.map((item) => _buildShopItemRow(item)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _adService.showRewarded(
            onRewarded: (_) {
              setState(() {
                _premiumEnergy += 2;
              });
              _showSnack('⚡ +2 Premium Energy earned!');
            },
            onNotAvailable: () => _showSnack('No ad available.'),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📺', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Watch Ad → +2 ⚡ Premium Energy',
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildShopItemRow(ShopItem item) {
    final canAfford = item.currency == 'coins'
        ? _coins >= item.cost
        : _premiumEnergy >= item.cost;
    return GestureDetector(
      onTap: canAfford ? () => _buyShopItem(item) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canAfford
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: canAfford ? Colors.white24 : Colors.white12),
        ),
        child: Row(children: [
          Text(item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.name,
                    style: TextStyle(
                        color: canAfford ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(item.description,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: canAfford
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: canAfford
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.3)),
            ),
            child: Text('${item.cost} ${item.currency == "coins" ? "🪙" : "⚡"}',
                style: TextStyle(
                    color: canAfford ? Colors.greenAccent : Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ]),
      ),
    );
  }

  // ─── ACHIEVEMENTS PANEL ──────────────────────────────────────────────────
  Widget _buildAchievementsPanel(Size size) {
    final unlocked = _achievements.where((a) => a.unlocked).length;
    return _buildOverlayPanel(
      title: '🏆 Achievements ($unlocked/${_achievements.length})',
      onClose: () => setState(() => _showAchievements = false),
      child: Column(
          children: _achievements
              .map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: a.unlocked
                          ? Colors.amber.withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: a.unlocked
                              ? Colors.amber.withOpacity(0.5)
                              : Colors.white12),
                    ),
                    child: Row(children: [
                      Text(a.emoji,
                          style: TextStyle(
                              fontSize: 24,
                              color:
                                  a.unlocked ? null : const Color(0x44FFFFFF))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(a.title,
                                style: TextStyle(
                                    color: a.unlocked
                                        ? Colors.amber
                                        : Colors.white38,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            Text(a.description,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                            if (a.unlocked && a.unlockedAt != null)
                              Text('Unlocked ${_formatDate(a.unlockedAt!)}',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 9)),
                          ])),
                      Text('+${a.reward}🪙',
                          style: TextStyle(
                              color: a.unlocked ? Colors.amber : Colors.white24,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ]),
                  ))
              .toList()),
    );
  }

  // ─── QUESTS PANEL ────────────────────────────────────────────────────────
  Widget _buildQuestsPanel(Size size) {
    return _buildOverlayPanel(
      title: '🎯 Daily Quests',
      onClose: () => setState(() => _showQuests = false),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Text(
              'Complete quests to earn bonus coins! Resets daily.',
              style: TextStyle(color: Colors.lightBlue, fontSize: 11),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 10),
        ..._dailyQuests.map((q) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: q.completed
                    ? Colors.green.withOpacity(0.12)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: q.completed
                        ? Colors.green.withOpacity(0.5)
                        : Colors.white12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(q.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(q.title,
                              style: TextStyle(
                                  color: q.completed
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13))),
                      if (q.completed)
                        const Text('✅', style: TextStyle(fontSize: 16))
                      else
                        Text('+${q.reward}🪙',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(q.description,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: q.fraction,
                                backgroundColor: Colors.white12,
                                color:
                                    q.completed ? Colors.green : Colors.amber,
                                minHeight: 6,
                              ))),
                      const SizedBox(width: 8),
                      Text('${q.progress}/${q.target}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10)),
                    ]),
                  ]),
            )),
      ]),
    );
  }

  // ─── STATS PANEL ─────────────────────────────────────────────────────────
  Widget _buildStatsPanel(Size size) {
    final plantCount = _grid.expand((r) => r).where((t) => t.isPlanted).length;
    final maturePlants = _grid
        .expand((r) => r)
        .where((t) => t.isPlanted && t.growthStage >= 4)
        .length;
    final rarePlants =
        _grid.expand((r) => r).where((t) => t.isPlanted && t.isRare).length;
    return _buildOverlayPanel(
      title: '📊 Garden Stats',
      onClose: () => setState(() => _showStats = false),
      child: Column(children: [
        _statRow('🌱', 'Plants Growing', '$plantCount'),
        _statRow('🌟', 'Ready to Harvest', '$maturePlants'),
        _statRow('✨', 'Rare Plants', '$rarePlants'),
        _statRow('🌸', 'Beauty Score', '$_beautyScore'),
        _statRow('⭐', 'Garden Level', '$_gardenLevel'),
        _statRow('🪙', 'Total Coins', '$_coins'),
        _statRow('🌍', 'O₂ Produced', '${_totalO2.toStringAsFixed(1)}L'),
        _statRow('🌾', 'Total Harvests', '$_totalHarvests'),
        _statRow('🌱', 'Total Planted', '$_totalPlanted'),
        _statRow('💧', 'Total Watered', '$_totalWatered'),
        _statRow('🌍', 'Seasons Visited', '${_visitedSeasons.length}/6'),
        const SizedBox(height: 8),
        // XP progress
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Level $_gardenLevel',
                    style: const TextStyle(
                        color: Colors.yellow, fontWeight: FontWeight.w700)),
                Text('$_xp / $_xpToNext XP',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: (_xp / _xpToNext).clamp(0.0, 1.0),
                      backgroundColor: Colors.white12,
                      color: Colors.yellow,
                      minHeight: 8)),
            ])),
      ]),
    );
  }

  Widget _statRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ]),
    );
  }

  // ─── OVERLAY PANEL TEMPLATE ──────────────────────────────────────────────
  Widget _buildOverlayPanel(
      {required String title,
      required VoidCallback onClose,
      required Widget child}) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent close on panel tap
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2818),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                child: Column(children: [
                  // Header
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(children: [
                        Expanded(
                            child: Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16))),
                        GestureDetector(
                            onTap: onClose,
                            child: const Icon(Icons.close,
                                color: Colors.white54, size: 22)),
                      ])),
                  const Divider(color: Colors.white12),
                  // Content
                  Expanded(
                      child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  )),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildCameraControls() {
    // Compass direction label based on rotation
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final dirIdx = ((_rotation + 22.5) % 360 / 45).floor();
    final dirLabel = dirs[dirIdx % 8];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom
          Row(mainAxisSize: MainAxisSize.min, children: [
            _camBtn(Icons.remove,
                () => setState(() => _zoom = (_zoom - 0.25).clamp(0.4, 3.0))),
            const SizedBox(width: 4),
            Text('${(_zoom * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 9)),
            const SizedBox(width: 4),
            _camBtn(Icons.add,
                () => setState(() => _zoom = (_zoom + 0.25).clamp(0.4, 3.0))),
          ]),
          const SizedBox(height: 6),
          // Y-axis rotation — 45° steps for clean isometric views
          Row(mainAxisSize: MainAxisSize.min, children: [
            _camBtn(Icons.rotate_left,
                () => setState(() => _rotation = (_rotation - 45) % 360)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _rotation = 0),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
                child: Center(
                  child: Text(dirLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _camBtn(Icons.rotate_right,
                () => setState(() => _rotation = (_rotation + 45) % 360)),
          ]),
          const SizedBox(height: 6),
          // Reset + grid toggle
          Row(mainAxisSize: MainAxisSize.min, children: [
            _camBtn(
                Icons.center_focus_strong,
                () => setState(() {
                      _camX = 0;
                      _camY = 0;
                      _zoom = 1.0;
                      _rotation = 0.0;
                    })),
            const SizedBox(width: 4),
            _camBtn(_showGrid ? Icons.grid_off : Icons.grid_on,
                () => setState(() => _showGrid = !_showGrid)),
          ]),
        ],
      ),
    );
  }

  Widget _camBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─── NOTIFICATION MODEL ───────────────────────────────────────────────────────
class _Notification {
  final String title, body;
  final Color color;
  double life = 1.0;
  _Notification({required this.title, required this.body, required this.color});
}

// ─── PAINTERS ────────────────────────────────────────────────────────────────

class _GardenPainter extends CustomPainter {
  final List<List<GardenTile>> grid;
  final int cols, rows;
  final SeasonConfig cfg;
  final Season season;
  final double camX, camY, glowValue, envValue;
  final double zoom, rotation;
  final GardenTile? selectedTile;
  final List<Meditator> meditators;
  final List<Butterfly> butterflies;
  final List<Bee> bees;
  final Size screenSize;
  final bool showGrid;

  static const double tW = 72.0, tH = 36.0;

  _GardenPainter({
    required this.grid,
    required this.cols,
    required this.rows,
    required this.cfg,
    required this.season,
    required this.camX,
    required this.camY,
    required this.glowValue,
    required this.envValue,
    required this.selectedTile,
    required this.meditators,
    required this.screenSize,
    required this.zoom,
    required this.rotation,
    required this.butterflies,
    required this.bees,
    this.showGrid = true,
  });

  Offset _iso(double c, double r) {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height * 0.42;

    // Y-axis rotation: orbit camera around garden centre (horizontal plane only)
    final gc = cols / 2.0;
    final gr = rows / 2.0;
    final dc = c - gc;
    final dr = r - gr;

    final angle = rotation * pi / 180;
    final cosA = cos(angle);
    final sinA = sin(angle);
    final rc = dc * cosA - dr * sinA;
    final rr = dc * sinA + dr * cosA;

    // Standard isometric projection
    final wx = (rc - rr) * tW / 2;
    final wy = (rc + rr) * tH / 2;

    return Offset(
      centerX + wx * zoom + camX,
      centerY + wy * zoom + camY,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _drawTile(canvas, grid[r][c], c.toDouble(), r.toDouble());
      }
    }
    // Creatures
    if (cfg.hasButterflies) {
      for (final b in butterflies) {
        _drawCreature(canvas, b.x * screenSize.width, b.y * screenSize.height,
            b.emoji, 14);
      }
    }
    if (cfg.hasBees) {
      for (final b in bees) {
        _drawCreature(
            canvas, b.x * screenSize.width, b.y * screenSize.height, '🐝', 12);
      }
    }
    // Meditators on top
    for (final m in meditators) {
      _drawMeditator(canvas, m);
    }
  }

  void _drawCreature(
      Canvas canvas, double x, double y, String emoji, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawTile(Canvas canvas, GardenTile t, double c, double r) {
    final tl = _iso(c, r);
    final tr = _iso(c + 1, r);
    final br = _iso(c + 1, r + 1);
    final bl = _iso(c, r + 1);
    final center = _iso(c + 0.5, r + 0.5);

    Color topColor;
    switch (t.tileType) {
      case TileType.path:
        topColor = cfg.pathColor;
        break;
      case TileType.pond:
        topColor = cfg.pondColor;
        break;
      case TileType.fence:
        topColor = const Color(0xFF8D6E63);
        break;
      case TileType.soil:
        if (season == Season.snowfall || season == Season.winter) {
          topColor = Color.lerp(cfg.groundLight, cfg.groundSnow, 0.7)!;
        } else if (cfg.hasRain) {
          topColor = Color.lerp(cfg.groundLight, cfg.groundWet, 0.6)!;
        } else if (t.water < 0.3) {
          topColor = Color.lerp(cfg.groundLight, const Color(0xFFBCAAA4), 0.4)!;
        } else {
          topColor = cfg.groundLight;
        }
        if (t.isPlanted) {
          topColor = Color.lerp(topColor, const Color(0xFF4E342E), 0.25)!;
        }
        break;
    }

    final topPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();

    canvas.drawPath(topPath, Paint()..color = topColor);

    if (t.tileType == TileType.pond) {
      canvas.drawOval(
          Rect.fromCenter(center: center, width: tW * 0.5, height: tH * 0.3),
          Paint()..color = Colors.white.withOpacity(0.15 + glowValue * 0.1));
      _drawEmoji(canvas, center, '🌊', 14);
    }

    if (t.tileType == TileType.fence) {
      _drawEmoji(canvas, center.translate(0, -tH * 0.5), '🪵', 12);
    }

    if (showGrid) {
      canvas.drawPath(
          topPath,
          Paint()
            ..color = cfg.groundDark.withOpacity(0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7);
    }

    // Depth faces
    final leftPath = Path()
      ..moveTo(bl.dx, bl.dy)
      ..lineTo(bl.dx, bl.dy + tH * 0.55)
      ..lineTo(br.dx, br.dy + tH * 0.55)
      ..lineTo(br.dx, br.dy)
      ..close();
    canvas.drawPath(
        leftPath, Paint()..color = cfg.groundDark.withOpacity(0.55));

    final rightPath = Path()
      ..moveTo(br.dx, br.dy)
      ..lineTo(br.dx, br.dy + tH * 0.55)
      ..lineTo(tr.dx, tr.dy + tH * 0.55)
      ..lineTo(tr.dx, tr.dy)
      ..close();
    canvas.drawPath(
        rightPath, Paint()..color = cfg.groundDark.withOpacity(0.38));

    // Selection highlight
    if (selectedTile == t) {
      canvas.drawPath(
          topPath,
          Paint()
            ..color = Colors.yellow.withOpacity(0.28 + glowValue * 0.18)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          topPath,
          Paint()
            ..color = Colors.yellow.withOpacity(0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }

    if (t.isPlanted && t.tileType == TileType.soil) {
      canvas.drawOval(
          Rect.fromCenter(center: center, width: tW * 0.55, height: tH * 0.32),
          Paint()..color = const Color(0xFF3E2723).withOpacity(0.45));
    }

    if ((season == Season.snowfall || season == Season.winter) &&
        t.tileType == TileType.soil) {
      canvas.drawPath(topPath, Paint()..color = Colors.white.withOpacity(0.35));
    }

    if (t.isPlanted && t.plantType != null && t.tileType == TileType.soil) {
      _drawPlant(canvas, t, center);
    }
  }

  void _drawEmoji(Canvas canvas, Offset pos, String emoji, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawPlant(Canvas canvas, GardenTile t, Offset center) {
    final stage = t.growthStage;
    final depthScale = 0.75 + (center.dy / screenSize.height) * 0.5;
    final fs = (14.0 + stage * 7.0) * depthScale;

    // Rare glow
    if (t.isRare) {
      canvas.drawCircle(
          center.translate(0, -fs * 0.4),
          fs * 0.8,
          Paint()
            ..color = Colors.purple.withOpacity(0.2 * glowValue)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
    }

    // Growth glow
    if (t.isGlowing) {
      canvas.drawCircle(
          center.translate(0, -fs * 0.4),
          fs * 0.65,
          Paint()
            ..color = Colors.greenAccent.withOpacity(0.28 * glowValue)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    }

    // Shadow
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(1, 3),
            width: fs * 0.75,
            height: fs * 0.22),
        Paint()..color = Colors.black.withOpacity(0.22));

    // Plant emoji
    final emoji = _emojiFor(t.plantType!, stage);
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: fs)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height * 0.88));

    // Rare sparkle
    if (t.isRare) {
      final sp = TextPainter(
          text: const TextSpan(text: '✨', style: TextStyle(fontSize: 10)),
          textDirection: TextDirection.ltr)
        ..layout();
      sp.paint(canvas, Offset(center.dx + fs * 0.3, center.dy - fs * 1.0));
    }

    // Health bar
    if (t.health < 0.75) {
      final bw = tW * 0.48;
      final bx = center.dx - bw / 2;
      final by = center.dy - fs - 6;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(bx, by, bw, 4), const Radius.circular(2)),
          Paint()..color = Colors.black38);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw * t.health, 4),
              const Radius.circular(2)),
          Paint()..color = Color.lerp(Colors.red, Colors.green, t.health)!);
    }

    // Thirsty indicator
    if (t.water < 0.25) {
      _drawEmoji(canvas, Offset(center.dx + fs * 0.35, center.dy - fs * 0.9),
          '🥵', 10);
    }

    // Snow on plant
    if (season == Season.snowfall || season == Season.winter) {
      canvas.drawCircle(center.translate(0, -fs * 0.7), fs * 0.2,
          Paint()..color = Colors.white.withOpacity(0.5));
    }

    // Stage 5 harvest ready indicator
    if (stage >= 5) {
      canvas.drawCircle(
          center.translate(0, -fs - 8),
          5,
          Paint()
            ..color = Colors.amber.withOpacity(0.8 + glowValue * 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  void _drawMeditator(Canvas canvas, Meditator m) {
    final center = _iso(m.col, m.row);
    final breathScale = 1.0 + sin(m.breathPhase) * 0.06;

    final auraColor = switch (season) {
      Season.spring => Colors.pink,
      Season.summer => Colors.orange,
      Season.monsoon => Colors.blue,
      Season.autumn => Colors.deepOrange,
      Season.winter || Season.snowfall => Colors.lightBlue,
    };
    canvas.drawCircle(
        center.translate(0, -12),
        22 * breathScale + glowValue * 4,
        Paint()
          ..color = auraColor.withOpacity(0.12 * glowValue)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));

    canvas.drawOval(
        Rect.fromCenter(center: center.translate(0, 2), width: 22, height: 7),
        Paint()..color = Colors.black.withOpacity(0.2));

    final tp = TextPainter(
      text:
          TextSpan(text: m.emoji, style: TextStyle(fontSize: 22 * breathScale)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height));

    // Speech bubble — dynamic width based on text
    if (m.speechBubble != null && m.speechLife > 0) {
      final alpha = m.speechLife.clamp(0.0, 1.0);
      final st = TextPainter(
        text: TextSpan(
            text: m.speechBubble,
            style: TextStyle(
                fontSize: 10,
                color: Colors.black.withOpacity(alpha),
                fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      final bubbleW = st.width + 16;
      final bubbleH = 22.0;
      final bubbleCy = center.dy - tp.height - 18;
      final bubbleRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(center.dx, bubbleCy),
              width: bubbleW,
              height: bubbleH),
          const Radius.circular(8));
      canvas.drawRRect(
          bubbleRect, Paint()..color = Colors.white.withOpacity(alpha * 0.95));
      // Tail triangle
      final tailPath = Path()
        ..moveTo(center.dx - 5, bubbleCy + bubbleH / 2)
        ..lineTo(center.dx + 5, bubbleCy + bubbleH / 2)
        ..lineTo(center.dx, bubbleCy + bubbleH / 2 + 6)
        ..close();
      canvas.drawPath(
          tailPath, Paint()..color = Colors.white.withOpacity(alpha * 0.95));
      st.paint(
          canvas, Offset(center.dx - st.width / 2, bubbleCy - st.height / 2));
    }

    // Weather reactions
    if (season == Season.monsoon) {
      _drawEmoji(
          canvas, Offset(center.dx, center.dy - tp.height - 14), '☂️', 14);
    }
    if (season == Season.winter || season == Season.snowfall) {
      _drawEmoji(
          canvas, Offset(center.dx + 8, center.dy - tp.height + 4), '🧣', 10);
    }
    if (season == Season.summer) {
      _drawEmoji(
          canvas, Offset(center.dx + 8, center.dy - tp.height + 4), '😎', 10);
    }
  }

  String _emojiFor(PlantType t, int stage) {
    final data = _plantData[t];
    if (data == null) return '🌱';
    final emojis = data['emoji'] as List<String>;
    return emojis[stage.clamp(0, 5)];
  }

  @override
  bool shouldRepaint(_GardenPainter old) =>
      old.camX != camX ||
      old.camY != camY ||
      old.zoom != zoom ||
      old.rotation != rotation ||
      old.glowValue != glowValue ||
      old.envValue != envValue ||
      old.season != season ||
      old.selectedTile != selectedTile;
}

class _RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final Size ss;
  _RainPainter(this.drops, this.ss);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (final d in drops) {
      paint.color = const Color(0xFF90CAF9).withOpacity(d.opacity);
      paint.strokeWidth = 1.0 + d.opacity * 0.5;
      final x = d.x * ss.width;
      final y = d.y * ss.height;
      final len = d.length * ss.height;
      canvas.drawLine(
          Offset(x, y), Offset(x + d.windX * ss.width * 8, y + len), paint);
    }
  }

  @override
  bool shouldRepaint(_RainPainter o) => true;
}

class _SnowPainter extends CustomPainter {
  final List<SnowFlake> flakes;
  final Size ss;
  _SnowPainter(this.flakes, this.ss);
  @override
  void paint(Canvas canvas, Size size) {
    for (final f in flakes) {
      final cx = f.x * ss.width;
      final cy = f.y * ss.height;
      final r = f.size / 2;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(f.rotation);
      // Draw snowflake as cross
      final p = Paint()
        ..color = Colors.white.withOpacity(0.82)
        ..strokeWidth = r * 0.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-r, 0), Offset(r, 0), p);
      canvas.drawLine(Offset(0, -r), Offset(0, r), p);
      canvas.drawLine(Offset(-r * 0.7, -r * 0.7), Offset(r * 0.7, r * 0.7), p);
      canvas.drawLine(Offset(r * 0.7, -r * 0.7), Offset(-r * 0.7, r * 0.7), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SnowPainter o) => true;
}

class _LeafPainter extends CustomPainter {
  final List<Particle> leaves;
  final Size ss;
  _LeafPainter(this.leaves, this.ss);
  @override
  void paint(Canvas canvas, Size size) {
    for (final l in leaves) {
      canvas.save();
      canvas.translate(l.x * ss.width, l.y * ss.height);
      canvas.rotate(l.rotation);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: l.size, height: l.size * 0.55),
          Paint()..color = l.color.withOpacity(l.life.clamp(0, 1)));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeafPainter o) => true;
}

class _FireflyPainter extends CustomPainter {
  final List<Particle> flies;
  final Size ss;
  final double glow;
  _FireflyPainter(this.flies, this.ss, this.glow);
  @override
  void paint(Canvas canvas, Size size) {
    for (final f in flies) {
      final cx = f.x * ss.width;
      final cy = f.y * ss.height;
      final opacity = (sin(f.life * 4) * 0.5 + 0.5) * f.life.clamp(0, 1);
      canvas.drawCircle(
          Offset(cx, cy),
          f.size * 1.5,
          Paint()
            ..color = Colors.yellow.withOpacity(opacity * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(Offset(cx, cy), f.size * 0.5,
          Paint()..color = Colors.yellowAccent.withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(_FireflyPainter o) => true;
}

class _BurstPainter extends CustomPainter {
  final List<Particle> particles;
  final Size ss;
  _BurstPainter(this.particles, this.ss);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(Offset(p.x * ss.width, p.y * ss.height), p.size / 2,
          Paint()..color = p.color.withOpacity(p.life.clamp(0, 1)));
    }
  }

  @override
  bool shouldRepaint(_BurstPainter o) => true;
}

class _LabelPainter extends CustomPainter {
  final List<FloatingLabel> labels;
  final Size ss;
  _LabelPainter(this.labels, this.ss);
  @override
  void paint(Canvas canvas, Size size) {
    for (final l in labels) {
      final tp = TextPainter(
        text: TextSpan(
            text: l.text,
            style: TextStyle(
              color: l.color.withOpacity(l.life.clamp(0, 1)),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(l.x * ss.width - tp.width / 2, l.y * ss.height));
    }
  }

  @override
  bool shouldRepaint(_LabelPainter o) => true;
}
