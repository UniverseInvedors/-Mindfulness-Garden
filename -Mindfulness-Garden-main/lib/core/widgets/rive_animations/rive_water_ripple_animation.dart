import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveWaterRippleAnimation extends StatefulWidget {
  final double? width;
  final double? height;
  final String? animationName;
  final bool loop;

  const RiveWaterRippleAnimation({
    super.key,
    this.width,
    this.height,
    this.animationName,
    this.loop = true,
  });

  @override
  State<RiveWaterRippleAnimation> createState() => _RiveWaterRippleAnimationState();
}

class _RiveWaterRippleAnimationState extends State<RiveWaterRippleAnimation> {
  Artboard? _artboard;
  SMITrigger? _trigger;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      // Load the Rive file for water ripple animation
      final file = await RiveFile.asset(
        'assets/animations/water_ripple.riv',
      );
      
      final artboard = file.mainArtboard;
      final controller = StateMachineController.fromArtboard(
        artboard,
        stateMachineName: widget.animationName ?? 'WaterRippleAnimation',
      );
      
      artboard.addController(controller);
      setState(() {
        _artboard = artboard;
      });
    } catch (e) {
      debugPrint('Rive file not found: $e');
    }
  }

  void triggerAnimation() {
    _trigger?.fire();
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      return SizedBox(
        width: widget.width ?? 120,
        height: widget.height ?? 120,
        child: Rive(
          artboard: _artboard!,
          fit: BoxFit.contain,
        ),
      );
    }

    // Fallback animation if Rive file is not available
    return _buildFallbackAnimation();
  }

  Widget _buildFallbackAnimation() {
    return SizedBox(
      width: widget.width ?? 120,
      height: widget.height ?? 120,
      child: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return CustomPaint(
            painter: _WaterRipplePainter(),
            size: Size(widget.width ?? 120, widget.height ?? 120),
          );
        },
      ),
    );
  }
}

class _WaterRipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw multiple concentric circles to simulate ripples
    final colors = [
      const Color(0xFF4FC3F7).withOpacity(0.6),
      const Color(0xFF4FC3F7).withOpacity(0.4),
      const Color(0xFF4FC3F7).withOpacity(0.2),
      const Color(0xFF4FC3F7).withOpacity(0.1),
    ];

    for (int i = 0; i < colors.length; i++) {
      final radius = 20.0 + i * 15.0;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }

    // Center point
    final centerPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
