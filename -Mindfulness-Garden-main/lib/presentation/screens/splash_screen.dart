// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:pranaverse/presentation/providers/auth_provider.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRANVERSE  –  Loading Screen with Progress Bar
// Design: Uses loading screen.png image with animated progress bar (5 sec minimum)
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  bool _disposed = false;
  Timer? _minimumDisplayTimer;
  bool _minimumTimeElapsed = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Progress animation controller - 5 seconds minimum
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        _startLoading();
      }
    });
  }

  void _startLoading() {
    // Start progress animation
    _progressCtrl.forward();

    // Minimum 5 second display timer
    _minimumDisplayTimer = Timer(const Duration(seconds: 5), () {
      if (!_disposed && mounted) {
        setState(() => _minimumTimeElapsed = true);
        _checkAndNavigate();
      }
    });

    // Load app data
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadUserData();
      if (!_disposed && mounted) {
        setState(() => _dataLoaded = true);
        _checkAndNavigate();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Splash error: $e');
      if (!_disposed && mounted) {
        setState(() => _dataLoaded = true);
        _checkAndNavigate();
      }
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted || _disposed) return;
    try {
      await context.read<UserProvider>().loadUser();
    } catch (_) {
      try {
        await context.read<UserProvider>().createDefaultUser();
      } catch (_) {}
    }
  }

  void _checkAndNavigate() {
    // Only navigate when both conditions are met
    if (_minimumTimeElapsed && _dataLoaded && !_disposed && mounted) {
      final auth = context.read<AuthProvider>();
      context.go(auth.currentUserId == null ? '/auth' : '/main');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _progressCtrl.dispose();
    _minimumDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loading screen.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image not found
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0a0a1a),
                        Color(0xFF1a1a2e),
                        Color(0xFF0f3460),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading bar at bottom
          Positioned(
            bottom: 80,
            left: 40,
            right: 40,
            child: Column(
              children: [
                // Loading bar background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00b4d8),
                          ),
                          minHeight: 8,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Loading text
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, child) {
                    final progress = (_progressAnim.value * 100).toInt();
                    return Text(
                      'Loading... $progress%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
