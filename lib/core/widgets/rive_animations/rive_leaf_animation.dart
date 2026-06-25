import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveLeafAnimation extends StatefulWidget {
  final double? width;
  final double? height;
  final String? animationName;
  final bool loop;

  const RiveLeafAnimation({
    super.key,
    this.width,
    this.height,
    this.animationName,
    this.loop = true,
  });

  @override
  State<RiveLeafAnimation> createState() => _RiveLeafAnimationState();
}

class _RiveLeafAnimationState extends State<RiveLeafAnimation> {
  Artboard? _artboard;
  SMITrigger? _trigger;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      // Load the Rive file for floating leaves
      // In a real implementation, you would load the actual Rive file
      // For now, we'll create a placeholder animation
      final file = await RiveFile.asset(
        'assets/animations/floating_leaves.riv',
      );
      
      final artboard = file.mainArtboard;
      final controller = StateMachineController.fromArtboard(
        artboard,
        stateMachineName: widget.animationName ?? 'LeafAnimation',
      );
      
      artboard.addController(controller);
      setState(() {
        _artboard = artboard;
      });
    } catch (e) {
      // If Rive file doesn't exist, use a fallback animation
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
        width: widget.width ?? 100,
        height: widget.height ?? 100,
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
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      child: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return CustomPaint(
            painter: _LeafPainter(),
            size: Size(widget.width ?? 100, widget.height ?? 100),
          );
        },
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw a simple leaf shape
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width, size.height / 4, size.width, size.height / 2);
    path.quadraticBezierTo(size.width, size.height * 0.75, size.width / 2, size.height);
    path.quadraticBezierTo(0, size.height * 0.75, 0, size.height / 2);
    path.quadraticBezierTo(0, size.height / 4, size.width / 2, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Draw vein
    final veinPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final veinPath = Path();
    veinPath.moveTo(size.width / 2, 0);
    veinPath.lineTo(size.width / 2, size.height);
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
