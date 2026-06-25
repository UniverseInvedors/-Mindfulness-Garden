import 'package:logger/logger.dart';
import 'package:universe_backend_sdk/universe_backend_sdk.dart';

/// Backend integration service for PranaVerse: Healing Frequencies
/// Handles all backend communication replacing Firebase
class BackendIntegrationService {
  final Logger _logger = Logger();
  UniverseBackendClient? _client;
  GameIntegrationHelper? _gameHelper;
  AuthService? _authService;
  GameService? _gameService;
  
  static const String _gameName = 'PranaVerse: Healing Frequencies';
  static const String _backendUrl = 'https://master-backend-r57r.onrender.com';

  Future<void> initialize() async {
    try {
      final config = UniverseBackendConfig(baseUrl: _backendUrl, enableLogging: true);
      _client = UniverseBackendClient(config: config);
      final authRepository = AuthRepository(_client!);
      _authService = AuthService(authRepository);
      final gameRepository = GameRepository(_client!);
      _gameService = GameService(gameRepository);
      
      final achievementRepository = AchievementRepository(_client!);
      final achievementService = AchievementService(achievementRepository);
      final leaderboardRepository = LeaderboardRepository(_client!);
      final leaderboardService = LeaderboardService(leaderboardRepository);
      
      _gameHelper = GameIntegrationHelper(
        client: _client!,
        gameService: _gameService!,
        achievementService: achievementService,
        leaderboardService: leaderboardService,
      );
      _logger.i('Backend integration service initialized for PranaVerse: Healing Frequencies');
    } catch (e) {
      _logger.e('Failed to initialize backend service', error: e);
      rethrow;
    }
  }

  UniverseBackendClient? get client => _client;
  GameIntegrationHelper? get gameHelper => _gameHelper;
  AuthService? get authService => _authService;

