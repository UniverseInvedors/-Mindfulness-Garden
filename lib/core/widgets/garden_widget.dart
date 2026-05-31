import 'package:flutter/material.dart';

class GardenWidget extends StatelessWidget {
  const GardenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // Plants and insects
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade50, Colors.green.shade50],
                  ),
                ),
              ),

              // Plants
              Positioned(
                left: 50,
                bottom: 40,
                child: _buildPlant('🌸', size: 40),
              ),
              Positioned(
                right: 80,
                bottom: 30,
                child: _buildPlant('🌻', size: 50),
              ),
              Positioned(
                left: 100,
                bottom: 20,
                child: _buildPlant('🌷', size: 35),
              ),
              Positioned(
                right: 40,
                bottom: 50,
                child: _buildPlant('🌺', size: 45),
              ),

              // Insects
              Positioned(top: 30, left: 60, child: _buildInsect('🦋')),
              Positioned(top: 50, right: 70, child: _buildInsect('🐝')),
              Positioned(top: 20, right: 100, child: _buildInsect('🐞')),

              // Features
              Positioned(left: 30, bottom: 10, child: _buildFeature('⛲')),
              Positioned(right: 30, bottom: 10, child: _buildFeature('🌳')),

              // Meditating person
              Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.self_improvement,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MEDITATING',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlant(String emoji, {double size = 30}) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      child: Text(emoji, style: TextStyle(fontSize: size)),
    );
  }

  Widget _buildInsect(String emoji) {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 3),
      tween: Tween<double>(begin: -10, end: 10),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        );
      },
    );
  }

  Widget _buildFeature(String emoji) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}
