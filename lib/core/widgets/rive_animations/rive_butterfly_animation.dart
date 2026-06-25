import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveButterflyAnimation extends StatefulWidget {
  final double? width;
  final double? height;
  final String? animationName;
  final bool loop;

  const RiveButterflyAnimation({
    super.key,
    this.width,
    this.height,
    this.animationName,
    this.loop = true,
  });

  @override
  State<RiveButterflyAnimation> createState() => _RiveButterflyAnimationState();
}

class _RiveButterflyAnimationState extends State<RiveButterflyAnimation> {
  Artboard? _artboard;
  SMITrigger? _trigger;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      // Load the Rive file for butterfly animation
      final file = await RiveFile.asset(
        'assets/animations/butterfly.riv',
      );
      
      final artboard = file.mainArtboard;
      final controller = StateMachineController.fromArtboard(
        artboard,
        stateMachineName: widget.animationName ?? 'ButterflyAnimation',
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
        width: widget.width ?? 80,
        height: widget.height ?? 80,
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
      width: widget.width ?? 80,
      height: widget.height ?? 80,
      child: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return CustomPaint(
            painter: _ButterflyPainter(),
            size: Size(widget.width ?? 80, widget.height ?? 80),
          );
        },
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wingPaint = Paint()
      ..color = const Color(0xFFE91E63).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final bodyPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    // Left wing
    final leftWing = Path();
    leftWing.moveTo(size.width / 2, size.height / 2);
    leftWing.quadraticBezierTo(0, size.height * 0.2, 0, size.height / 2);
    leftWing.quadraticBezierTo(0, size.height * 0.8, size.width / 2, size.height * 0.7);
    leftWing.close();
    canvas.drawPath(leftWing, wingPaint);

    // Right wing
    final rightWing = Path();
    rightWing.moveTo(size.width / 2, size.height / 2);
    rightWing.quadraticBezierTo(size.width, size.height * 0.2, size.width, size.height / 2);
    rightWing.quadraticBezierTo(size.width, size.height * 0.8, size.width / 2, size.height * 0.7);
    rightWing.close();
    canvas.drawPath(rightWing, wingPaint);

    // Body
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4,
      bodyPaint,
    );

    // Antennae
    final antennaPaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final leftAntenna = Path();
    leftAntenna.moveTo(size.width / 2 - 2, size.height / 2 - 4);
    leftAntenna.quadraticBezierTo(size.width / 2 - 5, size.height * 0.2, size.width / 2 - 8, size.height * 0.15);
    canvas.drawPath(leftAntenna, antennaPaint);

    final rightAntenna = Path();
    rightAntenna.moveTo(size.width / 2 + 2, size.height / 2 - 4);
    rightAntenna.quadraticBezierTo(size.width / 2 + 5, size.height * 0.2, size.width / 2 + 8, size.height * 0.15);
    canvas.drawPath(rightAntenna, antennaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
