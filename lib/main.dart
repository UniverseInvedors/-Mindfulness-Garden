import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mindfulness_garden/data/repositories/achievement_repository.dart';
import 'package:mindfulness_garden/core/themes/app_theme.dart';
import 'package:mindfulness_garden/core/widgets/app_responsive_scaler.dart';
import 'package:mindfulness_garden/presentation/providers/app_provider.dart';
import 'package:mindfulness_garden/presentation/providers/user_provider.dart';
import 'package:mindfulness_garden/presentation/providers/session_provider.dart';
import 'package:mindfulness_garden/presentation/providers/mood_provider.dart';
import 'package:mindfulness_garden/presentation/providers/achievement_provider.dart';
import 'package:mindfulness_garden/presentation/providers/challenge_provider.dart';
import 'package:mindfulness_garden/presentation/providers/subscription_provider.dart';
import 'package:mindfulness_garden/presentation/providers/wallet_provider.dart';
import 'package:mindfulness_garden/presentation/routes/app_router.dart';
import 'package:mindfulness_garden/data/models/achievement_model.dart';
import 'package:mindfulness_garden/data/models/mood_model.dart';
import 'package:mindfulness_garden/data/models/session_model.dart';
import 'package:mindfulness_garden/data/models/user_model.dart';
import 'package:mindfulness_garden/data/models/wallet_model.dart';
import 'package:mindfulness_garden/core/services/ad_service.dart';
import 'package:mindfulness_garden/core/services/wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle errors globally
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print('🚨 FLUTTER ERROR: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    print('🚨 PLATFORM ERROR: $error');
    print('Stack trace: $stack');
    return true;
  };

  try {
    print('🌱 Initializing Mindfulness Garden...');

    // Initialize Firebase - with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('🔥 Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase initialization failed: $e');
      // Continue without Firebase for development
    }

    // Initialize Hive
    await Hive.initFlutter();
    print('📦 Hive initialized');

    // Register Hive adapters with unique typeIds to avoid conflicts
    Hive
      ..registerAdapter(UserModelAdapter())
      ..registerAdapter(UserPreferencesAdapter())
      ..registerAdapter(SessionModelAdapter())
      ..registerAdapter(MoodModelAdapter())
      ..registerAdapter(AchievementModelAdapter());
    // Wallet adapters removed - using SharedPreferences instead

    print('📝 Hive adapters registered');

    // Open Hive boxes with error handling
    try {
      await Future.wait([
        Hive.openBox<UserModel>('users'),
        Hive.openBox<SessionModel>('sessions'),
        Hive.openBox<MoodModel>('moods'),
        Hive.openBox<AchievementModel>('achievements'),
        Hive.openBox<WalletModel>('user_wallets'),
      ]);
      print('🗃️ Hive boxes opened successfully');
    } catch (e) {
      print('⚠️ Error opening Hive boxes: $e');
      // Delete corrupted boxes and retry
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('sessions');
      await Hive.deleteBoxFromDisk('moods');
      await Hive.deleteBoxFromDisk('achievements');
      await Hive.deleteBoxFromDisk('user_wallets');

      await Future.wait([
        Hive.openBox<UserModel>('users'),
        Hive.openBox<SessionModel>('sessions'),
        Hive.openBox<MoodModel>('moods'),
        Hive.openBox<AchievementModel>('achievements'),
        Hive.openBox<WalletModel>('user_wallets'),
      ]);
      print('🗃️ Hive boxes recreated successfully');
    }

    print('🚀 App initialized successfully');

    // Initialize Ads
    try {
      await AdService().initialize();
      print('📢 AdMob initialized successfully');
    } catch (e) {
      print('⚠️ AdMob initialization failed: $e');
    }

    runApp(const MindfulnessGardenApp());
  } catch (e, s) {
    print('💥 Fatal error during initialization: $e');
    print('Stack trace: $s');

    runApp(const _ErrorApp());
  }
}

class _ErrorApp extends StatelessWidget {
  const _ErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MindfulnessGardenApp extends StatefulWidget {
  const MindfulnessGardenApp({super.key});

  @override
  State<MindfulnessGardenApp> createState() => _MindfulnessGardenAppState();
}

class _MindfulnessGardenAppState extends State<MindfulnessGardenApp> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),

        Provider<AchievementRepository>(
          create: (_) => AchievementRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => AchievementProvider(
            context.read<AchievementRepository>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),

        // Wallet provider with service dependency
        Provider<WalletService>(
          create: (_) => WalletService(),
        ),
        ChangeNotifierProxyProvider<UserProvider, WalletProvider>(
          create: (context) => WalletProvider(context.read<WalletService>()),
          update: (context, userProvider, walletProvider) {
            if (userProvider.currentUser != null && walletProvider != null) {
              // Initialize wallet when user is available
              walletProvider.initializeWallet(userProvider.currentUser!);
            }
            return walletProvider ??
                WalletProvider(context.read<WalletService>());
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.select<AppProvider, ThemeMode>(
            (provider) => provider.themeMode,
          );
          final uiThemeData = context.select<AppProvider, AppUiThemeData>(
            (provider) => provider.uiThemeData,
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Mindfulness Garden',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.buildDarkTheme(uiThemeData),
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return AppResponsiveScaler(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
