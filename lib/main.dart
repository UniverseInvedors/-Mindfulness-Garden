import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/responsive/responsive_context.dart';
import 'package:pranaverse/core/services/auth_service.dart';
import 'package:pranaverse/core/services/wallet_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/data/repositories/achievement_repository.dart';
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
import 'package:pranaverse/services/backend_integration_service.dart';

void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _log('FLUTTER ERROR: ${details.exception}');
    _log('Stack trace: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _log('PLATFORM ERROR: $error');
    _log('Stack trace: $stack');
    return true;
  };

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

    try {
      final backendService = BackendIntegrationService();
      await backendService.initialize();
      _log('Backend integration service initialized');

      await AuthService.initialize(backendService);
      _log('Auth service initialized with backend');
    } catch (e) {
      _log('Backend integration initialization failed: $e');
    }

    runApp(
      const riverpod.ProviderScope(
        child: MindfulnessGardenApp(),
      ),
    );
  } catch (e, s) {
    _log('Fatal error during initialization: $e');
    _log('Stack trace: $s');

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
          create: (context) => AchievementProvider(
            context.read<AchievementRepository>(),
          ),
        ),
        provider.ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        provider.ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        provider.Provider<WalletService>(
          create: (_) => WalletService(),
        ),
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
            supportedLocales: const [
              Locale('en'),
              Locale('bn'),
              Locale('hi'),
            ],
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return ResponsiveScope(child: child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}
