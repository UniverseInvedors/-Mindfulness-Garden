// lib/core/services/asset_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AssetService {
  static final AssetService _instance = AssetService._internal();
  factory AssetService() => _instance;

  AssetService._internal();

  // Asset categories and their fallback URLs (open-source assets)
  static final Map<String, Map<String, String>> _assetCategories = {
    'sounds/nature': {
      'forest':
          'https://assets.mixkit.co/sfx/preview/mixkit-forest-ambience-943.mp3',
      'ocean':
          'https://assets.mixkit.co/sfx/preview/mixkit-ocean-waves-loop-1240.mp3',
      'rain': 'https://assets.mixkit.co/sfx/preview/mixkit-rain-loop-1242.mp3',
      'birds':
          'https://assets.mixkit.co/sfx/preview/mixkit-birds-chirping-2469.mp3',
      'waterfall':
          'https://assets.mixkit.co/sfx/preview/mixkit-waterfall-nature-loop-1241.mp3',
      'wind':
          'https://assets.mixkit.co/sfx/preview/mixkit-wind-in-the-trees-2492.mp3',
      'crickets':
          'https://assets.mixkit.co/sfx/preview/mixkit-crickets-chirping-at-night-2491.mp3',
      'fire':
          'https://assets.mixkit.co/sfx/preview/mixkit-burning-fire-loop-1249.mp3',
    },
    'sounds/meditation': {
      'bowl':
          'https://assets.mixkit.co/sfx/preview/mixkit-singing-bowl-2595.mp3',
      'chime':
          'https://assets.mixkit.co/sfx/preview/mixkit-wind-chimes-2995.mp3',
      'gong':
          'https://assets.mixkit.co/sfx/preview/mixkit-gong-showbiz-announcement-483.mp3',
      'bell':
          'https://assets.mixkit.co/sfx/preview/mixkit-tibetan-bell-2326.mp3',
      'om':
          'https://assets.mixkit.co/sfx/preview/mixkit-meditation-sound-with-om-chant-3010.mp3',
    },
    'sounds/breathing': {
      'inhale':
          'https://cdn.pixabay.com/download/audio/2022/11/15/audio_8c1ee13671.mp3',
      'exhale':
          'https://cdn.pixabay.com/download/audio/2022/11/15/audio_9805c0a764.mp3',
      'hold':
          'https://cdn.pixabay.com/download/audio/2022/11/15/audio_3731eec314.mp3',
    },
    'images/garden': {
      'plant_1':
          'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393112_640.png',
      'plant_2':
          'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393113_640.png',
      'plant_3':
          'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393114_640.png',
      'tree_1':
          'https://cdn.pixabay.com/photo/2017/06/11/18/58/tree-2393117_640.png',
      'flower_1':
          'https://cdn.pixabay.com/photo/2017/06/11/18/56/flower-2393109_640.png',
      'garden_bg':
          'https://cdn.pixabay.com/photo/2016/11/29/05/45/astronomy-1867616_640.jpg',
    },
    'images/icons': {
      'meditation':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/meditation-2028156_640.png',
      'breathing':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/leaf-2028158_640.png',
      'garden':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/plant-2028157_640.png',
      'sleep':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/moon-2028159_640.png',
      'music':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/music-2028160_640.png',
      'stats':
          'https://cdn.pixabay.com/photo/2017/01/31/23/42/statistics-2028161_640.png',
    },
    'animations': {
      'mindfulness_logo':
          'https://assets9.lottiefiles.com/packages/lf20_xtwyvqnx.json',
      'loading': 'https://assets9.lottiefiles.com/packages/lf20_raiw2hpe.json',
      'success': 'https://assets9.lottiefiles.com/packages/lf20_ykzpojzk.json',
      'breathing':
          'https://assets9.lottiefiles.com/packages/lf20_bkdxl0dr.json',
      'meditation':
          'https://assets9.lottiefiles.com/packages/lf20_wnk7vlwb.json',
    },
  };

  // Cache for local asset paths
  final Map<String, String> _assetCache = {};

  // Check if asset exists locally
  Future<bool> assetExists(String assetPath) async {
    try {
      // First check cache
      if (_assetCache.containsKey(assetPath)) {
        return true;
      }

      // Try to load the asset
      await rootBundle.load(assetPath);
      _assetCache[assetPath] = assetPath;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get asset with fallback
  Future<String> getAsset(String assetPath) async {
    // If asset exists locally, return it
    if (await assetExists(assetPath)) {
      return assetPath;
    }

    // Otherwise, download or return fallback
    return await _getFallbackAsset(assetPath);
  }

  // Get fallback asset from URL
  Future<String> _getFallbackAsset(String assetPath) async {
    try {
      // Extract category and filename from path
      final parts = assetPath.split('/');
      if (parts.length < 2) return assetPath;

      final category = parts.sublist(0, parts.length - 1).join('/');
      final filename = parts.last.split('.').first;

      // Check if we have a fallback URL for this asset
      if (_assetCategories.containsKey(category) &&
          _assetCategories[category]!.containsKey(filename)) {
        final url = _assetCategories[category]![filename]!;
        final localPath = await _downloadAsset(url, assetPath);

        if (localPath != null) {
          _assetCache[assetPath] = localPath;
          return localPath;
        }
      }

      // Return default fallback based on category
      return _getDefaultFallback(category, filename);
    } catch (e) {
      print('⚠️ Error getting fallback asset: $e');
      return assetPath; // Return original path as fallback
    }
  }

  // Download asset from URL
  Future<String?> _downloadAsset(String url, String originalPath) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(originalPath);
        final filePath = p.join(appDir.path, 'downloaded_assets', fileName);

        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      }
    } catch (e) {
      print('⚠️ Error downloading asset: $e');
    }
    return null;
  }

  // Get default fallback asset
  String _getDefaultFallback(String category, String filename) {
    // Return built-in fallback assets
    switch (category) {
      case 'sounds/nature':
        return 'assets/fallback_sounds/nature.mp3';
      case 'sounds/meditation':
        return 'assets/fallback_sounds/meditation.mp3';
      case 'sounds/breathing':
        return 'assets/fallback_sounds/breathing.mp3';
      case 'images/garden':
        return 'assets/fallback_images/plant.png';
      case 'images/icons':
        return 'assets/fallback_images/icon.png';
      case 'animations':
        return 'assets/fallback_animations/loading.json';
      default:
        return 'assets/fallback_images/default.png';
    }
  }

  // Preload essential assets
  Future<void> preloadAssets() async {
    final essentialAssets = [
      'assets/animations/mindfulness_logo.json',
      'assets/sounds/nature/forest.mp3',
      'assets/sounds/meditation/bowl.mp3',
      'assets/images/icons/meditation.png',
      'assets/images/garden/garden_bg.png',
    ];

    for (final asset in essentialAssets) {
      await getAsset(asset);
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    _assetCache.clear();
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(appDir.path, 'downloaded_assets'));
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}
