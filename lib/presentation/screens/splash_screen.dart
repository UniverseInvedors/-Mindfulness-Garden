import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';
import 'package:mindfulness_garden/presentation/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _mainController;
  Animation<double>? _fadeInAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _logoScaleAnimation;
  Animation<Color?>? _backgroundGradientAnimation;
  Animation<Color?>? _textColorAnimation;
  Animation<Offset>? _slideAnimation;

  // State variables
  bool _isLoadingComplete = false;
  bool _showWelcomeText = false;
  bool _showProgressText = false;
  bool _isInitialized = false;
  String _loadingMessage = "Initializing garden...";
  int _loadingProgress = 0;
  Timer? _progressTimer;
  Timer? _messageTimer;

  final List<String> _loadingMessages = [
    "Planting seeds of mindfulness...",
    "Growing your garden...",
    "Watering positive thoughts...",
    "Nurturing inner peace...",
    "Almost ready...",
  ];

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    // Initialize after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimations();
    });
  }

  void _initializeAnimations() {
    // Create animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _mainController?.repeat(reverse: true);
      }
    });

    // Initialize animations
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: Curves.elasticOut,
      ),
    );

    _backgroundGradientAnimation = ColorTween(
      begin: const Color(0xFF0A192F),
      end: const Color(0xFF1A365D),
    ).animate(_mainController!);

    _textColorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.0),
      end: Colors.white.withOpacity(1.0),
    ).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    _mainController!.forward();

    // Mark as initialized
    setState(() {
      _isInitialized = true;
    });

    // Start loading sequence
    _startLoadingSequence();
    _startProgressTimer();

    // Initialize app
    _initializeApp();
  }

  void _startLoadingSequence() {
    int messageIndex = 0;
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (messageIndex < _loadingMessages.length && !_disposed && mounted) {
        setState(() {
          _loadingMessage = _loadingMessages[messageIndex];
        });
        messageIndex++;
      } else {
        timer.cancel();
      }
    });

    // Show welcome text with delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_disposed && mounted) {
        setState(() => _showWelcomeText = true);
      }
    });

    // Show progress text with delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!_disposed && mounted) {
        setState(() => _showProgressText = true);
      }
    });
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_loadingProgress < 90 && !_disposed && mounted) {
        setState(() {
          _loadingProgress += 3;
          if (_loadingProgress > 90) _loadingProgress = 90;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Keep splash snappy; don't hold the user on logo.
      await Future.delayed(const Duration(milliseconds: 200));

      // Initialize storage
      await LocalStorageService.init();

      // Load user data
      await _loadUserData();

      // Complete loading
      if (!_disposed && mounted) {
        setState(() {
          _isLoadingComplete = true;
          _loadingProgress = 100;
          _loadingMessage = "Garden ready!";
        });
      }

      // Wait for final animations
      await Future.delayed(const Duration(milliseconds: 150));

      // Navigate to next screen
      _navigateToNextScreen();
    } catch (e) {
      _handleError(e);
    } finally {
      _progressTimer?.cancel();
      _messageTimer?.cancel();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.loadUser();
    } catch (e) {
      // Create default user if loading fails
      final userProvider = context.read<UserProvider>();
      await userProvider.createDefaultUser();
    }
  }

  void _navigateToNextScreen() {
    if (!_disposed && mounted) {
      if (mounted && !_disposed) {
        context.go('/main');
      }
    }
  }

  void _handleError(dynamic error) {
    print('🌱 Splash screen error: $error');

    if (!_disposed && mounted) {
      setState(() {
        _loadingMessage = "Oops! Something went wrong";
        _isLoadingComplete = true;
      });
    }

    // Show error dialog after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_disposed) {
        _showErrorDialog();
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildErrorDialogContent(),
      ),
    );
  }

  Widget _buildErrorDialogContent() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFFD32F2F),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Connection Issue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Unable to connect to garden services.\nWe\'ll continue in offline mode.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              // Retry button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _retryInitialization();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Retry',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Continue button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (mounted && !_disposed) {
                      context.go('/main');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    if (!_disposed && mounted) {
      setState(() {
        _isLoadingComplete = false;
        _loadingProgress = 0;
        _loadingMessage = "Retrying...";
      });

      _startProgressTimer();
      _initializeApp();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _mainController?.dispose();
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Show loading until animations are initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A192F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Preparing garden...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: AnimatedBuilder(
        animation: _mainController!,
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        _backgroundGradientAnimation?.value ??
                            const Color(0xFF0A192F),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Opacity(
                  opacity: _fadeInAnimation?.value ?? 1.0,
                  child: Transform.scale(
                    scale: _scaleAnimation?.value ?? 1.0,
                    child: Container(
                      width: size.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: _logoScaleAnimation?.value ?? 0.0,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.spa,
                                size: 70,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // App name
                          SlideTransition(
                            position: _slideAnimation ?? AlwaysStoppedAnimation(Offset.zero),
                            child: const Text(
                              'MINDFULNESS\nGARDEN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                height: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tagline
                          AnimatedOpacity(
                            opacity: _showWelcomeText ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            child: Column(
                              children: [
                                Text(
                                  'Nurture Your Mind',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _textColorAnimation?.value ??
                                        Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Grow in Peace & Harmony',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Loading section
                          AnimatedOpacity(
                            opacity: _showProgressText ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            child: Column(
                              children: [
                                // Loading message
                                Text(
                                  _loadingMessage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Progress bar
                                Container(
                                  width: 200,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Progress bar
                                      AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
                                        width: 200 * (_loadingProgress / 100),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            colors: _isLoadingComplete
                                                ? [
                                              const Color(0xFF4CAF50),
                                              const Color(0xFF2E7D32),
                                            ]
                                                : [
                                              const Color(0xFF2196F3),
                                              const Color(0xFF1976D2),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Progress percentage
                                Text(
                                  '$_loadingProgress%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Loading indicator
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Animated checkmark or spinner
                                      AnimatedSwitcher(
                                        duration:
                                        const Duration(milliseconds: 500),
                                        child: _isLoadingComplete
                                            ? Icon(
                                          Icons.check_circle,
                                          color: const Color(0xFF4CAF50),
                                          size: 30,
                                        )
                                            : RotationTransition(
                                          turns: Tween(
                                              begin: 0.0, end: 1.0)
                                              .animate(_mainController!),
                                          child: Icon(
                                            Icons.self_improvement,
                                            color: Colors.white
                                                .withOpacity(0.9),
                                            size: 25,
                                          ),
                                        ),
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
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final active =
                            (_mainController?.value ?? 0) > (index + 1) / 3;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF4CAF50)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Version info
                    Column(
                      children: [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '© 2024 Mindfulness Garden',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
