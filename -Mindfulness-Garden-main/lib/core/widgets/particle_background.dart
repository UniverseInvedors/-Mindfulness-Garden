import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final AnimationController? animationController;

  const ParticleBackground({
    super.key,
    this.particleCount = 30,
    this.animationController,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.animationController ??
        AnimationController(
          duration: const Duration(seconds: 30),
          vsync: this,
        )
      ..repeat();
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particleCount: widget.particleCount,
        animation: _controller,
      ),
      size: Size.infinite,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final int particleCount;
  final Animation<double> animation;

  _ParticlePainter({
    required this.particleCount,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final x = size.width * ((i + animation.value) % 1);
      final y = size.height *
          (0.5 + 0.4 * (i.isEven ? 1 : -1) * (0.5 + 0.5 * (i % 3) / 3));
      final radius = 2.0 + (i % 5) * 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return particleCount != oldDelegate.particleCount;
  }
}
