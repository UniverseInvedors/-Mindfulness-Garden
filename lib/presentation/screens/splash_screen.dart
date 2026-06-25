import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';

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
    "Planting tiny seeds of joy...",
    "Growing a playful garden...",
    "Watering happy thoughts...",
    "Nurturing calm adventures...",
    "Almost ready to explore...",
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
      begin: const Color(0xFF1A1A2E),
      end: const Color(0xFF16213E),
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
    if (kDebugMode) {
      debugPrint('Splash screen error: $error');
    }

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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Show loading until animations are initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
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
      backgroundColor: const Color(0xFF1A1A2E),
      body: AnimatedBuilder(
        animation: _mainController!,
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient with modern colors
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        const Color(0xFF0F3460),
                      ],
                    ),
                  ),
                ),
              ),

              // Decorative gradient circles
              Positioned(
                top: -size.height * 0.2,
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9D4EDD).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -size.height * 0.2,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00B4D8).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content with glassmorphism
              Center(
                child: Opacity(
                  opacity: _fadeInAnimation?.value ?? 1.0,
                  child: Transform.scale(
                    scale: _scaleAnimation?.value ?? 1.0,
                    child: GlassContainer(
                      width: isDesktop
                          ? ResponsiveHelper.getMaxContentWidth(context)
                          : size.width * 0.95,
                      height: isDesktop ? size.height * 0.7 : size.height * 0.8,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsivePadding(
                            context,
                            mobilePadding: 24),
                        vertical: ResponsiveHelper.getResponsivePadding(context,
                            mobilePadding: 40),
                      ),
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveBorderRadius(context,
                              mobileRadius: 32)),
                      blur: 20,
                      opacity: 0.15,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9D4EDD).withOpacity(0.3),
                          const Color(0xFF00B4D8).withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Centered Icon Display - Prominent
                            Transform.scale(
                              scale: _logoScaleAnimation?.value ?? 0.0,
                              child: Container(
                                width: ResponsiveHelper
                                    .getResponsiveContainerWidth(context,
                                        mobileWidth: 200,
                                        tabletWidth: 240,
                                        desktopWidth: 280),
                                height: ResponsiveHelper
                                    .getResponsiveContainerHeight(context,
                                        mobileHeight: 200,
                                        tabletHeight: 240,
                                        desktopHeight: 280),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF9D4EDD).withOpacity(0.4),
                                      const Color(0xFF00B4D8).withOpacity(0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9D4EDD)
                                          .withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF00B4D8)
                                          .withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/images/mindful_garden_icon.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF2E7D32),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.spa,
                                        size: 100,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                                height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    mobileSpacing: 40)),

                            // App name
                            SlideTransition(
                              position: _slideAnimation ??
                                  AlwaysStoppedAnimation(Offset.zero),
                              child: Text(
                                'MINDFULNESS\nGARDEN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobileSize: 36,
                                          tabletSize: 42,
                                          desktopSize: 48),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF9D4EDD)
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                                height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    mobileSpacing: 24)),

                            // Tagline
                            AnimatedOpacity(
                              opacity: _showWelcomeText ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                              child: Column(
                                children: [
                                  Text(
                                    'Playful Garden Journey',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context,
                                              mobileSize: 18,
                                              tabletSize: 20,
                                              desktopSize: 24),
                                      color: _textColorAnimation?.value ??
                                          Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              mobileSpacing: 8)),
                                  Text(
                                    'Grow calm adventures with every step',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context,
                                              mobileSize: 14,
                                              tabletSize: 16,
                                              desktopSize: 18),
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    mobileSpacing: 48)),

                            // Loading section
                            AnimatedOpacity(
                              opacity: _showProgressText ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              child: GlassContainer(
                                width: ResponsiveHelper
                                    .getResponsiveContainerWidth(context,
                                        mobileWidth: 280,
                                        tabletWidth: 320,
                                        desktopWidth: 360),
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.getResponsivePadding(context,
                                      mobilePadding: 20),
                                ),
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveBorderRadius(
                                        context,
                                        mobileRadius: 20)),
                                blur: 15,
                                opacity: 0.1,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF9D4EDD).withOpacity(0.2),
                                    const Color(0xFF00B4D8).withOpacity(0.1),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Loading message
                                    Text(
                                      _loadingMessage,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context,
                                                mobileSize: 14,
                                                tabletSize: 16,
                                                desktopSize: 18),
                                        color: Colors.white.withOpacity(0.9),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    SizedBox(
                                        height: ResponsiveHelper
                                            .getResponsiveSpacing(context,
                                                mobileSpacing: 20)),

                                    // Progress bar
                                    Container(
                                      width: ResponsiveHelper
                                          .getResponsiveContainerWidth(context,
                                              mobileWidth: 200,
                                              tabletWidth: 250,
                                              desktopWidth: 300),
                                      height: ResponsiveHelper
                                          .getResponsiveContainerHeight(context,
                                              mobileHeight: 6,
                                              tabletHeight: 7,
                                              desktopHeight: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Progress bar
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: ResponsiveHelper
                                                    .getResponsiveContainerWidth(
                                                        context,
                                                        mobileWidth: 200,
                                                        tabletWidth: 250,
                                                        desktopWidth: 300) *
                                                (_loadingProgress / 100),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              gradient: LinearGradient(
                                                colors: _isLoadingComplete
                                                    ? [
                                                        const Color(0xFF4CAF50),
                                                        const Color(0xFF2E7D32),
                                                      ]
                                                    : [
                                                        const Color(0xFF9D4EDD),
                                                        const Color(0xFF00B4D8),
                                                      ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF9D4EDD)
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                        height: ResponsiveHelper
                                            .getResponsiveSpacing(context,
                                                mobileSpacing: 12)),

                                    // Progress percentage
                                    Text(
                                      '$_loadingProgress%',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context,
                                                mobileSize: 12,
                                                tabletSize: 14,
                                                desktopSize: 16),
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    SizedBox(
                                        height: ResponsiveHelper
                                            .getResponsiveSpacing(context,
                                                mobileSpacing: 16)),

                                    // Loading indicator
                                    Container(
                                      width: ResponsiveHelper
                                          .getResponsiveContainerWidth(context,
                                              mobileWidth: 50,
                                              tabletWidth: 60,
                                              desktopWidth: 70),
                                      height: ResponsiveHelper
                                          .getResponsiveContainerHeight(context,
                                              mobileHeight: 50,
                                              tabletHeight: 60,
                                              desktopHeight: 70),
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
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Animated checkmark or spinner
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child: _isLoadingComplete
                                                ? Icon(
                                                    Icons.check_circle,
                                                    color:
                                                        const Color(0xFF4CAF50),
                                                    size: ResponsiveHelper
                                                        .getResponsiveIconSize(
                                                            context,
                                                            mobileSize: 30,
                                                            tabletSize: 35,
                                                            desktopSize: 40),
                                                  )
                                                : RotationTransition(
                                                    turns: Tween(
                                                            begin: 0.0,
                                                            end: 1.0)
                                                        .animate(
                                                            _mainController!),
                                                    child: Icon(
                                                      Icons.self_improvement,
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      size: ResponsiveHelper
                                                          .getResponsiveIconSize(
                                                              context,
                                                              mobileSize: 25,
                                                              tabletSize: 30,
                                                              desktopSize: 35),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
