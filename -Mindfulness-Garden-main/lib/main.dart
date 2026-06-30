import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/responsive/responsive_context.dart';
import 'package:pranaverse/core/services/analytics_service.dart';
import 'package:pranaverse/core/services/ad_service.dart';
import 'package:pranaverse/core/services/fcm_service.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/services/wallet_service.dart';
import 'package:pranaverse/core/services/location_time_service.dart';
import 'package:pranaverse/core/services/auto_theme_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/data/repositories/achievement_repository.dart';
import 'package:pranaverse/firebase_options.dart';
import 'package:pranaverse/l10n/app_localizations.dart';
import 'package:pranaverse/presentation/providers/achievement_provider.dart';
import 'package:pranaverse/presentation/providers/auth_provider.dart';
import 'package:pranaverse/presentation/providers/challenge_provider.dart';
import 'package:pranaverse/presentation/providers/mood_provider.dart';
import 'package:pranaverse/presentation/providers/session_provider.dart';
import 'package:pranaverse/presentation/providers/subscription_provider.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/presentation/providers/wallet_provider.dart';
import 'package:pranaverse/presentation/routes/app_router.dart';
import 'package:pranaverse/services/audio_manager_service.dart';

void _log(String message) {
  if (kDebugMode) debugPrint(message);
}

/// Initialize enhanced audio manager for immersive experience
Future<void> _initializeAudioManager() async {
  try {
    await AudioManagerService().initialize();
    _log('AudioManagerService initialized successfully');
  } catch (e) {
    _log('AudioManagerService initialization failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase core (must come first) ──────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Analytics + Crashlytics ───────────────────────────────────────────────
  // This call sets up FlutterError.onError and PlatformDispatcher.instance.onError
  await AnalyticsService().initialize();

  try {
    _log('Initializing PranaVerse: Healing Frequencies...');

    await Hive.initFlutter();
    _log('Hive initialized');

    try {
      await LocalStorageService.init();
      _log('LocalStorageService initialized');
    } catch (e) {
      _log('LocalStorageService initialization failed: $e');
    }

    // ── FCM (non-blocking) ────────────────────────────────────────────────
    unawaited(FcmService().initialize());

    // ── AdMob (non-blocking — never delays app start) ─────────────────────
    unawaited(AdService().initialize());

    // ── Sound service ─────────────────────────────────────────────────────
    unawaited(SoundService().initialize());

    // ── Audio Manager Service (Enhanced Audio System) ────────────────────
    unawaited(_initializeAudioManager());

    // ── Location & Auto Theme Services ───────────────────────────────────
    unawaited(LocationTimeService().initialize());
    unawaited(AutoThemeService().initialize());

    runApp(const riverpod.ProviderScope(child: MindfulnessGardenApp()));
  } catch (e, s) {
    _log('Fatal error during initialization: $e');
    _log('Stack trace: $s');
    FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
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

class MindfulnessGardenApp extends riverpod.ConsumerWidget {
  const MindfulnessGardenApp({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => UserProvider()),
        provider.ChangeNotifierProvider(create: (_) => SessionProvider()),
        provider.ChangeNotifierProvider(create: (_) => MoodProvider()),
        provider.Provider<AchievementRepository>(
          create: (_) => AchievementRepository(),
        ),
        provider.ChangeNotifierProvider(
          create: (context) =>
              AchievementProvider(context.read<AchievementRepository>()),
        ),
        provider.ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        provider.ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        provider.Provider<WalletService>(create: (_) => WalletService()),
        provider.ChangeNotifierProxyProvider<UserProvider, WalletProvider>(
          create: (context) => WalletProvider(context.read<WalletService>()),
          update: (context, userProvider, walletProvider) {
            if (userProvider.currentUser != null && walletProvider != null) {
              walletProvider.initializeWallet(userProvider.currentUser!);
            }
            return walletProvider ??
                WalletProvider(context.read<WalletService>());
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final appSettings = context.watch<AppSettingsProvider>();
          final themeMode = appSettings.themeMode;
          final uiThemeData = appSettings.uiThemeData;
          final locale = appSettings.language.locale;

          // ── Sync premium status into AdService ───────────────────────────
          final isPremium =
              context.watch<SubscriptionProvider>().isPremiumUser();
          AdService().setPremium(isPremium);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'PranaVerse',
            theme: AppTheme.buildTheme(uiThemeData),
            darkTheme: AppTheme.buildTheme(uiThemeData),
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('bn'), Locale('hi')],
            routerConfig: AppRouter.router,
            builder: (context, child) {
              final theme = Theme.of(context);
              final defaultTextStyle = theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ) ??
                  TextStyle(color: theme.colorScheme.onSurface);

              return DefaultTextStyle(
                style: defaultTextStyle,
                child: ResponsiveScope(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}
