// lib/core/optimizations/performance_optimizations.dart
import 'dart:async';

import 'package:flutter/material.dart';

// 1. Image Caching
class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
      cacheWidth: (width != null) ? (width! * 2).toInt() : null,
      cacheHeight: (height != null) ? (height! * 2).toInt() : null,
    );
  }
}

// 2. Lazy Loading Lists
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsets padding;

  const OptimizedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      padding: padding,
      scrollDirection: scrollDirection,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          return _KeepAliveWrapper(child: children[index]);
        },
        childCount: children.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important!
    return widget.child;
  }
}

class OptimizedAnimationBuilder extends StatefulWidget {
  final Widget Function(BuildContext, Animation<double>) builder;
  final Duration duration;
  final Curve curve;

  const OptimizedAnimationBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<OptimizedAnimationBuilder> createState() =>
      _OptimizedAnimationBuilderState();
}

class _OptimizedAnimationBuilderState extends State<OptimizedAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return RepaintBoundary(child: widget.builder(context, _animation));
      },
    );
  }
}

// 4. Memory Management
class MemoryOptimizedScreen extends StatefulWidget {
  const MemoryOptimizedScreen({super.key});

  @override
  State<MemoryOptimizedScreen> createState() => _MemoryOptimizedScreenState();
}

class _MemoryOptimizedScreenState extends State<MemoryOptimizedScreen>
    with WidgetsBindingObserver {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Pre-cache assets
    _precacheAssets();

    // Use ValueNotifier for simple state
    _setupValueListeners();
  }

  Future<void> _precacheAssets() async {
    final images = [
      'assets/images/mindful_garden_icon.png',
    ];

    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
  }

  void _setupValueListeners() {
    // Use ValueNotifier instead of setState for frequent updates
    final valueNotifier = ValueNotifier<int>(0);

    valueNotifier.addListener(() {
      // Handle value changes efficiently
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        for (final controller in _controllers) {
          controller.stop();
        }
        break;
      case AppLifecycleState.resumed:
        for (final controller in _controllers) {
          controller.forward();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden: // Add this case
        _cleanup();
        break;
    }
  }

  void _cleanup() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    for (final timer in _timers) {
      timer.cancel();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _subscriptions.clear();
    _timers.clear();
    _controllers.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