  Future<bool> login(String email, String password) async {
    try {
      if (_authService == null) throw Exception('Backend service not initialized');
      final result = await _authService!.login(email, password);
      // Tokens are automatically saved by the auth repository
      return result.user != null;
    } catch (e) {
      _logger.e('Login failed', error: e);
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName, String lastName) async {
    try {
      if (_authService == null) throw Exception('Backend service not initialized');
      final request = RegisterRequest(
        email: email,
        username: firstName,
        gameId: 'pranaverse',
        password: password,
        passwordConfirm: password,
        firstName: firstName,
        lastName: lastName,
      );
      final result = await _authService!.register(request);
      return result != null;
    } catch (e) {
      _logger.e('Registration failed', error: e);
      return false;
    }
  }

  Future<void> logout() async {
    await _client?.tokenManager.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    final token = await _client?.tokenManager.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<GameIntegrationResult?> initializeGame() async {
    try {
      if (_gameHelper == null) throw Exception('Game helper not initialized');
      return await _gameHelper!.initializeGame(_gameName);
    } catch (e) {
      _logger.e('Failed to initialize game', error: e);
      return null;
    }
  }

  Future<GameSession?> startSession({Map<String, dynamic>? deviceInfo}) async {
    try {
      final games = await _gameService!.listGames();
      final game = games.results.firstWhere((g) => g.name == _gameName, orElse: () => throw Exception('Game not found'));
      return await _gameHelper!.startSession(game.id, deviceInfo: deviceInfo);
    } catch (e) {
      _logger.e('Failed to start session', error: e);
      return null;
    }
  }

  Future<GameSession?> endSession(int sessionId, int score, {Map<String, dynamic>? sessionData}) async {
    try {
      return await _gameHelper!.endSession(sessionId, score: score, sessionData: sessionData);
    } catch (e) {
      _logger.e('Failed to end session', error: e);
      return null;
    }
  }

  Future<GameProgress?> updateProgress({int? level, int? experiencePoints, int? highScore, Map<String, dynamic>? gameStats}) async {
    try {
      final games = await _gameService!.listGames();
      final game = games.results.firstWhere((g) => g.name == _gameName, orElse: () => throw Exception('Game not found'));
      return await _gameHelper!.updateProgress(game.id, level: level, experiencePoints: experiencePoints, highScore: highScore, gameStats: gameStats);
    } catch (e) {
      _logger.e('Failed to update progress', error: e);
      return null;
    }
  }

  // Data tracking methods for mindfulness progress
  Future<bool> trackMeditationSession({
    required int durationMinutes,
    required String moodBefore,
    required String moodAfter,
    String? notes,
  }) async {
    try {
      final sessionData = <String, dynamic>{
        'duration_minutes': durationMinutes,
        'mood_before': moodBefore,
        'mood_after': moodAfter,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final session = await startSession(deviceInfo: sessionData);
      if (session == null) return false;
      
      // Calculate score based on duration
      final score = durationMinutes * 10;
      await endSession(session.id, score, sessionData: sessionData);
      
      // Update progress stats
      await updateProgress(gameStats: {
        'total_sessions': (await getTotalSessions()) + 1,
        'total_minutes': (await getTotalMinutes()) + durationMinutes,
        'last_session': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      _logger.e('Failed to track meditation session', error: e);
      return false;
    }
  }

  Future<bool> trackGardenProgress({
    required int plantsGrown,
    required String plantType,
  }) async {
    try {
      await updateProgress(gameStats: {
        'plants_grown': (await getPlantsGrown()) + plantsGrown,
        'last_plant': plantType,
        'last_plant_timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _logger.e('Failed to track garden progress', error: e);
      return false;
    }
  }

  Future<bool> trackStreak({required int currentStreak}) async {
    try {
      await updateProgress(gameStats: {
        'current_streak': currentStreak,
        'last_streak_update': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _logger.e('Failed to track streak', error: e);
      return false;
    }
  }

  Future<bool> trackMood({required String mood, String? notes}) async {
    try {
      await updateProgress(gameStats: {
        'last_mood': mood,
        'last_mood_timestamp': DateTime.now().toIso8601String(),
        'mood_notes': notes,
      });
      return true;
    } catch (e) {
      _logger.e('Failed to track mood', error: e);
      return false;
    }
  }

  Future<int> getTotalSessions() async {
    try {
      // TODO: Implement proper progress retrieval when SDK method is available
      _logger.w('getTotalSessions: getProgress method not available in SDK, returning 0');
      return 0;
    } catch (e) {
      _logger.e('Failed to get total sessions', error: e);
      return 0;
    }
  }

  Future<int> getTotalMinutes() async {
    try {
      // TODO: Implement proper progress retrieval when SDK method is available
      _logger.w('getTotalMinutes: getProgress method not available in SDK, returning 0');
      return 0;
    } catch (e) {
      _logger.e('Failed to get total minutes', error: e);
      return 0;
    }
  }

  Future<int> getPlantsGrown() async {
    try {
      // TODO: Implement proper progress retrieval when SDK method is available
      _logger.w('getPlantsGrown: getProgress method not available in SDK, returning 0');
      return 0;
    } catch (e) {
      _logger.e('Failed to get plants grown', error: e);
      return 0;
    }
  }

  Future<int> getCurrentStreak() async {
    try {
      // TODO: Implement proper progress retrieval when SDK method is available
      _logger.w('getCurrentStreak: getProgress method not available in SDK, returning 0');
      return 0;
    } catch (e) {
      _logger.e('Failed to get current streak', error: e);
      return 0;
    }
  }

  Future<Map<String, dynamic>> getAllProgress() async {
    try {
      // TODO: Implement proper progress retrieval when SDK method is available
      _logger.w('getAllProgress: getProgress method not available in SDK, returning empty map');
      return {};
    } catch (e) {
      _logger.e('Failed to get all progress', error: e);
      return {};
    }
  }

  void dispose() {
    _client?.dispose();
  }
}
