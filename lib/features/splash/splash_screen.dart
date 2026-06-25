import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Navigate to auth/dashboard after animation
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF43A047),
              Color(0xFF66BB6A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative nature elements
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: 1.0,
                    end: 1.2,
                    duration: 3000.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: 1.2,
                    end: 1.0,
                    duration: 3000.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: 1.0,
                    end: 1.3,
                    duration: 4000.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: 1.3,
                    end: 1.0,
                    duration: 4000.ms,
                    curve: Curves.easeInOut,
                  ),
            ),

            // Floating particles/leaves
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 70.0) % MediaQuery.of(context).size.width,
                top: (index * 50.0) % MediaQuery.of(context).size.height,
                child: _buildFloatingLeaf(index),
              );
            }),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon with glow effect
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF81C784),
                          Color(0xFF4CAF50),
                          Color(0xFF2E7D32),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                        BoxShadow(
                          color: const Color(0xFF81C784).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 70,
                      color: Colors.white,
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(duration: 800.ms)
                      .scale(duration: 1000.ms, curve: Curves.easeOutBack)
                      .then()
                      .shimmer(duration: 2000.ms),

                  const SizedBox(height: 50),

                  // App name with elegant typography
                  Text(
                    'Mindfulness',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .slideY(begin: 0.4, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Garden',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 800.ms, duration: 800.ms)
                      .slideY(begin: 0.4, end: 0),

                  const SizedBox(height: 30),

                  // Tagline
                  Text(
                    'Grow Your Inner Peace',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 4,
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 80),

                  // Begin Journey button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          if (mounted) {
                            context.go('/auth');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 18,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Begin Journey',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF2E7D32),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 1200.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0)
                      .then()
                      .shimmer(duration: 1500.ms),
                ],
              ),
            ),

            // Bottom decorative elements
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDecorativeCircle(const Color(0xFF81C784)),
                    const SizedBox(width: 16),
                    _buildDecorativeCircle(const Color(0xFF4CAF50)),
                    const SizedBox(width: 16),
                    _buildDecorativeCircle(const Color(0xFF2E7D32)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLeaf(int index) {
    return Container(
      width: 15 + (index % 4) * 8,
      height: 15 + (index % 4) * 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1 + (index % 3) * 0.05),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: -80 - (index * 10),
          duration: (4000 + index * 300).ms,
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 1200.ms);
  }

  Widget _buildDecorativeCircle(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: 1.0,
          end: 1.4,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: 1.4,
          end: 1.0,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }
}
